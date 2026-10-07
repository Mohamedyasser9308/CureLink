
import 'package:curelink/l10n/app_localizations.dart';

class AuthValidators {
  AuthValidators._();

  static String? name(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return l10n.enterYourName;
    }

    if (text.length < 2) {
      return l10n.fieldError;
    }

    return null;
  }

  static String? phone(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return l10n.enterYourPhone;
    }

    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(text)) {
      return l10n.fieldError;
    }

    return null;
  }

  static String? email(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return l10n.enterYourEmail;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return l10n.fieldError;
    }

    return null;
  }

  static String? password(
    String? value,
    AppLocalizations l10n,
  ) {
    final text = value ?? '';

    if (text.isEmpty) {
      return l10n.createPassword;
    }

    if (text.length < 8) {
      return l10n.weakPassword;
    }

    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() originalPassword,
    AppLocalizations l10n,
  ) {
    return (String? value) {
      if ((value ?? '').isEmpty) {
        return l10n.reEnterPassword;
      }

      if (value != originalPassword()) {
        return l10n.passwordsDoNotMatch;
      }

      return null;
    };
  }
}
