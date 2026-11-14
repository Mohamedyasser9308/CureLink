import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/chatbot/data/services/gemini_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GeminiTestPage extends StatefulWidget {
  const GeminiTestPage({super.key});

  @override
  State<GeminiTestPage> createState() => _GeminiTestPageState();
}

class _GeminiTestPageState extends State<GeminiTestPage> {
  final TextEditingController _messageController = TextEditingController();
  late final GeminiService _geminiService = GeminiService();

  String? _response;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (_isLoading) return;
    if (message.isEmpty) {
      setState(() {
        _response = null;
        _errorMessage = 'Please enter a message before sending.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _response = null;
      _errorMessage = null;
    });

    try {
      final response = await _geminiService.sendMessage(message);
      if (!mounted) return;
      setState(() {
        if (response.isEmpty) {
          _errorMessage = 'Gemini returned an empty response.';
        } else {
          _response = response;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = kDebugMode
            ? _redactCredentials(error.toString())
            : 'Unable to get a response from Gemini. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _redactCredentials(String message) {
    return message
        .replaceAll(
          RegExp(r'AIza[0-9A-Za-z_-]{20,}'),
          '[redacted API key]',
        )
        .replaceAll(
          RegExp(r'\bbearer\s+[^\s,;]+', caseSensitive: false),
          'Bearer [redacted]',
        )
        .replaceAll(
          RegExp(
            r'(api[_-]?key|key|access[_-]?token|refresh[_-]?token|authorization)\s*[:=]\s*[^\s,;]+',
            caseSensitive: false,
          ),
          '[redacted credential]',
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Connection Test')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _messageController,
                minLines: 5,
                maxLines: 8,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter a message to send to Gemini',
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _sendMessage,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Sending...' : 'Send'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                ),
              ],
              if (_response != null) ...[
                const SizedBox(height: 24),
                Text('Response', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(_response!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
