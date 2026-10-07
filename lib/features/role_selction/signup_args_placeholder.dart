
import 'package:curelink/features/role_selction/user_role_placeholder.dart';

import 'age_group.dart';

class SignUpArgs {
  const SignUpArgs({
    required this.name,
    required this.ageGroup,
    required this.role,
  });

  final String name;
  final AgeGroup ageGroup;
  final UserRole role;
}
