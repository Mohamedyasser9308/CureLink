import 'dart:io';
import 'package:curelink/core/services/cloudinary_service.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/features/medication/data/repositries/medication_repository.dart';
import 'package:curelink/features/medication/presentation/cubit/medication_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRepository repository;

  MedicationCubit({required this.repository}) : super(MedicationInitial());

  Future<void> saveMedication({
    required String patientId,
    required String name,
    required String dosage,
    required String time,
    required String frequency,
    required List<int> weekdays,
    required int? durationDays,
    required String description,
    required String instructions,
    File? image,
  }) async {
    if (state is MedicationLoading) return;

    if (FirebaseAuth.instance.currentUser == null) {
      emit(MedicationError('Please log in first'));
      return;
    }

    if (patientId.trim().isEmpty ||
        name.trim().isEmpty ||
        dosage.trim().isEmpty ||
        time.trim().isEmpty ||
        frequency.trim().isEmpty) {
      emit(MedicationError('Please complete required fields'));
      return;
    }

    if (frequency == 'Specific days' && weekdays.isEmpty) {
      emit(MedicationError('Please select at least one day'));
      return;
    }

    if (durationDays != null && durationDays <= 0) {
      emit(MedicationError('Invalid treatment duration'));
      return;
    }

    emit(MedicationLoading());

    try {
      String? imageUrl;

      if (image != null) {
        imageUrl = await CloudinaryService.uploadImage(image);
      }

      final medicationId = repository.createMedicationId(patientId);

      final now = DateTime.now();

      final medication = MedicationModel(
        id: medicationId,
        name: name.trim(),
        dosage: dosage.trim(),
        times: [time.trim()],
        frequency: frequency,
        weekdays: weekdays,
        durationDays: durationDays,
        startDate: now,
        createdAt: now,
        description: description.trim().isEmpty ? null : description.trim(),
        instructions: instructions.trim().isEmpty ? null : instructions.trim(),
        imageUrl: imageUrl,
      );

      await repository.addMedication(
        patientId: patientId,
        medication: medication,
      );

      emit(MedicationSuccess());
    } on FirebaseException catch (e) {
      emit(MedicationError('Firebase error: ${e.code}'));
    } catch (e) {
      emit(MedicationError('Failed to save medication. Please try again.'));
    }
  }
}
