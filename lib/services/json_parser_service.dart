import 'dart:convert';
import '../models/noun.dart';

/// Parses a Babbel vocabulary JSON export and extracts German nouns.
///
/// A vocabulary item is considered a noun if its [learn_language_text]
/// starts with a definite article: "der" (masculine), "die" (feminine),
/// or "das" (neuter).
class JsonParserService {
  static const Map<String, Gender> _articleToGender = {
    'der': Gender.masculine,
    'die': Gender.feminine,
    'das': Gender.neuter,
  };

  /// Parses [jsonString] and returns the list of nouns found.
  ///
  /// Throws a [FormatException] if the string is not valid JSON or the
  /// top-level structure is unexpected.
  List<Noun> parse(String jsonString) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      throw FormatException('Invalid JSON: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected a JSON object at the top level.',
      );
    }

    final vocabulary = decoded['vocabulary'];
    if (vocabulary == null) {
      throw const FormatException(
        'Missing "vocabulary" key in JSON.',
      );
    }
    if (vocabulary is! List) {
      throw const FormatException(
        '"vocabulary" must be a JSON array.',
      );
    }

    final nouns = <Noun>[];
    for (final item in vocabulary) {
      final noun = _tryParseNoun(item);
      if (noun != null) nouns.add(noun);
    }
    return nouns;
  }

  /// Attempts to build a [Noun] from a raw vocabulary item map.
  /// Returns null if the item is not a standalone noun entry.
  Noun? _tryParseNoun(dynamic item) {
    if (item is! Map<String, dynamic>) return null;

    final learnText = item['learn_language_text'];
    if (learnText is! String || learnText.isEmpty) return null;

    final parts = learnText.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return null; // needs at least article + word

    final article = parts[0].toLowerCase();
    final gender = _articleToGender[article];
    if (gender == null) return null; // not a noun entry

    final id = item['id']?.toString() ?? learnText; // fall back to text as id
    final word = parts.sublist(1).join(' ');
    final translation =
        (item['display_language_text'] as String? ?? '').trim();

    return Noun(
      id: id,
      word: word,
      gender: gender,
      translation: translation,
    );
  }
}
