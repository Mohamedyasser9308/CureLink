enum ProfileStatus {
  initial,
  generatingId,
  ready,
  saving,
  success,
  failure,
}

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userId = '',
    this.errorMessage,
  });

  final ProfileStatus status;
  final String userId;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    String? userId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}