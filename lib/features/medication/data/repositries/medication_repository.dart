import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';

class MedicationRepository {
  final FirebaseFirestore firestore;

  MedicationRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> medicationsRef(String patientId) {
    if (patientId.trim().isEmpty) {
      throw ArgumentError('Patient ID cannot be empty');
    }

    return firestore
        .collection('users')
        .doc(patientId)
        .collection('medications');
  }

  String createMedicationId(String patientId) {
    return medicationsRef(patientId).doc().id;
  }

  Future<void> addMedication({
    required String patientId,
    required MedicationModel medication,
  }) async {
    await medicationsRef(patientId).doc(medication.id).set(medication.toMap());
  }

    Future<MedicationModel?> getMedicationById({
    required String patientId,
    required String medicineId,
  }) async {
    final doc = await medicationsRef(patientId).doc(medicineId).get();
    final data = doc.data();

    if (!doc.exists || data == null) return null;

    return MedicationModel.fromMap(data, doc.id);
  }

  Future<List<MedicationModel>> getMedications({
    required String patientId,
  }) async {
    final snapshot = await medicationsRef(patientId).get();

    return snapshot.docs.map((doc) {
      return MedicationModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> updateMedication({
    required String patientId,
    required MedicationModel medication,
  }) async {
    await medicationsRef(
      patientId,
    ).doc(medication.id).update(medication.toMap());
  }

  Future<void> deleteMedication({
    required String patientId,
    required String medicationId,
  }) async {
    await medicationsRef(patientId).doc(medicationId).delete();
  }
}
