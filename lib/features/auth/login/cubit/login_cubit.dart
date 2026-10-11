
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../../../l10n/app_localizations.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(LoginInit());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    emit(LoginLoading());

    try {
      await _repository.signIn(
        email: email,
        password: password,
        l10n: l10n,
      );

      emit(LoginSuccess());
    } on AuthException catch (error) {
      emit(LoginError(error.message));
    } catch (_) {
      emit(LoginError(l10n.authenticationFailed));
    }
  }
}
