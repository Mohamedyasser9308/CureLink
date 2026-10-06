import 'package:curelink/features/role_selction/user_role_placeholder.dart' ;
import 'package:flutter/material.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../../core/router/routes_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/role_selction/age_group.dart';
import '../../../../features/role_selction/persona_header.dart';
import '../../../../features/role_selction/selection_card.dart';
import 'signup_args_placeholder.dart';

/// Shows only the roles allowed for [ageGroup]. Patient is preselected
/// (Child and Older Adult have Patient as the only option).
class RolePage extends StatefulWidget {
  const RolePage({super.key, required this.ageGroup});

  final AgeGroup ageGroup;

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  UserRole _selected = UserRole.patient;
  void _continue() {
  AppNavigator.push(
    context,
    RoutesNames.personaHome,
    arguments: SignUpArgs(ageGroup: widget.ageGroup, role: _selected),
  );
}
 

  String _headline(AppLocalizations l10n) => switch (widget.ageGroup) {
        AgeGroup.child => l10n.roleChild,
        AgeGroup.teenager => l10n.roleTeenAdult,
        AgeGroup.olderAdult => l10n.roleOlderAdult,
      };

  String _description(AppLocalizations l10n) => switch (widget.ageGroup) {
        AgeGroup.child => l10n.childRoleHint,
        AgeGroup.teenager => l10n.teenAdultRoleHint,
        AgeGroup.olderAdult => l10n.olderAdultRoleHint,
      };

  (IconData, String, String) _roleUi(UserRole role, AppLocalizations l10n) =>
      switch (role) {
        UserRole.patient => (
            Icons.person_outline,
            l10n.rolePatient,
            l10n.usePatientHint,
          ),
        UserRole.caregiver => (
            Icons.volunteer_activism_outlined,
            l10n.roleCaregiver,
            l10n.useCaregiverHint,
          ),
        UserRole.both => (
            Icons.switch_account_outlined,
            l10n.roleBoth,
            l10n.switchModesHint,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.chooseYourRole,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          PersonaHeader(
            overline: l10n.personaFirst,
            headline: _headline(l10n),
            description: _description(l10n),
          ),
          const SizedBox(height: 16),
          for (final role in widget.ageGroup.allowedRoles) ...[
            Builder(
              builder: (_) {
                final (icon, title, hint) = _roleUi(role, l10n);
                return SelectionCard(
                  icon: icon,
                  title: title,
                  subtitle: hint,
                  selected: _selected == role,
                  onTap: () => setState(() => _selected = role),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          AppButton(label: l10n.continueButton, onPressed: _continue),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}