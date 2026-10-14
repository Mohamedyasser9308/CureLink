
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

  /// Upload an image and return its URL and public ID.
  static Future<CloudinaryUploadResult> uploadImageWithDetails(
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
      throw Exception(
        'Cloudinary upload failed '
        '(${response.statusCode}): $responseBody',
      );
    }

    final decoded = jsonDecode(responseBody);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid Cloudinary response.');
    }

    final secureUrl = decoded['secure_url'] as String?;
    final publicId = decoded['public_id'] as String?;

    if (secureUrl == null ||
        secureUrl.isEmpty ||
        publicId == null ||
        publicId.isEmpty) {
      throw Exception(
        'Cloudinary response is missing image information.',
      );
    }

    return CloudinaryUploadResult(
      secureUrl: secureUrl,
      publicId: publicId,
    );
  }

  /// Backward compatibility with existing callers.
  static Future<CloudinaryUploadResult> uploadImageWithPublicId(
    File image,
  ) async {
    return uploadImageWithDetails(image);
  }

  /// Upload an image and return only its secure URL.
  static Future<String> uploadImage(File image) async {
    final result = await uploadImageWithDetails(image);
    return result.secureUrl;
  }

  /// Delete an image through a secure Firebase Cloud Function.
  static Future<void> deleteImage(String publicId) async {
    final normalizedPublicId = publicId.trim();

    if (normalizedPublicId.isEmpty) {
      throw ArgumentError('Cloudinary public ID cannot be empty.');
    }

    final callable = FirebaseFunctions.instance.httpsCallable(
      'deleteCloudinaryImage',
    );

    final response = await callable.call<Map<dynamic, dynamic>>({
      'publicId': normalizedPublicId,
    });

    final data = response.data;
    final result = data['result']?.toString();

    // Treat an already-deleted image as success.
    if (result == 'ok' || result == 'not found') {
      return;
    }

    throw Exception(
      'Cloudinary image deletion failed: '
      '${result ?? 'Unexpected server response'}',
    );
  }

  
  static String? publicIdFromUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) return null;

    final segments = uri.pathSegments;
    final uploadIndex = segments.indexOf('upload');

    if (uploadIndex == -1 ||
        uploadIndex + 1 >= segments.length) {
      return null;
    }

    var idSegments = segments.sublist(uploadIndex + 1);

    // Skip the version segment when present.
    final versionIndex = idSegments.indexWhere(
      (segment) => RegExp(r'^v\d+$').hasMatch(segment),
    );

    if (versionIndex != -1) {
      idSegments = idSegments.sublist(versionIndex + 1);
    } else {
      // Remove common transformation segments if the URL
      // contains transformations but no version segment.
      while (idSegments.isNotEmpty &&
          _looksLikeTransformation(idSegments.first)) {
        idSegments = idSegments.sublist(1);
      }
    }

    if (idSegments.isEmpty) return null;

    final path = idSegments.join('/');
    final dotIndex = path.lastIndexOf('.');

    return dotIndex == -1
        ? path
        : path.substring(0, dotIndex);
  }

  static bool _looksLikeTransformation(String segment) {
    return segment.contains(',') ||
        RegExp(
          r'^(c_|w_|h_|q_|f_|g_|ar_|r_|e_|dpr_|'
          r'bo_|b_|t_|fl_|l_|o_|a_)',
        ).hasMatch(segment);
  }
}
