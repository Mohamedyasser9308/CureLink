import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  const AuthException(this.message);

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
    late final User user;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final createdUser = credential.user;
      if (createdUser == null) throw const AuthException('');
      user = createdUser;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_signUpMessage(error.code, l10n));
    } on AuthException {
      throw AuthException(l10n.couldNotCreateAccount);
    } catch (_) {
      throw AuthException(l10n.couldNotCreateAccount);
    }

    try {
      await user.updateDisplayName(name);
    } catch (_) {
    }

    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {
        await _auth.signOut();
      }
      throw AuthException(l10n.couldNotCreateAccount);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' =>
          l10n.invalidCredentials,
        'invalid-email' => l10n.invalidEmail,
        'too-many-requests' => l10n.tooManyAttempts,
        'network-request-failed' => l10n.noInternetConnection,
        _ => l10n.authenticationFailed,
      };
      throw AuthException(message);
    } catch (_) {
      throw AuthException(l10n.authenticationFailed);
    }
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    required AppLocalizations l10n,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'invalid-email' => l10n.invalidEmail,
        'user-not-found' => l10n.userNotFound,
        'too-many-requests' => l10n.tooManyAttempts,
        'network-request-failed' => l10n.noInternetConnection,
        _ => l10n.passwordResetFailed,
      };
      throw AuthException(message);
    } catch (_) {
      throw AuthException(l10n.passwordResetFailed);
    }
  }

  String _signUpMessage(String code, AppLocalizations l10n) {
    return switch (code) {
      'email-already-in-use' => l10n.emailAlreadyRegistered,
      'invalid-email' => l10n.invalidEmail,
      'weak-password' => l10n.weakPassword,
      'network-request-failed' => l10n.noInternetConnection,
      'operation-not-allowed' => l10n.emailSignupDisabled,
      'too-many-requests' => l10n.tooManyAttempts,
      _ => l10n.couldNotCreateAccount,
    };
  }
}
