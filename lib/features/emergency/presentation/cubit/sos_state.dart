enum SosStatusType {
  initial,
  loading,
  pending,
  sent,
  partiallySent,
  failure,
  verificationFailed,
}

class SosState {
  final SosStatusType status;
  final String? requestId;
  final String? errorMessage;

  const SosState({
    this.status = SosStatusType.initial,
    this.requestId,
    this.errorMessage,
  });
}
