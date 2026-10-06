enum UserRole {
  patient('Patient'),
  caregiver('Caregiver'),
  both('Both');

  const UserRole(this.value);

  /// Value stored in Firestore.
  final String value;

  static UserRole fromValue(String value) => UserRole.values.firstWhere(
        (e) => e.value == value,
        orElse: () => UserRole.patient,
      );
}