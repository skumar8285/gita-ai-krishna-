// Om Bell — pure sine wave tones via dart:math
// Creates sacred 136Hz frequency sound

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

class OmBellService {
  static final AudioPlayer _bellPlayer = AudioPlayer();

  /// Generate Om Bell WAV bytes (136.1 Hz sacred frequency)
  static Uint8List _generateOmWav() {
    const sampleRate = 44100;
    const duration = 3.5; // seconds
    final numSamples = (sampleRate * duration).toInt();

    // 3 harmonics: base, octave, 5th
    const freqs = [136.1, 272.2, 408.3];
    const amps  = [0.60,  0.25,  0.12];

    final samples = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Exponential decay envelope
      final env = math.exp(-t * 1.2);
      double sample = 0;
      for (int fi = 0; fi < freqs.length; fi++) {
        sample += amps[fi] * math.sin(2 * math.pi * freqs[fi] * t) * env;
      }
      // Attack
      final attack = i < 2000 ? i / 2000.0 : 1.0;
      samples[i] = (sample * attack * 28000).clamp(-32768, 32767).toInt();
    }

    // Build WAV
    final dataSize = numSamples * 2;
    final header = ByteData(44);
    // RIFF
    header.setUint8(0, 0x52); header.setUint8(1, 0x49);
    header.setUint8(2, 0x46); header.setUint8(3, 0x46);
    header.setUint32(4, 36 + dataSize, Endian.little);
    header.setUint8(8, 0x57); header.setUint8(9, 0x41);
    header.setUint8(10, 0x56); header.setUint8(11, 0x45);
    // fmt
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74); header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);  // PCM
    header.setUint16(22, 1, Endian.little);  // Mono
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    // data
    header.setUint8(36, 0x64); header.setUint8(37, 0x61);
    header.setUint8(38, 0x74); header.setUint8(39, 0x61);
    header.setUint32(40, dataSize, Endian.little);

    final result = Uint8List(44 + dataSize);
    result.setAll(0, header.buffer.asUint8List());
    final sampleBytes = samples.buffer.asUint8List();
    result.setAll(44, sampleBytes);
    return result;
  }

  static Future<void> playOmBell() async {
    try {
      final wav = _generateOmWav();
      final source = _BytesAudioSource(wav, 'audio/wav');
      await _bellPlayer.stop();
      await _bellPlayer.setAudioSource(source);
      await _bellPlayer.play();
    } catch (_) {}
  }

  static void dispose() => _bellPlayer.dispose();
}

/// Custom audio source from bytes
class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  final String _contentType;

  _BytesAudioSource(this._bytes, this._contentType);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      contentType: _contentType,
      stream: Stream.value(_bytes.sublist(start, end)),
    );
  }
}
