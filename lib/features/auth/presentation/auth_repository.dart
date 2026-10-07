
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/l10n/app_localizations.dart';
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
    required AppLocalizations l10n,
  }) async {
    UserCredential credential;

    // -----------------------------
    // 1. Create Firebase Auth user
    // -----------------------------
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code, l10n));
    } catch (_) {
      throw AuthException(
        l10n.couldNotCreateAccount,
      );
    }

    final user = credential.user;

    if (user == null) {
      throw AuthException(
        l10n.couldNotCreateAccount,
      );
    }

    // -----------------------------
    // 2. Update Firebase profile
    // -----------------------------
    try {
      await user.updateDisplayName(name);
    } catch (_) {
      // Don't block signup if display name update fails.
    }

    // -----------------------------
    // 3. Save profile in Firestore
    // -----------------------------
    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      print(
        'Firestore profile save failed: '
        '${e.code} - ${e.message}',
      );
    } catch (e) {
      print(
        'Firestore profile save failed: $e',
      );
    }
  }

  String _messageFor(
    String code,
    AppLocalizations l10n,
  ) {
    switch (code) {
      case 'email-already-in-use':
        return l10n.emailAlreadyRegistered;

      case 'invalid-email':
        return l10n.invalidEmail;

      case 'weak-password':
        return l10n.weakPassword;

      case 'network-request-failed':
        return l10n.noInternetConnection;

      case 'operation-not-allowed':
        return l10n.emailSignupDisabled;

      case 'too-many-requests':
        return l10n.tooManyAttempts;

      default:
        return l10n.couldNotCreateAccount;
    }
  }
}
