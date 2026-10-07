
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInit());

  Future<void> login({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    emit(LoginLoading());

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        emit(LoginError(l10n.invalidCredentials));
        return;
      }

      emit(
        LoginError(
          e.message ?? l10n.authenticationFailed,
        ),
      );
    } catch (_) {
      emit(LoginError(l10n.authenticationFailed));
    }
  }
}
