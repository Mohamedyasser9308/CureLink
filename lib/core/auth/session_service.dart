
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

    // A login can complete before the profile write from onboarding is visible
    // to a fresh session. Retry server reads briefly before routing as incomplete.
    for (var attempt = 0; attempt < 3; attempt++) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      final profile = snapshot.data();
      if (profile?['profileCompleted'] == true || attempt == 2) {
        return profile;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  Future<bool> isProfileCompleted() async {
    final profile = await getCurrentUserProfile();
    return profile?['profileCompleted'] == true;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
