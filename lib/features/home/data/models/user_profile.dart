class UserProfile {
  const UserProfile({required this.name, required this.role});

  final String name;

  final String role;

  factory UserProfile.fromMap(Map<String, dynamic>? map) {
    return UserProfile(
      name: (map?['name'] as String?)?.trim() ?? '',
      role: (map?['role'] as String?)?.trim() ?? '',
    );
  }

  String get firstName {
    if (name.isEmpty) return '';
    return name.split(RegExp(r'\s+')).first;
  }

  bool get canSwitchMode => role.toLowerCase() == 'both';
}
