import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  GeminiService()
    : _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.8-flash',
      );

  final GenerativeModel _model;

  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    final response = await _model.generateContent([Content.text(message)]);
    return response.text?.trim() ?? '';
  }
}
