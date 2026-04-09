import 'package:flutter/foundation.dart';
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

  /// Parses [jsonString] and replaces any previously loaded vocabulary.
  void loadFromJson(String jsonString, String fileName) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _nouns = _parser.parse(jsonString);
      _loadedFileName = fileName;
      _errorMessage =
          _nouns.isEmpty ? 'Nessun sostantivo trovato nel file.' : null;
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
