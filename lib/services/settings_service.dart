import 'package:shared_preferences/shared_preferences.dart';

/// Persists user settings via SharedPreferences.
class SettingsService {
  static const String _sessionLengthKey = 'session_length';

  /// Sentinel value meaning "use all available nouns".
  static const int allNouns = 0;

  /// Default session length on first launch.
  static const int defaultSessionLength = allNouns;

  Future<int> getSessionLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionLengthKey) ?? defaultSessionLength;
  }

  Future<void> setSessionLength(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionLengthKey, value);
  }
}
