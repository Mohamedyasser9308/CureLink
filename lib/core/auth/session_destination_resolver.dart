enum SessionDestination {
  login,
  completeProfile,
  patientHome,
  caregiverHome,
  invalidProfile,
}

class SessionDestinationResolver {
  static SessionDestination resolve({
    required bool isLoggedIn,
    Map<String, dynamic>? profile,
  }) {
    if (!isLoggedIn) {
      return SessionDestination.login;
    }

    if (profile == null) {
      return SessionDestination.invalidProfile;
    }

    if (profile['profileCompleted'] != true) {
      return SessionDestination.completeProfile;
    }

    final role = profile['role'];

    if (role is! String) {
      return SessionDestination.invalidProfile;
    }

    switch (role.trim().toLowerCase()) {
      case 'patient':
      case 'both':
        return SessionDestination.patientHome;

      case 'caregiver':
        return SessionDestination.caregiverHome;

      default:
        return SessionDestination.invalidProfile;
    }
  }
}
