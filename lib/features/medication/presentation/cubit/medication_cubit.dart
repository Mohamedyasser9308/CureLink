
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/core/services/cloudinary_service.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
import 'package:curelink/features/medication/data/repositries/medication_repository.dart';
import 'package:curelink/features/medication/presentation/cubit/medication_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRepository repository;

  MedicationCubit({
    required this.repository,
  }) : super(const MedicationInitial());

  MedicationModel? _existingMedication;

  bool get isEditMode => _existingMedication != null;

  /// Loads a medication when editing.
  /// If medicineId is empty, the Cubit enters Add Mode.
  Future<void> loadMedication({
    required String patientId,
    String? medicineId,
  }) async {
    emit(const MedicationLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _existingMedication = null;
        emit(
          const MedicationLoadFailure(
            'Please log in first.',
          ),
        );
        return;
      }

      if (patientId.trim().isEmpty) {
        _existingMedication = null;
        emit(
          const MedicationLoadFailure(
            'Patient ID is required.',
          ),
        );
        return;
      }

      final id = medicineId?.trim();

      // Add Mode.
      if (id == null || id.isEmpty) {
        _existingMedication = null;
        emit(const MedicationNew());
        return;
      }

      // Edit Mode.
      final medication = await repository.getMedicationById(
        patientId: patientId,
        medicineId: id,
      );

      if (isClosed) return;

      if (medication == null) {
        _existingMedication = null;
        emit(
          const MedicationLoadFailure(
            'Medication not found.',
          ),
        );
        return;
      }

      _existingMedication = medication;
      emit(MedicationLoaded(medication));
    } on FirebaseException catch (e) {
      if (isClosed) return;

      _existingMedication = null;
      emit(
        MedicationLoadFailure(
          'Firebase error: ${e.code}',
        ),
      );
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

  /// Adds a new medication or updates the existing medication.
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

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(
        const MedicationError(
          'Please log in first.',
        ),
      );
      return;
    }

    final normalizedPatientId = patientId.trim();
    final normalizedName = name.trim();
    final normalizedDosage = dosage.trim();
    final normalizedTime = time.trim();
    final normalizedFrequency = frequency.trim();

    if (normalizedPatientId.isEmpty ||
        normalizedName.isEmpty ||
        normalizedDosage.isEmpty ||
        normalizedTime.isEmpty ||
        normalizedFrequency.isEmpty) {
      emit(
        const MedicationError(
          'Please complete all required fields.',
        ),
      );
      return;
    }

    if (normalizedFrequency == 'Specific days' &&
        weekdays.isEmpty) {
      emit(
        const MedicationError(
          'Please select at least one day.',
        ),
      );
      return;
    }

    if (durationDays != null && durationDays <= 0) {
      emit(
        const MedicationError(
          'Invalid treatment duration.',
        ),
      );
      return;
    }

    final existing = _existingMedication;

    emit(const MedicationLoading());

    String? uploadedImagePublicId;

    try {
      // Keep the existing image unless a new image is selected.
      String? imageUrl = existing?.imageUrl;
      String? imagePublicId = existing?.imagePublicId;

      String? oldImagePublicId;

      // Upload a replacement image if provided.
      if (image != null) {
        final uploaded =
            await CloudinaryService.uploadImageWithDetails(image);

        imageUrl = uploaded.secureUrl;
        imagePublicId = uploaded.publicId;
        uploadedImagePublicId = uploaded.publicId;

        // Find the previous image's public ID for cleanup.
        if (existing != null) {
          oldImagePublicId = existing.imagePublicId;

          if ((oldImagePublicId == null ||
                  oldImagePublicId.isEmpty) &&
              (existing.imageUrl?.isNotEmpty ?? false)) {
            oldImagePublicId =
                CloudinaryService.publicIdFromUrl(
              existing.imageUrl!,
            );
          }
        }
      }

      final now = DateTime.now();

      final medication = MedicationModel(
        id: existing?.id ??
            repository.createMedicationId(normalizedPatientId),
        name: normalizedName,
        dosage: normalizedDosage,
        times: [normalizedTime],
        frequency: normalizedFrequency,
        weekdays: List<int>.from(weekdays),
        durationDays: durationDays,
        startDate: existing?.startDate ?? now,
        createdAt: existing?.createdAt ?? now,
        description: description.trim().isEmpty
            ? null
            : description.trim(),
        instructions: instructions.trim().isEmpty
            ? null
            : instructions.trim(),
        imageUrl: imageUrl,
        imagePublicId: imagePublicId,
        isActive: existing?.isActive ?? true,
      );

      // Add or update the Firestore document.
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
      }

      if (isClosed) return;

      _existingMedication = medication;

      // Delete the previous image only after Firestore succeeds.
      if (image != null &&
          oldImagePublicId != null &&
          oldImagePublicId.isNotEmpty &&
          oldImagePublicId != imagePublicId) {
        try {
          await CloudinaryService.deleteImage(
            oldImagePublicId,
          );
        } catch (_) {
          // Saving succeeded. A failed cleanup should not
          // turn a successful medication save into an error.
        }
      }

      emit(const MedicationSuccess());
    } on FirebaseException catch (e) {
      // If upload succeeded but saving failed, attempt to remove
      // the newly uploaded image to avoid an unused Cloudinary asset.
      await _cleanupUploadedImage(uploadedImagePublicId);

      if (isClosed) return;

      emit(
        MedicationError(
          'Firebase error: ${e.code}',
        ),
      );
    } catch (_) {
      await _cleanupUploadedImage(uploadedImagePublicId);

      if (isClosed) return;

      emit(
        const MedicationError(
          'Failed to save medication. Please try again.',
        ),
      );
    }
  }

  Future<void> _cleanupUploadedImage(
    String? publicId,
  ) async {
    if (publicId == null || publicId.isEmpty) return;

    try {
      await CloudinaryService.deleteImage(publicId);
    } catch (_) {
      // Cleanup is best-effort.
    }
  }
}
