
abstract class MedicationState {
  const MedicationState();
}

class MedicationInitial extends MedicationState {
  const MedicationInitial();
}

class MedicationLoading extends MedicationState {
  const MedicationLoading();
}

class MedicationSuccess extends MedicationState {
  const MedicationSuccess();
}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError(this.message);
}
