import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/home/data/models/medication_model.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Placeholder
class MedicineDetailsPage extends StatelessWidget {
  const MedicineDetailsPage({super.key, required this.medication});

  final MedicationModel medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );

    return AppScaffold(
      title: l10n.medicineDetails,
      scrollable: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(l10n.medicationName, medication.name),
            row(l10n.dose, medication.dosage),
            row(l10n.time, medication.times.join(' · ')),
            row(l10n.instructions, medication.instructions),
          ],
        ),
      ),
    );
  }
}
