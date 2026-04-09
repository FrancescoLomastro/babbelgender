import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Provides audio and haptic feedback for correct and wrong answers.
///
/// Tones are generated programmatically as WAV byte buffers —
/// no external asset files required.
class SoundService {
  SoundService._();

  static final AudioPlayer _correctPlayer = AudioPlayer();
  static final AudioPlayer _wrongPlayer = AudioPlayer();

  static late final Uint8List _correctBytes;
  static late final Uint8List _wrongBytes;
  static bool _initialized = false;

  /// Pre-generates tone buffers. Call once from main() before runApp().
  static Future<void> init() async {
    if (_initialized) return;
    // Correct: bright 880 Hz ping, 180 ms, smooth exponential fade
    _correctBytes = _buildWav(
      frequency: 880,
      durationSeconds: 0.18,
      amplitude: 0.38,
      decayRate: 14.0,
    );
    // Wrong: low 180 Hz buzz, 280 ms, soft-clipped (makes it sound harsh)
    _wrongBytes = _buildWav(
      frequency: 180,
      durationSeconds: 0.28,
      amplitude: 0.45,
      decayRate: 7.0,
      distortion: 0.55,
    );
    _initialized = true;
  }

  static Future<void> playCorrect() async {
    HapticFeedback.lightImpact();
    try {
      await _correctPlayer.stop();
      await _correctPlayer.play(BytesSource(_correctBytes));
    } catch (_) {
      // Audio unavailable on this platform — haptic already fired.
    }
  }

  static Future<void> playWrong() async {
    HapticFeedback.heavyImpact();
    try {
      await _wrongPlayer.stop();
      await _wrongPlayer.play(BytesSource(_wrongBytes));
    } catch (_) {
      // Audio unavailable on this platform — haptic already fired.
    }
  }

  // ── WAV generator ───────────────────────────────────────────────────────────

  /// Generates a mono 16-bit PCM WAV file as a [Uint8List].
  ///
  /// [decayRate] controls how fast the volume drops (higher = shorter sustain).
  /// [distortion] applies soft clipping (0 = pure sine, 1 = heavily clipped).
  static Uint8List _buildWav({
    required double frequency,
    required double durationSeconds,
    double amplitude = 0.3,
    double decayRate = 10.0,
    double distortion = 0.0,
    int sampleRate = 22050,
  }) {
    final numSamples = (sampleRate * durationSeconds).round();
    final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
    final totalSize = 44 + dataSize;

    final buf = ByteData(totalSize);
    int o = 0;

    // RIFF header
    _str(buf, o, 'RIFF'); o += 4;
    buf.setUint32(o, 36 + dataSize, Endian.little); o += 4;
    _str(buf, o, 'WAVE'); o += 4;

    // fmt chunk
    _str(buf, o, 'fmt '); o += 4;
    buf.setUint32(o, 16, Endian.little); o += 4;        // chunk size
    buf.setUint16(o, 1, Endian.little); o += 2;         // PCM
    buf.setUint16(o, 1, Endian.little); o += 2;         // mono
    buf.setUint32(o, sampleRate, Endian.little); o += 4;
    buf.setUint32(o, sampleRate * 2, Endian.little); o += 4; // byte rate
    buf.setUint16(o, 2, Endian.little); o += 2;         // block align
    buf.setUint16(o, 16, Endian.little); o += 2;        // bits per sample

    // data chunk
    _str(buf, o, 'data'); o += 4;
    buf.setUint32(o, dataSize, Endian.little); o += 4;

    // PCM samples
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = math.exp(-decayRate * t / durationSeconds);
      double s = amplitude * envelope * math.sin(2 * math.pi * frequency * t);

      // Soft clipping: tanh-style saturation
      if (distortion > 0) {
        s = s * (1.0 + distortion) / (1.0 + distortion * s.abs().clamp(0, 1));
      }

      final pcm = (s * 32767).round().clamp(-32768, 32767);
      buf.setInt16(o, pcm, Endian.little);
      o += 2;
    }

    return buf.buffer.asUint8List();
  }

  static void _str(ByteData d, int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      d.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
}
