import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/patient_connection.dart';

class ConnectionService {
  ConnectionService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _connections =>
      _firestore.collection('connections');

  Stream<List<PatientConnection>> watchCaregiverConnections(String uid) {
    return _connections
        .where('caregiverUid', isEqualTo: uid)
        .snapshots()
        .map(_toConnections);
  }

  Stream<List<PatientConnection>> watchPatientConnections(String uid) {
    return _connections
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .map(_toConnections);
  }

  List<PatientConnection> _toConnections(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => PatientConnection.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> requestPatientAccess(String patientUniqueId) async {
    final caregiver = _auth.currentUser;
    if (caregiver == null) {
      throw const ConnectionException('not_signed_in');
    }

    final normalizedId = patientUniqueId.trim().toUpperCase();
    if (normalizedId.isEmpty) {
      throw const ConnectionException('patient_id_required');
    }

    final uniqueIdSnapshot = await _firestore
        .collection('unique_ids')
        .doc(normalizedId)
        .get();
    final patientUid = uniqueIdSnapshot.data()?['uid'] as String?;
    if (!uniqueIdSnapshot.exists || patientUid == null || patientUid.isEmpty) {
      throw const ConnectionException('patient_not_found');
    }
    if (patientUid == caregiver.uid) {
      throw const ConnectionException('cannot_connect_self');
    }

    final caregiverSnapshot = await _firestore
        .collection('users')
        .doc(caregiver.uid)
        .get();
    final caregiverName = (caregiverSnapshot.data()?['name'] as String? ?? '')
        .trim();
    if (caregiverName.isEmpty) {
      throw const ConnectionException('profile_name_missing');
    }

    final connectionRef = _connections.doc('${caregiver.uid}_$patientUid');

    await _firestore.runTransaction((transaction) async {
      final current = await transaction.get(connectionRef);
      final status = current.data()?['status'] as String?;

      if (status == 'pending') {
        throw const ConnectionException('already_pending');
      }
      if (status == 'accepted') {
        throw const ConnectionException('already_connected');
      }

      if (current.exists) {
        transaction.update(connectionRef, {
          'status': 'pending',
          'updatedAt': FieldValue.serverTimestamp(),
          'respondedAt': FieldValue.delete(),
        });
        return;
      }

      transaction.set(connectionRef, {
        'caregiverUid': caregiver.uid,
        'patientUid': patientUid,
        'patientUniqueId': normalizedId,
        'caregiverName': caregiverName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> respondToRequest({
    required PatientConnection connection,
    required bool accept,
  }) async {
    final patient = _auth.currentUser;
    if (patient == null) {
      throw const ConnectionException('not_signed_in');
    }
    if (connection.patientUid != patient.uid) {
      throw const ConnectionException('not_allowed');
    }

    final ref = _connections.doc(connection.id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null || data['status'] != 'pending') {
        throw const ConnectionException('request_no_longer_pending');
      }

      transaction.update(ref, {
        'status': accept ? 'accepted' : 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
