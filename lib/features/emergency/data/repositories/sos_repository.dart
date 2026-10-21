import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sos_model.dart';

class SosRepository {
  SosRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sosRequests =>
      _firestore.collection('sos_requests');

  CollectionReference<Map<String, dynamic>> get _connections =>
      _firestore.collection('connections');

  // --------------------------------------------------
  // Get accepted caregivers for a patient
  // --------------------------------------------------

  Future<List<String>> getAcceptedCaregivers(String patientUid) async {
    final normalizedPatientUid = patientUid.trim();

    if (normalizedPatientUid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty');
    }

    final snapshot = await _connections
        .where('patientUid', isEqualTo: normalizedPatientUid)
        .where('status', isEqualTo: 'accepted')
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .map((doc) => doc.data()['caregiverUid'])
        .whereType<String>()
        .map((uid) => uid.trim())
        .where((uid) => uid.isNotEmpty)
        .toSet()
        .toList();
  }

  // --------------------------------------------------
  // Generate a stable request ID
  // --------------------------------------------------

  String generateRequestId() {
    return _sosRequests.doc().id;
  }

  // --------------------------------------------------
  // Create SOS request
  // --------------------------------------------------

  Future<String> createSosRequest({
    required String requestId,
    required String patientUid,
    required List<String> caregiverUids,
  }) async {
    final normalizedRequestId = requestId.trim();
    final normalizedPatientUid = patientUid.trim();

    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request ID cannot be empty');
    }

    if (normalizedPatientUid.isEmpty) {
      throw ArgumentError('Patient UID cannot be empty');
    }

    if (normalizedRequestId.contains('/')) {
      throw ArgumentError('Request ID cannot contain a slash');
    }

    final uniqueCaregivers = caregiverUids
        .map((uid) => uid.trim())
        .where((uid) => uid.isNotEmpty)
        .toSet()
        .toList();

    if (uniqueCaregivers.isEmpty) {
      throw StateError('No accepted caregivers found');
    }

    if (uniqueCaregivers.contains(normalizedPatientUid)) {
      throw StateError('Patient cannot be their own caregiver');
    }

    final requestRef = _sosRequests.doc(normalizedRequestId);

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(requestRef);

      if (existing.exists) {
        final data = existing.data();

        if (data == null) {
          throw StateError('Existing SOS request has no data');
        }

        // Never overwrite a request belonging
        // to another patient.
        if (data['patientUid'] != normalizedPatientUid) {
          throw StateError('SOS request belongs to another patient');
        }

        // The same request ID must refer to
        // the same set of caregivers.
        final existingCaregivers = data['caregiverUids'];

        if (existingCaregivers is! List ||
            existingCaregivers.any((uid) => uid is! String)) {
          throw StateError('Existing SOS request has invalid caregivers');
        }

        final existingSet = existingCaregivers.cast<String>().toSet();

        final requestedSet = uniqueCaregivers.toSet();

        if (existingSet.length != requestedSet.length ||
            !existingSet.containsAll(requestedSet)) {
          throw StateError('SOS request caregivers do not match');
        }

        // This ID already exists with the same
        // patient and caregivers.
        // Do not create or overwrite it.
        return;
      }

      final request = SosModel(
        id: normalizedRequestId,
        patientUid: normalizedPatientUid,
        caregiverUids: uniqueCaregivers,
        createdAt: DateTime.now().toUtc(),
        status: SosStatus.pending,
      );

      transaction.set(requestRef, request.toMap());
    });

    return normalizedRequestId;
  }

  // --------------------------------------------------
  // Read request from Firestore server
  // --------------------------------------------------

  Future<SosModel?> getSosRequest(String requestId) async {
    final normalizedRequestId = requestId.trim();

    if (normalizedRequestId.isEmpty || normalizedRequestId.contains('/')) {
      throw ArgumentError('Invalid SOS request ID');
    }

    final snapshot = await _sosRequests
        .doc(normalizedRequestId)
        .get(const GetOptions(source: Source.server));

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      throw StateError('SOS request exists without data');
    }

    return SosModel.fromMap(snapshot.id, data);
  }

  // --------------------------------------------------
  // Listen to SOS status changes
  // --------------------------------------------------

  Stream<SosModel> watchSosRequest(String requestId) {
    final normalizedRequestId = requestId.trim();

    if (normalizedRequestId.isEmpty || normalizedRequestId.contains('/')) {
      throw ArgumentError('Invalid SOS request ID');
    }

    return _sosRequests.doc(normalizedRequestId).snapshots().map((snapshot) {
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        throw StateError('SOS request not found');
      }

      return SosModel.fromMap(snapshot.id, data);
    });
  }
}
