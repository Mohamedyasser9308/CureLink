import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  Future<void> sendResetEmail({
    required String email,
    required AppLocalizations l10n,
  }) async {
    emit(ForgotPasswordLoading());

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      emit(
        ForgotPasswordSuccess(
          l10n.passwordResetEmailSent,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = l10n.invalidEmail;
          break;

        case 'user-not-found':
          message = l10n.userNotFound;
          break;

        case 'too-many-requests':
          message = l10n.tooManyAttempts;
          break;

        case 'network-request-failed':
          message = l10n.noInternetConnection;
          break;

        default:
          message = l10n.passwordResetFailed;
      }

      emit(ForgotPasswordError(message));
    } catch (_) {
      emit(
        ForgotPasswordError(
          l10n.passwordResetFailed,
        ),
      );
    }
  }
}