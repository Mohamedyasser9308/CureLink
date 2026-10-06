import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_states.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginCubit extends Cubit<LoginStates>{
  LoginCubit() : super(LoginInit());

  Future<void> login({
    required email,
    required password,
  })async{
      emit(LoginLoading());
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        emit(LoginSuccess());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential'){
          emit(LoginError("E-mail or Password is incorrect")); 
          return;
        }
        emit(LoginError(e.message ?? "Authentication failed")); 
      }
  }
}