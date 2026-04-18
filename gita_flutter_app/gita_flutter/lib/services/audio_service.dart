import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();
  static bool _ttsInit = false;

  static Future<void> init() async {
    if (_ttsInit) return;
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.45);   // धीमी — Mahabharat जैसी
    await _tts.setPitch(0.6);          // गहरी आवाज़
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ttsInit = true;
  }

  // Play ElevenLabs audio bytes
  static Future<void> playAudioBytes(Uint8List bytes) async {
    try {
      await _player.stop();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/krishna_voice.mp3');
      await file.writeAsBytes(bytes);
      await _player.setFilePath(file.path);
      _player.setSpeed(0.88); // थोड़ा धीमा
      await _player.play();
    } catch (e) {
      rethrow;
    }
  }

  // TTS fallback
  static Future<void> speakTTS(String text) async {
    await init();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      await _tts.stop();
    } catch (_) {}
  }

  static Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  static bool get isPlaying => _player.playing;

  static void dispose() {
    _player.dispose();
  }
}
