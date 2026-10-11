abstract class MedicationState {}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationSuccess extends MedicationState {}

class MedicationError extends MedicationState {
  final String message;

  MedicationError(this.message);
}
