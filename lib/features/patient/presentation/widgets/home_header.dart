import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.userName});

  /// First name from Firestore. Empty falls back to the localized "Patient".
  final String userName;

  String _greeting(AppLocalizations l10n, int hour) {
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final name = userName.isEmpty ? l10n.patient : userName;
    final greeting = _greeting(l10n, DateTime.now().hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.today.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.tertiary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.greetingWithName(greeting, name)} 👋',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.medicationPlanToday,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
