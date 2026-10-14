
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionService {
  SessionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot =
        await _firestore.collection('users').doc(user.uid).get();

    return snapshot.data();
  }

  Future<bool> isProfileCompleted() async {
    final profile = await getCurrentUserProfile();
    return profile?['profileCompleted'] == true;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
