
import 'package:curelink/features/medication/data/models/medication_model.dart';

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

class MedicationLoaded extends MedicationState {
  final MedicationModel medication;

  const MedicationLoaded(this.medication);
}

class MedicationNew extends MedicationState {
  const MedicationNew();
}

class MedicationLoadFailure extends MedicationState {
  final String message;

  const MedicationLoadFailure(this.message);
}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError(this.message);
}
