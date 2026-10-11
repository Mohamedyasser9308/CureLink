import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_repository.dart';
import '../../../../../l10n/app_localizations.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(SignupInitial());

  final AuthRepository _repository;

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    if (state is SignupLoading) return;

    emit(SignupLoading());
    try {
      await _repository.signUp(
        name: name,
        phone: phone,
        email: email,
        password: password,
        l10n: l10n,
      );
      emit(SignupSuccess());
    } on AuthException catch (error) {
      emit(SignupError(error.message));
    } catch (_) {
      emit(SignupError(l10n.couldNotCreateAccount));
    }
  }
}
