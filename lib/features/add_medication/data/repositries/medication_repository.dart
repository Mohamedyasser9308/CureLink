
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medication_model.dart';

class MedicationRepository {
  final FirebaseFirestore firestore;

  MedicationRepository({
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to a patient's medications collection.
  CollectionReference<Map<String, dynamic>> medicationsRef(
    String patientId,
  ) {
    final normalizedPatientId = patientId.trim();

    if (normalizedPatientId.isEmpty) {
      throw ArgumentError('Patient ID cannot be empty.');
    }

    return firestore
        .collection('users')
        .doc(normalizedPatientId)
        .collection('medications');
  }

  /// Generate a unique medication document ID.
  String createMedicationId(String patientId) {
    return medicationsRef(patientId).doc().id;
  }

  /// Add a new medication.
  Future<void> addMedication({
    required String patientId,
    required MedicationModel medication,
  }) async {
    final medicationId = medication.id.trim();

    if (medicationId.isEmpty) {
      throw ArgumentError('Medication ID cannot be empty.');
    }

    await medicationsRef(patientId)
        .doc(medicationId)
        .set(medication.toMap());
  }

  /// Get one medication by ID.
  Future<MedicationModel?> getMedicationById({
    required String patientId,
    required String medicineId,
  }) async {
    final medicationId = medicineId.trim();

    if (medicationId.isEmpty) {
      throw ArgumentError('Medication ID cannot be empty.');
    }

    final document = await medicationsRef(patientId)
        .doc(medicationId)
        .get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return MedicationModel.fromMap(
      data,
      document.id,
    );
  }

  /// Get all medications for a patient.
  Future<List<MedicationModel>> getMedications({
    required String patientId,
  }) async {
    final snapshot = await medicationsRef(patientId).get();

    return snapshot.docs.map((document) {
      return MedicationModel.fromMap(
        document.data(),
        document.id,
      );
    }).toList();
  }

  /// Update an existing medication only.
  Future<void> updateMedication({
    required String patientId,
    required MedicationModel medication,
  }) async {
    final medicationId = medication.id.trim();

    if (medicationId.isEmpty) {
      throw ArgumentError('Medication ID cannot be empty.');
    }

    await medicationsRef(patientId)
        .doc(medicationId)
        .update(medication.toMap());
  }

  /// Delete a medication.
  Future<void> deleteMedication({
    required String patientId,
    required String medicationId,
  }) async {
    final normalizedMedicationId = medicationId.trim();

    if (normalizedMedicationId.isEmpty) {
      throw ArgumentError('Medication ID cannot be empty.');
    }

    await medicationsRef(patientId)
        .doc(normalizedMedicationId)
        .delete();
  }
}
