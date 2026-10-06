abstract class LoginStates {}

class LoginInit extends LoginStates{}

class LoginLoading extends LoginStates{}

class LoginSuccess extends LoginStates{}

class LoginError extends LoginStates{
  LoginError(this.message);

  final String message;
}
