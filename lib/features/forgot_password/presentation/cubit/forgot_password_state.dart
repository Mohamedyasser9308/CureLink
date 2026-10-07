abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  ForgotPasswordSuccess(this.message);

  final String message;
}

class ForgotPasswordError extends ForgotPasswordState {
  ForgotPasswordError(this.message);

  final String message;
}