import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../add_medication/data/models/medication_model.dart';
import '../../domain/entities/caregiver_alert.dart';
import '../../domain/entities/caregiver_patient.dart';
import '../../domain/repositories/caregiver_repository.dart';

class FirestoreCaregiverRepository implements CaregiverRepository {
  FirestoreCaregiverRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _doses(String patientUid) =>
      _firestore.collection('users').doc(patientUid).collection('doses');

  @override
  Stream<List<CaregiverPatient>> watchPatients(String caregiverUid) {
    return _firestore
        .collection('connections')
        .where('caregiverUid', isEqualTo: caregiverUid)
        .snapshots()
        .asyncMap((snapshot) async {
          final connections = snapshot.docs
              .map((doc) => doc.data())
              .where((data) => data['status'] == 'accepted')
              .toList();

          return Future.wait(
            connections.map(
              (data) => _loadPatient(
                patientUid: data['patientUid'] as String? ?? '',
                patientUniqueId: data['patientUniqueId'] as String? ?? '',
              ),
            ),
          );
        });
  }

  Future<CaregiverPatient> _loadPatient({
    required String patientUid,
    required String patientUniqueId,
  }) async {
    final today = _startOfDay(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final userFuture = _firestore.collection('users').doc(patientUid).get();
    final dosesFuture = _doses(patientUid)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(tomorrow))
        .get();
    final results = await Future.wait([userFuture, dosesFuture]);
    final user = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final doses = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final doseData = doses.docs.map((doc) => doc.data()).toList()
      ..sort(
        (a, b) =>
            _readDate(b['scheduledAt']).compareTo(_readDate(a['scheduledAt'])),
      );

    int count(String status) =>
        doseData.where((dose) => dose['status'] == status).length;

    final name = (user.data()?['name'] as String? ?? '').trim();
    final takenCount = count('taken');
    final missedCount = count('missed');
    return CaregiverPatient(
      uid: patientUid,
      uniqueId: patientUniqueId,
      name: name.isEmpty ? patientUniqueId : name,
      takenCount: takenCount,
      missedCount: missedCount,
      pendingCount: doseData.length - takenCount - missedCount,
      latestStatus: doseData.isEmpty
          ? null
          : doseData.first['status'] as String?,
    );
  }

  @override
  Future<List<CaregiverAlert>> getRecentAlerts(
    List<CaregiverPatient> patients,
  ) async {
    final now = DateTime.now();
    final from = _startOfDay(now.subtract(const Duration(days: 6)));
    final until = _startOfDay(now).add(const Duration(days: 1));
    final alertGroups = await Future.wait(
      patients.map((patient) async {
        final snapshot = await _doses(patient.uid)
            .where(
              'scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from),
            )
            .where('scheduledAt', isLessThan: Timestamp.fromDate(until))
            .get();
        return snapshot.docs
            .where((dose) => dose.data()['status'] == 'missed')
            .map(
              (dose) => CaregiverAlert(
                patientName: patient.name,
                medicationName: dose.data()['medicationName'] as String? ?? '',
                scheduledAt: _readDate(dose.data()['scheduledAt']),
              ),
            )
            .toList();
      }),
    );
    final alerts = alertGroups.expand((group) => group).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return alerts;
  }

  @override
  Stream<List<MedicationModel>> watchPatientMedications(String patientUid) {
    return _firestore
        .collection('users')
        .doc(patientUid)
        .collection('medications')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
              .where((medication) => medication.isActive)
              .toList(),
        );
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _readDate(dynamic value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : DateTime.fromMillisecondsSinceEpoch(0);
}
