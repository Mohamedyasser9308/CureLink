import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Placeholder
class AddMedicinePage extends StatelessWidget {
  const AddMedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.addMedicine,
      body: AppEmptyState(
        title: l10n.addMedicine,
        icon: Icons.add_circle_outline_rounded,
      ),
    );
  }
}
