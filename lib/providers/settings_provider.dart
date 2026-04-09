import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

/// Available session length options.
class SessionLengthOption {
  final int value; // 0 = all nouns
  final String label;
  final String subtitle;

  const SessionLengthOption({
    required this.value,
    required this.label,
    required this.subtitle,
  });
}

const List<SessionLengthOption> kSessionLengthOptions = [
  SessionLengthOption(
    value: 10,
    label: '10 sostantivi',
    subtitle: 'Sessione rapida',
  ),
  SessionLengthOption(
    value: 20,
    label: '20 sostantivi',
    subtitle: 'Sessione media',
  ),
  SessionLengthOption(
    value: SettingsService.allNouns,
    label: 'Tutti i sostantivi',
    subtitle: 'Sessione completa',
  ),
];

/// Holds user preferences and keeps them in sync with SharedPreferences.
class SettingsProvider extends ChangeNotifier {
  final _service = SettingsService();

  int _sessionLength = SettingsService.defaultSessionLength;

  int get sessionLength => _sessionLength;

  /// Returns true if the session should use all available nouns.
  bool get isAllNouns => _sessionLength == SettingsService.allNouns;

  /// Loads persisted settings from SharedPreferences.
  /// Called once at app startup from main().
  Future<void> load() async {
    _sessionLength = await _service.getSessionLength();
    notifyListeners();
  }

  /// Updates the session length, notifies listeners and persists the value.
  Future<void> setSessionLength(int value) async {
    if (_sessionLength == value) return;
    _sessionLength = value;
    notifyListeners();
    await _service.setSessionLength(value);
  }

  /// Resolves the actual number of nouns to use given [totalAvailable].
  /// Returns [totalAvailable] when the setting is "all nouns".
  int resolveCount(int totalAvailable) {
    if (isAllNouns || _sessionLength >= totalAvailable) {
      return totalAvailable;
    }
    return _sessionLength;
  }
}
