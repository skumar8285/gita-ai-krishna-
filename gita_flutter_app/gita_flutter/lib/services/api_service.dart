import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/message.dart';

class ApiService {
  // ── Claude API ─────────────────────────────────────────────────────────────
  static Future<String> askKrishna(List<Message> history) async {
    final messages = history.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();

    final response = await http.post(
      Uri.parse(AppConstants.anthropicUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': AppConstants.anthropicKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-5-20251001',
        'max_tokens': 1000,
        'system': AppConstants.krishnaPrompt,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['content'][0]['text'] as String;
    } else {
      throw Exception('Claude API Error: ${response.statusCode}');
    }
  }

  // ── ElevenLabs TTS ─────────────────────────────────────────────────────────
  static Future<Uint8List?> getVoice(String text) async {
    final cleanText = cleanForSpeech(text);
    final shortText = cleanText.length > 800
        ? cleanText.substring(0, 800)
        : cleanText;

    for (final voiceId in AppConstants.voiceIds) {
      try {
        final response = await http.post(
          Uri.parse('${AppConstants.elevenLabsUrl}/$voiceId'),
          headers: {
            'xi-api-key': AppConstants.elevenLabsKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          body: jsonEncode({
            'text': shortText,
            'model_id': 'eleven_multilingual_v2',
            'voice_settings': {
              'stability': 0.35,
              'similarity_boost': 0.90,
              'style': 0.60,
              'use_speaker_boost': true,
            },
          }),
        );

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
