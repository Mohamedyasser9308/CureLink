import 'package:curelink/features/role_selction/user_role_placeholder.dart';

import 'age_group.dart';

/// Arguments passed to the profile details page.
class SignUpArgs {
  const SignUpArgs({required this.ageGroup, required this.role});

  final AgeGroup ageGroup;
  final UserRole role;
}