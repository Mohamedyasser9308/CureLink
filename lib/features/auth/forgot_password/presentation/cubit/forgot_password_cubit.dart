import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_repository.dart';
import '../../../../../l10n/app_localizations.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(ForgotPasswordInitial());

  final AuthRepository _repository;

  Future<void> sendResetEmail({
    required String email,
    required AppLocalizations l10n,
  }) async {
    emit(ForgotPasswordLoading());

    try {
      await _repository.sendPasswordResetEmail(
        email: email,
        l10n: l10n,
      );

      emit(
        ForgotPasswordSuccess(
          l10n.passwordResetEmailSent,
        ),
      );
    } on AuthException catch (error) {
      emit(ForgotPasswordError(error.message));
    } catch (_) {
      emit(
        ForgotPasswordError(
          l10n.passwordResetFailed,
        ),
      );
    }
  }
}
