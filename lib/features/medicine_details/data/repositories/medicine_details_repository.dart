import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';


abstract interface class MedicineDetailsDataSource {
  Future<MedicationModel?> getMedication({
    required String patientId,
    required String medicationId,
  });

  Future<void> deleteMedication({
    required String patientId,
    required String medicationId,
  });
}


class MedicineDetailsRepository implements MedicineDetailsDataSource {
  MedicineDetailsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _medications(String patientId) {
    if (patientId.trim().isEmpty) {
      throw ArgumentError('patientId must not be empty');
    }
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('medications');
  }

  @override
  Future<MedicationModel?> getMedication({
    required String patientId,
    required String medicationId,
  }) async {
    if (medicationId.trim().isEmpty) {
      throw ArgumentError('medicationId must not be empty');
    }

    final snapshot = await _medications(patientId).doc(medicationId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return MedicationModel.fromMap(data, snapshot.id);
  }

  @override
  Future<void> deleteMedication({
    required String patientId,
    required String medicationId,
  }) async {
    if (medicationId.trim().isEmpty) {
      throw ArgumentError('medicationId must not be empty');
    }
    await _medications(patientId).doc(medicationId).delete();
  }
}
