
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';

class MedicationRepository {
  final FirebaseFirestore firestore;

  MedicationRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> medicationsRef(
    String patientId,
  ) {
    if (patientId.trim().isEmpty) {
      throw ArgumentError('Patient ID cannot be empty');
    }

    return firestore
        .collection('users')
        .doc(patientId)
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
    if (medication.id.trim().isEmpty) {
      throw ArgumentError('Medication ID cannot be empty');
    }

    await medicationsRef(patientId)
        .doc(medication.id)
        .set(medication.toMap());
  }

  /// Get all medications for a patient.
  Future<List<MedicationModel>> getMedications({
    required String patientId,
  }) async {
    final snapshot = await medicationsRef(patientId).get();

    return snapshot.docs.map((doc) {
      return MedicationModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  /// Replace an existing medication with the updated model.
  Future<void> updateMedication({
    required String patientId,
    required MedicationModel medication,
  }) async {
    if (medication.id.trim().isEmpty) {
      throw ArgumentError('Medication ID cannot be empty');
    }

    await medicationsRef(patientId)
        .doc(medication.id)
        .set(medication.toMap());
  }

  /// Delete a medication document from Firestore.
  Future<void> deleteMedication({
    required String patientId,
    required String medicationId,
  }) async {
    if (medicationId.trim().isEmpty) {
      throw ArgumentError('Medication ID cannot be empty');
    }

    await medicationsRef(patientId).doc(medicationId).delete();
  }
}
