import 'dart:io';

import 'package:curelink/core/services/cloudinary_service.dart';
import 'package:curelink/core/services/dose_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curelink/features/schedule/data/repositories/dose_repository.dart';

import '../../data/models/medication_model.dart';
import '../../data/repositries/medication_repository.dart';
import 'medication_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRepository repository;
  final DoseRepository doseRepository;

  MedicationCubit({required this.repository, DoseRepository? doseRepository})
    : doseRepository = doseRepository ?? DoseRepository(),
      super(const MedicationInitial());

  MedicationModel? _existingMedication;

  bool get isEditMode => _existingMedication != null;

  /// Load an existing medication or enter Add Mode.
  Future<void> loadMedication({
    required String patientId,
    String? medicineId,
  }) async {
    if (isClosed) return;

    emit(const MedicationLoading());

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        _existingMedication = null;
        emit(const MedicationLoadFailure('Please log in first.'));
        return;
      }

      final normalizedPatientId = patientId.trim();

      if (normalizedPatientId.isEmpty) {
        _existingMedication = null;
        emit(const MedicationLoadFailure('Patient ID is required.'));
        return;
      }

      final normalizedMedicineId = medicineId?.trim();

      // Add Mode.
      if (normalizedMedicineId == null || normalizedMedicineId.isEmpty) {
        _existingMedication = null;
        emit(const MedicationNew());
        return;
      }

      // Edit Mode.
      final medication = await repository.getMedicationById(
        patientId: normalizedPatientId,
        medicineId: normalizedMedicineId,
      );

      if (isClosed) return;

      if (medication == null) {
        _existingMedication = null;
        emit(const MedicationLoadFailure('Medication not found.'));
        return;
      }

      _existingMedication = medication;
      emit(MedicationLoaded(medication));
    } on FirebaseException catch (e) {
      if (isClosed) return;

      _existingMedication = null;
      emit(MedicationLoadFailure('Firebase error: ${e.code}'));
    } catch (_) {
      if (isClosed) return;

      _existingMedication = null;
      emit(
        const MedicationLoadFailure(
          'Failed to load medication. Please try again.',
        ),
      );
    }
  }

  /// Add a medication or update the currently loaded medication.
  Future<void> saveMedication({
    required String patientId,
    required String name,
    required String dosage,
    required List<String> times,
    required String frequency,
    required List<int> weekdays,
    required int? durationDays,
    required String description,
    required String instructions,
    File? image,
  }) async {
    if (isClosed || state is MedicationLoading) return;

    if (FirebaseAuth.instance.currentUser == null) {
      emit(const MedicationError('Please log in first.'));
      return;
    }

    final normalizedPatientId = patientId.trim();
    final normalizedName = name.trim();
    final normalizedDosage = dosage.trim();
    final normalizedTimes =
        times
            .map((time) => time.trim())
            .where((time) => time.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final normalizedFrequency = frequency.trim();

    if (normalizedPatientId.isEmpty ||
        normalizedName.isEmpty ||
        normalizedDosage.isEmpty ||
        normalizedTimes.isEmpty ||
        normalizedFrequency.isEmpty) {
      emit(const MedicationError('Please complete all required fields.'));
      return;
    }

    if (normalizedFrequency == 'Specific days' && weekdays.isEmpty) {
      emit(const MedicationError('Please select at least one day.'));
      return;
    }

    if (weekdays.any((day) => day < 1 || day > 7)) {
      emit(const MedicationError('Invalid weekday selection.'));
      return;
    }

    if (durationDays != null && durationDays <= 0) {
      emit(const MedicationError('Invalid treatment duration.'));
      return;
    }

    final existing = _existingMedication;

    // Prevent accidentally adding a new document when an edit
    // operation was requested but the medication was not loaded.
    if (existing != null && existing.id.trim().isEmpty) {
      emit(const MedicationError('Invalid medication ID.'));
      return;
    }

    emit(const MedicationLoading());

    String? uploadedImagePublicId;

    try {
      // Keep the current image unless a replacement is selected.
      String? imageUrl = existing?.imageUrl;
      String? imagePublicId = existing?.imagePublicId;
      String? oldImagePublicId;

      if (image != null) {
        // Upload the new image first.
        final uploaded = await CloudinaryService.uploadImageWithDetails(image);

        imageUrl = uploaded.secureUrl;
        imagePublicId = uploaded.publicId;
        uploadedImagePublicId = uploaded.publicId;

        // Remember the previous image so it can be deleted only
        // after the Firestore save succeeds.
        if (existing != null) {
          oldImagePublicId = existing.imagePublicId;

          if ((oldImagePublicId == null || oldImagePublicId.isEmpty) &&
              (existing.imageUrl?.isNotEmpty ?? false)) {
            oldImagePublicId = CloudinaryService.publicIdFromUrl(
              existing.imageUrl!,
            );
          }
        }
      }

      final now = DateTime.now();

      final medication = MedicationModel(
        id: existing?.id ?? repository.createMedicationId(normalizedPatientId),
        name: normalizedName,
        dosage: normalizedDosage,
        times: normalizedTimes,
        frequency: normalizedFrequency,
        weekdays: weekdays.toSet().toList()..sort(),
        durationDays: durationDays,
        startDate: existing?.startDate ?? now,
        createdAt: existing?.createdAt ?? now,
        description: description.trim().isEmpty ? null : description.trim(),
        instructions: instructions.trim().isEmpty ? null : instructions.trim(),
        imageUrl: imageUrl,
        imagePublicId: imagePublicId,
        isActive: existing?.isActive ?? true,
      );

      // Save to Firestore.
      if (existing == null) {
        await repository.addMedication(
          patientId: normalizedPatientId,
          medication: medication,
        );
      } else {
        await repository.updateMedication(
          patientId: normalizedPatientId,
          medication: medication,
        );

        final today = DateTime(now.year, now.month, now.day);
        final rangeEnd = today.add(
          const Duration(days: DoseRepository.scheduleHorizonDays),
        );
        final scheduledDoses = doseRepository.generateMedicationDoses(
          medication: medication,
          from: today,
          to: rangeEnd,
          now: now,
        );
        await doseRepository.reconcileMedicationDoses(
          patientUid: normalizedPatientId,
          medicationIds: {medication.id},
          scheduledDoses: scheduledDoses,
          from: today,
          to: rangeEnd,
          now: now,
        );
      }

      await DoseNotificationService.instance.syncPatientSchedule(
        normalizedPatientId,
      );

      if (isClosed) return;

      _existingMedication = medication;

      // Delete the old image only after Firestore succeeds.
      if (image != null &&
          oldImagePublicId != null &&
          oldImagePublicId.isNotEmpty &&
          oldImagePublicId != imagePublicId) {
        try {
          await CloudinaryService.deleteImage(oldImagePublicId);
        } catch (_) {
          // The medication was saved successfully.
          // Old-image cleanup is best-effort.
        }
      }

      if (isClosed) return;

      emit(const MedicationSuccess());
    } on FirebaseException catch (e) {
      await _cleanupUploadedImage(uploadedImagePublicId);

      if (isClosed) return;

      emit(MedicationError('Firebase error: ${e.code}'));
    } catch (_) {
      await _cleanupUploadedImage(uploadedImagePublicId);

      if (isClosed) return;

      emit(
        const MedicationError('Failed to save medication. Please try again.'),
      );
    }
  }

  /// Best-effort cleanup when a newly uploaded image cannot be saved.
  Future<void> _cleanupUploadedImage(String? publicId) async {
    if (publicId == null || publicId.isEmpty) return;

    try {
      await CloudinaryService.deleteImage(publicId);
    } catch (_) {
      // Cleanup is best-effort.
    }
  }
}
