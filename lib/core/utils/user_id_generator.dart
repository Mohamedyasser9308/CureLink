import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserIdGenerator {
  UserIdGenerator._();

  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _suffixLength = 6;
  static const int _maxAttempts = 20;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static String _prefixForRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'CL';

      case 'caregiver':
        return 'CR';

      case 'both':
        return 'BO';

      default:
        return 'US';
    }
  }

  static Future<String> generate({
    required String role,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    // Make sure the user is authenticated
    if (user == null) {
      throw Exception(
        'No authenticated user found. Please login first.',
      );
    }

    final prefix = _prefixForRole(role);
    final random = Random.secure();

    for (int attempt = 0; attempt < _maxAttempts; attempt++) {
      final suffix = List.generate(
        _suffixLength,
        (_) => _chars[random.nextInt(_chars.length)],
      ).join();

      final candidate = '$prefix-$suffix';

      final idRef = _firestore
          .collection('unique_ids')
          .doc(candidate);

      try {
        final reserved =
            await _firestore.runTransaction<bool>(
          (transaction) async {
            final snapshot = await transaction.get(idRef);

            if (snapshot.exists) {
              return false;
            }

            transaction.set(idRef, {
              'uniqueId': candidate,
              'prefix': prefix,
              'uid': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });

            return true;
          },
        );

        if (reserved) {
          return candidate;
        }
      } on FirebaseException catch (e) {
        throw Exception(
          'Firebase Error: ${e.code} - ${e.message}',
        );
      }
    }

    throw Exception(
      'Unable to generate a unique CureLink ID after $_maxAttempts attempts.',
    );
  }
}