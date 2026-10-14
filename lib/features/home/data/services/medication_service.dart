import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medication_model.dart';
import '../models/user_profile.dart';

class NotSignedInException implements Exception {
  const NotSignedInException();
  @override
  String toString() => 'NotSignedInException: no authenticated user';
}

class MedicationService {
  MedicationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<UserProfile> watchUserProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.error(const NotSignedInException());

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => UserProfile.fromMap(snap.data()));
  }

  Stream<List<MedicationModel>> watchMedications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.error(const NotSignedInException());

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
