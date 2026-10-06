import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw AuthException(
          'Could not create your account. Please try again.',
        );
      }

      await user.updateDisplayName(name);

      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } on FirebaseException {
      throw AuthException(
        'Account created, but we could not save your profile. '
        'Please try again.',
      );
    } catch (_) {
      throw AuthException(
        'Something went wrong. Please try again.',
      );
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'invalid-email':
        return 'This email address is not valid.';

      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';

      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';

      case 'operation-not-allowed':
        return 'Email sign-up is not enabled in Firebase yet.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';

      default:
        return 'Could not create the account. Please try again.';
    }
  }
}
