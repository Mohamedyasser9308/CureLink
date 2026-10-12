
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'm0qi1rny';
  static const String uploadPreset = 'curelink_mobile';

  static Future<String> uploadImage(File image) async {
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
    return data['secure_url'] as String;
  }
}