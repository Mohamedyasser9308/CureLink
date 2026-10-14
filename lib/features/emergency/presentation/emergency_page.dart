import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Placeholder
class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.emergencySos,
      body: AppEmptyState(
        title: l10n.emergencySos,
        icon: Icons.notifications_active_outlined,
      ),
    );
  }
}
