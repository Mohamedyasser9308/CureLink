import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mode_switcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../add_medication/data/models/medication_model.dart';
import '../../../add_medication/presentation/add_medicine_page.dart';
import '../../../connections/presentation/pages/connections_page.dart';
import '../../../patient/data/models/dose_item.dart';
import '../../../patient/presentation/widgets/medication_card.dart';
import '../../domain/entities/caregiver_alert.dart';
import '../../domain/entities/caregiver_patient.dart';
import '../../domain/repositories/caregiver_repository.dart';

class CaregiverDashboardContent extends StatelessWidget {
  const CaregiverDashboardContent({
    required this.patients,
    required this.alerts,
    required this.repository,
    required this.role,
    required this.showModeSwitcher,
    required this.onModeChanged,
    super.key,
  });

  final List<CaregiverPatient> patients;
  final List<CaregiverAlert> alerts;
  final CaregiverRepository repository;
  final String role;
  final bool showModeSwitcher;
  final ValueChanged<AppMode> onModeChanged;

  void _openConnections(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ConnectionsPage(accountRole: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        if (showModeSwitcher) ...[
          ModeSwitcher(mode: AppMode.caregiver, onChanged: onModeChanged),
          const SizedBox(height: 20),
        ],
        Text(
          l10n.caregiverDashboard.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppTheme.cyan,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(l10n.careOverview, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(l10n.careOverviewSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 18),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () => _openConnections(context),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(l10n.addPatient),
          ),
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: l10n.connectedPatients),
        const SizedBox(height: 10),
        if (patients.isEmpty)
          _EmptyPatientsCard(onTap: () => _openConnections(context))
        else
          for (final patient in patients)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PatientCard(
                patient: patient,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _PatientMedicationsPage(
                      patientUid: patient.uid,
                      repository: repository,
                    ),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 8),
        _SectionTitle(title: l10n.recentAlerts),
        const SizedBox(height: 10),
        _RecentAlerts(alerts: alerts),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: AppTheme.primary,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.35,
    ),
  );
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});
  final CaregiverPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alert = patient.missedCount > 0;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final latestLabel = switch (patient.latestStatus) {
      'missed' => l10n.latestMedicationMissed,
      'taken' => l10n.latestDoseTaken,
      _ => l10n.todaysMedications,
    };
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: alert ? colors.error : colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusChip(
                    label: alert ? l10n.needsAttention : l10n.onTrack,
                    alert: alert,
                    colors: colors,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(latestLabel, style: theme.textTheme.bodySmall),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.dosesSummary(
                  patient.takenCount,
                  patient.missedCount,
                  patient.pendingCount,
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.alert,
    required this.colors,
  });
  final String label;
  final bool alert;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: alert ? colors.error : colors.secondary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: alert ? colors.onError : colors.onSecondary,
      ),
    ),
  );
}

class _EmptyPatientsCard extends StatelessWidget {
  const _EmptyPatientsCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.group_outlined),
      title: Text(AppLocalizations.of(context)!.noLinkedPatients),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _RecentAlerts extends StatelessWidget {
  const _RecentAlerts({required this.alerts});
  final List<CaregiverAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (alerts.isEmpty) {
      return Card(
        color: const Color(0xFFFFFEF8),
        child: ListTile(
          leading: const Icon(Icons.notifications_none_rounded),
          title: Text(l10n.noNewAlerts),
          subtitle: Text(l10n.attentionItemsAppearHere),
        ),
      );
    }
    return Column(
      children: [
        for (final alert in alerts.take(5))
          Card(
            color: const Color(0xFFFBEAEC),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.destructive,
              ),
              title: Text(l10n.missedDose),
              subtitle: Text('${alert.patientName} · ${alert.medicationName}'),
              trailing: Text(
                TimeOfDay.fromDateTime(alert.scheduledAt).format(context),
              ),
            ),
          ),
      ],
    );
  }
}

class _PatientMedicationsPage extends StatefulWidget {
  const _PatientMedicationsPage({
    required this.patientUid,
    required this.repository,
  });

  final String patientUid;
  final CaregiverRepository repository;

  @override
  State<_PatientMedicationsPage> createState() =>
      _PatientMedicationsPageState();
}

class _PatientMedicationsPageState extends State<_PatientMedicationsPage> {
  late final Stream<List<MedicationModel>> _medications;

  @override
  void initState() {
    super.initState();
    _medications = widget.repository.watchPatientMedications(widget.patientUid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientDetails)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMedicine(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedicine),
      ),
      body: StreamBuilder<List<MedicationModel>>(
        stream: _medications,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.somethingWentWrong));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todayDoses = DoseItem.buildToday(
            snapshot.data!,
            DateTime.now(),
          );
          if (todayDoses.isEmpty) {
            return Center(child: Text(l10n.emptyMedicationsTitle));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              for (final dose in todayDoses)
                Padding(
                  key: ValueKey(
                    '${dose.medication.id}-${dose.time.toIso8601String()}',
                  ),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MedicationCard(
                    dose: dose,
                    onTap: () =>
                        _openMedicine(context, medicineId: dose.medication.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openMedicine(BuildContext context, {String? medicineId}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddMedicinePage(
          patientId: widget.patientUid,
          medicineId: medicineId,
        ),
      ),
    );
  }
}
