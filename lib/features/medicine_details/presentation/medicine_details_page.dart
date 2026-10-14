import 'package:curelink/features/medication/presentation/add_medicine_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_button.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/features/medicine_details/data/repositories/medicine_details_repository.dart';
import 'package:curelink/l10n/app_localizations.dart';

class MedicineDetailsPage extends StatefulWidget {
  final String patientId;
  final String medicationId;
  final VoidCallback? onEdit;
  final MedicineDetailsDataSource? repository;

  const MedicineDetailsPage({
    super.key,
    required this.patientId,
    required this.medicationId,
    this.onEdit,
    this.repository,
  });

  @override
  State<MedicineDetailsPage> createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  late final MedicineDetailsDataSource _repository;
  late Future<MedicationModel?> _medicineFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MedicineDetailsRepository();
    _medicineFuture = _loadMedicine();
  }

  Future<MedicationModel?> _loadMedicine() {
    if (widget.patientId.trim().isEmpty || widget.medicationId.trim().isEmpty) {
      throw ArgumentError('Patient ID and medication ID are required.');
    }

    return _repository.getMedication(
      patientId: widget.patientId,
      medicationId: widget.medicationId,
    );
  }

  void _reloadMedicine() {
    setState(() {
      _medicineFuture = _loadMedicine();
    });
  }

  void _retryLoading() {
    _reloadMedicine();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight ? AppTheme.navy : theme.colorScheme.onSurface;
    final secondaryColor = isLight
        ? AppTheme.lightTextSecondary
        : theme.colorScheme.onSurfaceVariant;

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.medicineDetails),
        automaticallyImplyLeading: true,
      ),
      scrollable: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 28, 0, 32),
        child: FutureBuilder<MedicationModel?>(
          future: _medicineFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _MessageState(
                icon: Icons.cloud_off_outlined,
                message: l10n.networkError,
                action: IconButton(
                  onPressed: _retryLoading,
                  icon: const Icon(Icons.refresh),
                ),
              );
            }

            final medication = snapshot.data;
            if (medication == null) {
              return _MessageState(
                icon: Icons.medication_outlined,
                message: l10n.idNotAvailable,
                action: IconButton(
                  onPressed: _retryLoading,
                  icon: const Icon(Icons.refresh),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineDetails,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                _MedicineImage(imageUrl: medication.imageUrl),
                const SizedBox(height: 16),
                Text(
                  medication.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: titleColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                if (_hasText(medication.description)) ...[
                  const SizedBox(height: 6),
                  Text(
                    medication.description!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryColor,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _MedicineSummary(
                  medication: medication,
                  titleColor: titleColor,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: l10n.editMedicine,
                  onPressed: () async {
                    if (widget.onEdit != null) {
                      widget.onEdit!();
                      return;
                    }
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMedicinePage(
                          patientId: widget.patientId,
                          medicineId: widget.medicationId,
                        ),
                      ),
                    );
                    if (result == true && mounted) {
                      setState(() {
                        _medicineFuture = _loadMedicine();
                      });
                    }
                  },
                  icon: Icons.edit_outlined,
                  isExpanded: true,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _isDeleting ? null : _confirmDelete,
                    icon: const Icon(Icons.delete_forever_outlined, size: 18),
                    label: Text(l10n.deleteMedicine),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMedicine),
        content: Text(l10n.deleteMedicineConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      await _repository.deleteMedication(
        patientId: widget.patientId,
        medicationId: widget.medicationId,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.networkError)));
      setState(() => _isDeleting = false);
    }
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget action;

  const _MessageState({
    required this.icon,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 42,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          action,
        ],
      ),
    ),
  );
}

class _MedicineImage extends StatelessWidget {
  final String? imageUrl;
  const _MedicineImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 162,
      decoration: BoxDecoration(
        color: AppTheme.mint.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(28),
      ),
      child: imageUrl != null && imageUrl!.trim().isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (_, __, ___) => const _MedicinePlaceholder(),
              ),
            )
          : const _MedicinePlaceholder(),
    );
  }
}

class _MedicinePlaceholder extends StatelessWidget {
  const _MedicinePlaceholder();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.mint.withValues(alpha: 0.75),
      ),
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.capsules,
          size: 58,
          color: AppTheme.primary,
        ),
      ),
    ),
  );
}

class _MedicineSummary extends StatelessWidget {
  final MedicationModel medication;
  final Color titleColor;

  const _MedicineSummary({required this.medication, required this.titleColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final time = medication.times.isEmpty ? '—' : medication.times.join(', ');

    final duration = switch (medication.durationDays) {
      null => l10n.ongoing,
      7 => l10n.medSevenDays,
      14 => l10n.medFourteenDays,
      30 => l10n.medThirtyDays,
      final days => days.toString(),
    };

    final startDate = DateFormat.yMMMd(locale).format(medication.startDate);

    final weekdays = medication.weekdays.isEmpty
        ? '—'
        : medication.weekdays
              .map((day) {
                final date = DateTime(2024, 1, day);
                return DateFormat.E(locale).format(date);
              })
              .join(', ');

    final rows = <(String, String)>[
      (l10n.dose, medication.dosage),
      (l10n.time, time),
      (l10n.frequency, _localizedFrequency(l10n, medication.frequency)),
      (l10n.duration, duration),
      (l10n.startDate, startDate),
      (l10n.conditions, weekdays),
      if (_hasText(medication.instructions))
        (l10n.instructions, medication.instructions!.trim()),
    ];

    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: titleColor,
      fontSize: 13,
      height: 1.5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: AppTheme.mint.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final row in rows)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${row.$1}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: row.$2),
                ],
              ),
              style: textStyle,
            ),
        ],
      ),
    );
  }

  String _localizedFrequency(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'every day':
      case 'daily':
        return l10n.medEveryDay;
      case 'every other day':
        return l10n.medEveryOtherDay;
      case 'specific days':
        return l10n.medSpecificDays;
      case 'as needed':
        return l10n.medAsNeeded;
      default:
        return value;
    }
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}
