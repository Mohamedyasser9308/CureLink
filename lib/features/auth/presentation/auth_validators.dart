class AuthValidators {
  AuthValidators._();

  static const String genericError = 'Check this field and try again.';

  static String? name(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your name.';
    }

    if (text.length < 2) {
      return genericError;
    }

    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your phone number.';
    }

    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(text)) {
      return genericError;
    }

    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your email.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return genericError;
    }

    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Please enter a password.';
    }

    if (text.length < 8) {
      return 'Use at least 8 characters.';
    }

    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() originalPassword,
  ) {
    return (String? value) {
      if ((value ?? '').isEmpty) {
        return 'Please confirm your password.';
      }

      if (value != originalPassword()) {
        return 'Passwords do not match.';
      }

      return null;
    };
  }
}