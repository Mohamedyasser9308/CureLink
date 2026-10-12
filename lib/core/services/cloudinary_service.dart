import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });
}

class CloudinaryService {
  static const String cloudName = 'm0qi1rny';
  static const String uploadPreset = 'curelink_mobile';

  static Future<String> uploadImage(File image) async {
    final result = await uploadImageWithPublicId(image);
    return result.secureUrl;
  }

  static Future<CloudinaryUploadResult> uploadImageWithPublicId(
    File image,
  ) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Image upload failed: $responseBody');
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    return CloudinaryUploadResult(
      secureUrl: data['secure_url'] as String,
      publicId: data['public_id'] as String,
    );
  }

  static Future<void> deleteImage(String publicId) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'deleteCloudinaryImage',
    );

    final response = await callable.call<dynamic>({'publicId': publicId});
    final result = (response.data as Map)['result'];

    // "not found" means it's already gone, so we treat it as success.
    if (result != 'ok' && result != 'not found') {
      throw Exception('Image delete failed: $result');
    }
  }

  // Older medicines were saved without imagePublicId, so we can
  // recover it from the secure URL:
  // https://res.cloudinary.com/<cloud>/image/upload/v123/<publicId>.<ext>
  static String? publicIdFromUrl(String url) {
    final segments = Uri.tryParse(url)?.pathSegments;
    if (segments == null) return null;

    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex == -1) return null;

    var idSegments = segments.sublist(uploadIndex + 1);

    if (idSegments.isNotEmpty && RegExp(r'^v\d+$').hasMatch(idSegments.first)) {
      idSegments = idSegments.sublist(1);
    }

    if (idSegments.isEmpty) return null;

    final path = idSegments.join('/');
    final dotIndex = path.lastIndexOf('.');

    return dotIndex == -1 ? path : path.substring(0, dotIndex);
  }
}