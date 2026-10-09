
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  // Replace these with your Cloudinary account details.
  static const String _cloudName = 'YOUR_CLOUD_NAME';
  static const String _uploadPreset = 'YOUR_UPLOAD_PRESET';

  Future<String?> uploadProfileImage(File image) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    if (_cloudName == 'YOUR_CLOUD_NAME' ||
        _uploadPreset == 'YOUR_UPLOAD_PRESET') {
      throw Exception(
        'Please configure your Cloudinary cloud name and upload preset.',
      );
    }

    if (!await image.exists()) {
      throw Exception('Selected image does not exist.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'curelink/users/${user.uid}/profile'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      String message = 'Cloudinary image upload failed.';

      try {
        final body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final error = body['error'];

        if (error is Map<String, dynamic> &&
            error['message'] is String) {
          message = error['message'] as String;
        }
      } catch (_) {
        // Keep the default error message if the response is invalid.
      }

      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final photoUrl = data['secure_url'];

    if (photoUrl is! String || photoUrl.isEmpty) {
      throw Exception(
        'Cloudinary did not return a valid image URL.',
      );
    }

    return photoUrl;
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