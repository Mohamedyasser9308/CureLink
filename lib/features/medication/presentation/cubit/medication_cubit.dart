import 'dart:io';
import 'package:curelink/core/services/cloudinary_service.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/features/medication/data/repositries/medication_repository.dart';
import 'package:curelink/features/medication/presentation/cubit/medication_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRepository repository;

  // Set when the medicine already exists on Firestore (Edit Mode).
  MedicationModel? _existingMedication;

  bool get isEditMode => _existingMedication != null;

  MedicationCubit({required this.repository}) : super(MedicationInitial());

  Future<void> loadMedication({
    required String patientId,
    String? medicineId,
  }) async {
    emit(MedicationLoading());

    // No id provided, so this is a new medicine (Add Mode).
    if (medicineId == null ||
        medicineId.trim().isEmpty ||
        patientId.trim().isEmpty) {
      _existingMedication = null;
      emit(MedicationNew());
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      emit(MedicationLoadFailure('Please log in first'));
      return;
    }

    try {
      final medication = await repository.getMedicationById(
        patientId: patientId,
        medicineId: medicineId,
      );

      _existingMedication = medication;

      if (medication == null) {
        emit(MedicationNew());
      } else {
        emit(MedicationLoaded(medication));
      }
    } on FirebaseException catch (e) {
      emit(MedicationLoadFailure('Firebase error: ${e.code}'));
    } catch (e) {
      emit(MedicationLoadFailure('Failed to load medication. Please try again.'));
    }
  }

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
      final existing = _existingMedication;

      // Edit Mode keeps the current image unless the user picked a new one.
      String? imageUrl = existing?.imageUrl;
      String? imagePublicId = existing?.imagePublicId;

      if (image != null) {
        // 1. Delete the old image from Cloudinary.
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final oldPublicId =
              imagePublicId ?? CloudinaryService.publicIdFromUrl(imageUrl);

          if (oldPublicId != null) {
            await CloudinaryService.deleteImage(oldPublicId);
          }
        }

        // 2. Upload the new image.
        final uploaded = await CloudinaryService.uploadImageWithPublicId(image);

        imageUrl = uploaded.secureUrl;
        imagePublicId = uploaded.publicId;
      }

      final medicationId =
          existing?.id ?? repository.createMedicationId(patientId);

      final now = DateTime.now();

      final medication = MedicationModel(
        id: medicationId,
        name: name.trim(),
        dosage: dosage.trim(),
        times: [time.trim()],
        frequency: frequency,
        weekdays: weekdays,
        durationDays: durationDays,
        startDate: existing?.startDate ?? now,
        createdAt: existing?.createdAt ?? now,
        description: description.trim().isEmpty ? null : description.trim(),
        instructions: instructions.trim().isEmpty ? null : instructions.trim(),
        imageUrl: imageUrl,
        imagePublicId: imagePublicId,
      );

      // 3. Save to Firestore.
      if (existing == null) {
        await repository.addMedication(
          patientId: patientId,
          medication: medication,
        );
      } else {
        await repository.updateMedication(
          patientId: patientId,
          medication: medication,
        );

        _existingMedication = medication;
      }

      emit(MedicationSuccess());
    } on FirebaseException catch (e) {
      emit(MedicationError('Firebase error: ${e.code}'));
    } catch (e) {
      emit(MedicationError('Failed to save medication. Please try again.'));
    }
  }
}