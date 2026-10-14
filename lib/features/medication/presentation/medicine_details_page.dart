
import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MedicineDetailsPage extends StatelessWidget {
  const MedicineDetailsPage({
    super.key,
    required this.medication,
  });

  final MedicationModel medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final times = medication.times
        .where((time) => time.trim().isNotEmpty)
        .join(' · ');

    final frequency = _frequencyLabel(medication.frequency, l10n);

    final duration = medication.durationDays == null
        ? l10n.medOngoing
        : '${medication.durationDays} ${l10n.days}';

    Widget detailCard({
      required IconData icon,
      required String label,
      required String value,
    }) {
      final displayValue = value.trim().isEmpty ? '—' : value;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    displayValue,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      title: l10n.medicineDetails,
      scrollable: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: _medicineImage(),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                medication.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            detailCard(
              icon: Icons.medication_outlined,
              label: l10n.medicationName,
              value: medication.name,
            ),

            detailCard(
              icon: Icons.scale_outlined,
              label: l10n.dose,
              value: medication.dosage,
            ),

            detailCard(
              icon: Icons.access_time_rounded,
              label: l10n.time,
              value: times,
            ),

            detailCard(
              icon: Icons.repeat_rounded,
              label: l10n.medFrequencyDuration,
              value: frequency,
            ),

            detailCard(
              icon: Icons.calendar_month_outlined,
              label: l10n.medTreatmentDuration,
              value: duration,
            ),

            if (medication.weekdays.isNotEmpty)
              detailCard(
                icon: Icons.date_range_rounded,
                label: l10n.medSelectDays,
                value: medication.weekdays
                    .map((day) => _weekdayLabel(day, l10n))
                    .join(' · '),
              ),

            if ((medication.description ?? '').trim().isNotEmpty)
              detailCard(
                icon: Icons.notes_rounded,
                label: l10n.medDescription,
                value: medication.description!,
              ),

            if ((medication.instructions ?? '').trim().isNotEmpty)
              detailCard(
                icon: Icons.info_outline_rounded,
                label: l10n.instructions,
                value: medication.instructions!,
              ),

            detailCard(
              icon: medication.isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              label: l10n.medStatus,
              value: medication.isActive
                  ? l10n.medActive
                  : l10n.medInactive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicineImage() {
    final imageUrl = medication.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return const Icon(
        Icons.medication_rounded,
        color: AppTheme.primary,
        size: 52,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image_outlined,
          color: AppTheme.primary,
          size: 48,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  String _frequencyLabel(String frequency, AppLocalizations l10n) {
    switch (frequency.trim().toLowerCase()) {
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
        return frequency;
    }
  }

  String _weekdayLabel(int day, AppLocalizations l10n) {
    switch (day) {
      case DateTime.monday:
        return l10n.medMonday;
      case DateTime.tuesday:
        return l10n.medTuesday;
      case DateTime.wednesday:
        return l10n.medWednesday;
      case DateTime.thursday:
        return l10n.medThursday;
      case DateTime.friday:
        return l10n.medFriday;
      case DateTime.saturday:
        return l10n.medSaturday;
      case DateTime.sunday:
        return l10n.medSunday;
      default:
        return day.toString();
    }
  }
}
