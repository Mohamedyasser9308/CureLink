import 'package:curelink/features/role_selction/user_role_placeholder.dart';


enum AgeGroup {
  child('Child'),
  // UI label is "Teen / Adult"; stored value stays 'Teenager'.
  teenager('Teenager'),
  olderAdult('Older Adult');

  const AgeGroup(this.value);

  /// Value stored in Firestore.
  final String value;

  /// Roles this age group is allowed to pick.
  List<UserRole> get allowedRoles =>
      this == AgeGroup.teenager ? UserRole.values : const [UserRole.patient];

  static AgeGroup fromValue(String value) => AgeGroup.values.firstWhere(
        (e) => e.value == value,
        orElse: () => AgeGroup.child,
      );
}
