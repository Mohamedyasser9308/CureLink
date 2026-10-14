import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/home/data/models/dose_item.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// One card per scheduled dose ("Medication name · Dose · 08:00").
class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key, required this.dose, required this.onTap});

  final DoseItem dose;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final timeLabel = DateFormat.jm(locale).format(dose.time);
    final status = dose.statusAt(DateTime.now());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: scheme.tertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.medication.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dose.medication.dosage} · $timeLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: status, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.l10n});

  final DoseStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    late final String label;
    late final Color background;
    late final Color foreground;

    switch (status) {
      case DoseStatus.dueNow:
        label = l10n.statusDueNow;
        background = const Color(0xFFFFEBC7);
        foreground = const Color(0xFF9A5B00);
      case DoseStatus.upcoming:
        label = l10n.statusUpcoming;
        background = scheme.tertiary.withValues(alpha: 0.15);
        foreground = isDark ? AppTheme.cyan : AppTheme.navy;
      case DoseStatus.past:
        // Placeholder until dose logs exist (then: taken / missed).
        label = l10n.statusPending;
        background = scheme.onSurface.withValues(alpha: 0.08);
        foreground = scheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}
