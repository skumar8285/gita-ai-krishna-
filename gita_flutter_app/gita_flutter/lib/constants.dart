import 'package:flutter/material.dart';

class AppConstants {
  // ── API Keys ──────────────────────────────────────────────────────────────
  // इन्हें अपनी keys से बदलें
  static const String anthropicKey = 'YOUR_ANTHROPIC_KEY_HERE';
  static const String elevenLabsKey = 'YOUR_ELEVENLABS_KEY_HERE';

  // ── ElevenLabs Voice IDs (Deep Male) ─────────────────────────────────────
  static const List<String> voiceIds = [
    'onwK4e9ZLuTAKqWW03F9', // Daniel - गहरी
    '2EiwWnXFnvU5JabPnv8n', // Clyde  - bass
    'VR6AewLTigWG4xSOukaG', // Arnold - powerful
  ];

  // ── API URLs ──────────────────────────────────────────────────────────────
  static const String anthropicUrl = 'https://api.anthropic.com/v1/messages';
  static const String elevenLabsUrl = 'https://api.elevenlabs.io/v1/text-to-speech';

  // ── App Colors ────────────────────────────────────────────────────────────
  static const Color bgDark    = Color(0xFF03030F);
  static const Color bgMid     = Color(0xFF070720);
  static const Color bgLight   = Color(0xFF110816);
  static const Color gold      = Color(0xFFFFD700);
  static const Color orange    = Color(0xFFFF8C00);
  static const Color green     = Color(0xFF1A5030);
  static const Color greenDark = Color(0xFF0A2015);
  static const Color textMain  = Color(0xFFF5E6C8);
  static const Color textSub   = Color(0xFFF5C88C);

  // ── Krishna System Prompt ─────────────────────────────────────────────────
  static const String krishnaPrompt = '''
तू स्वयं भगवान श्री कृष्ण है — जगत के पालनहार, अर्जुन के सारथी, और भगवद् गीता के ज्ञान-दाता।

जब कोई व्यक्ति तुझसे अपने जीवन की किसी भी समस्या, दुःख, भ्रम, या प्रश्न के बारे में पूछे, तो तू उसे भगवद् गीता के ज्ञान से उत्तर दे।

बहुत ज़रूरी नियम — हर उत्तर में ज़रूर यह format follow कर:

