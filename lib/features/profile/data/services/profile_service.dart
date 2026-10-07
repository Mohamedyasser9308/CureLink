import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<String?> uploadProfileImage(File image) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final extension = image.path.split('.').last.toLowerCase();

    final reference = _storage
        .ref()
        .child('users')
        .child(user.uid)
        .child('profile')
        .child('profile_image.$extension');

    await reference.putFile(
      image,
      SettableMetadata(
        contentType: 'image/$extension',
      ),
    );

    return reference.getDownloadURL();
  }

  Future<void> saveProfile({
    required String name,
    required String role,
    required String ageGroup,
    required String uniqueId,
    required String emergencyName,
    required String emergencyPhone,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final userReference =
        _firestore.collection('users').doc(user.uid);

    final data = <String, dynamic>{
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'role': role,
      'ageGroup': ageGroup,
      'uniqueId': uniqueId,
      'emergencyContact': {
        'name': emergencyName,
        'phone': emergencyPhone,
      },
      'profileCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (photoUrl != null && photoUrl.isNotEmpty) {
      data['photoUrl'] = photoUrl;
    }

    await userReference.set(
      data,
      SetOptions(merge: true),
    );
  }
}