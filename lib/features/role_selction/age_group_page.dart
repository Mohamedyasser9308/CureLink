
import 'package:flutter/material.dart';

import '../../../../core/router/app_navigation.dart';
import '../../../../core/router/routes_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/role_selction/age_group.dart';
import '../../../../features/role_selction/persona_header.dart';
import '../../../../features/role_selction/selection_card.dart';
import '../../../../features/role_selction/signup_args_placeholder.dart';

class AgeGroupPage extends StatefulWidget {
  const AgeGroupPage({
    super.key,
    required this.name,
  });

  final String name;

  @override
  State<AgeGroupPage> createState() => _AgeGroupPageState();
}

class _AgeGroupPageState extends State<AgeGroupPage> {
  AgeGroup? _selected;

  void _continue() {
    final age = _selected;

    if (age == null) return;

    AppNavigator.push(
      context,
      RoutesNames.rolePage,
      arguments: SignUpArgs(
        name: widget.name,
        ageGroup: age,
        role: age.allowedRoles.first,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = <(AgeGroup, IconData, String, String)>[
      (
        AgeGroup.child,
        Icons.child_care_outlined,
        l10n.roleChild,
        l10n.childRoleHint,
      ),
      (
        AgeGroup.teenager,
        Icons.person_outline,
        l10n.roleTeenAdult,
        l10n.teenAdultRoleHint,
      ),
      (
        AgeGroup.olderAdult,
        Icons.elderly_outlined,
        l10n.roleOlderAdult,
        l10n.olderAdultRoleHint,
      ),
    ];

    return AppScaffold(
      title: l10n.chooseYourRole,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          PersonaHeader(
            overline: l10n.personaFirst,
            headline: l10n.ageGroup,
            description: l10n.ageGroupSubtitle,
          ),

          const SizedBox(height: 16),

          for (final (age, icon, title, hint) in items) ...[
            SelectionCard(
              icon: icon,
              title: title,
              subtitle: hint,
              selected: _selected == age,
              onTap: () {
                setState(() {
                  _selected = age;
                });
              },
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 4),

          AppButton(
            label: l10n.continueButton,
            onPressed: _selected == null ? null : _continue,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
