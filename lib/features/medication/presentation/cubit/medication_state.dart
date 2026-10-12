import 'package:curelink/features/medication/data/models/medication_model.dart';

abstract class MedicationState {}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationSuccess extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final MedicationModel medication;

  MedicationLoaded(this.medication);
}

class MedicationNew extends MedicationState {}

class MedicationLoadFailure extends MedicationState {
  final String message;

  MedicationLoadFailure(this.message);
}

class MedicationError extends MedicationState {
  final String message;

  MedicationError(this.message);
}