import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/noun.dart';
import '../services/json_parser_service.dart';

/// Holds the vocabulary loaded from a Babbel JSON export.
/// Lives at the top of the widget tree so every screen can access it.
class VocabularyProvider extends ChangeNotifier {
  final _parser = JsonParserService();

  List<Noun> _nouns = [];
  String? _loadedFileName;
  String? _errorMessage;
  bool _isLoading = false;

  List<Noun> get nouns => List.unmodifiable(_nouns);
  String? get loadedFileName => _loadedFileName;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasVocabulary => _nouns.isNotEmpty;

  static const String _jsonKey = 'vocabulary_json';
  static const String _fileNameKey = 'vocabulary_filename';

  /// Tries to restore a previously saved vocabulary from SharedPreferences.
  /// Call this once during app startup before [runApp].
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_jsonKey);
    final name = prefs.getString(_fileNameKey);
    if (saved != null && saved.isNotEmpty) {
      try {
        _nouns = _parser.parse(saved);
        _loadedFileName = name;
      } catch (_) {
        // Saved data is corrupt — silently discard it.
        _nouns = [];
        _loadedFileName = null;
        await prefs.remove(_jsonKey);
        await prefs.remove(_fileNameKey);
      }
      notifyListeners();
    }
  }

  /// Parses [jsonString] and replaces any previously loaded vocabulary.
  /// Persists the raw JSON so it survives app restarts.
  Future<void> loadFromJson(String jsonString, String fileName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _nouns = _parser.parse(jsonString);
      _loadedFileName = fileName;
      _errorMessage =
          _nouns.isEmpty ? 'Nessun sostantivo trovato nel file.' : null;

      if (_nouns.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_jsonKey, jsonString);
        await prefs.setString(_fileNameKey, fileName);
      }
    } on FormatException catch (e) {
      _nouns = [];
      _loadedFileName = null;
      _errorMessage = 'File non valido: ${e.message}';
    } catch (_) {
      _nouns = [];
      _loadedFileName = null;
      _errorMessage = 'Errore durante il caricamento del file.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
