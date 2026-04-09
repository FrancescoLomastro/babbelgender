import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:babbelgender/models/noun.dart';
import 'package:babbelgender/services/json_parser_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _makeJson(List<Map<String, dynamic>> vocabulary) => jsonEncode({
      'exported_at': '2026-04-04T10:00:00.000Z',
      'user': {'locale': 'it', 'learn_language': 'DEU'},
      'statistics': {
        'total': vocabulary.length,
        'due': 0,
        'health': {'weak': 0, 'medium': 0, 'strong': vocabulary.length},
      },
      'vocabulary': vocabulary,
    });

Map<String, dynamic> _item({
  required String id,
  required String learnText,
  required String displayText,
}) =>
    {
      'id': id,
      'learn_language_text': learnText,
      'display_language_text': displayText,
      'times_reviewed': 3,
      'knowledge_level': 5,
      'health': 'strong',
      'favorited': false,
      'mistakes': 0,
      'mistake_in_last_review': false,
      'speaker_role': 'f1',
      'source': 'self_study_lesson',
      'type': null,
      'grammar_type': null,
      'last_reviewed_at': null,
      'last_mistake_at': null,
      'next_review_at': '2026-05-01T00:00:00.000Z',
      'created_at': '2026-01-01T00:00:00.000Z',
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late JsonParserService parser;

  setUp(() {
    parser = JsonParserService();
  });

  group('JsonParserService — noun extraction', () {
    test('extracts masculine nouns (der)', () {
      final json = _makeJson([
        _item(id: '001', learnText: 'der Tee', displayText: 'il tè'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns.length, 1);
      expect(nouns.first.word, 'Tee');
      expect(nouns.first.gender, Gender.masculine);
      expect(nouns.first.translation, 'il tè');
    });

    test('extracts feminine nouns (die)', () {
      final json = _makeJson([
        _item(id: '002', learnText: 'die Torte', displayText: 'la torta'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns.length, 1);
      expect(nouns.first.gender, Gender.feminine);
    });

    test('extracts neuter nouns (das)', () {
      final json = _makeJson([
        _item(id: '003', learnText: 'das Fleisch', displayText: 'la carne'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns.length, 1);
      expect(nouns.first.gender, Gender.neuter);
    });

    test('filters out verbs and phrases', () {
      final json = _makeJson([
        _item(id: '004', learnText: 'Ich mag Kaffee.', displayText: 'Mi piace il caffè.'),
        _item(id: '005', learnText: 'trinken', displayText: 'bere'),
        _item(id: '006', learnText: 'gut', displayText: 'buono'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns, isEmpty);
    });

    test('handles a mixed vocabulary correctly', () {
      final json = _makeJson([
        _item(id: '101', learnText: 'der Salat',    displayText: 'l\'insalata'),
        _item(id: '102', learnText: 'die Suppe',    displayText: 'la zuppa'),
        _item(id: '103', learnText: 'das Gemüse',   displayText: 'la verdura'),
        _item(id: '104', learnText: 'Ich esse.',    displayText: 'Mangio.'),
        _item(id: '105', learnText: 'schlafen',     displayText: 'dormire'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns.length, 3);
      expect(nouns.map((n) => n.id), containsAll(['101', '102', '103']));
    });

    test('fullText returns article + word', () {
      final json = _makeJson([
        _item(id: '007', learnText: 'die Mutter', displayText: 'la madre'),
      ]);
      final noun = parser.parse(json).first;
      expect(noun.fullText, 'die Mutter');
    });

    test('handles multi-word nouns', () {
      final json = _makeJson([
        _item(id: '008', learnText: 'die ältere Schwester', displayText: 'la sorella maggiore'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns.length, 1);
      expect(nouns.first.word, 'ältere Schwester');
      expect(nouns.first.gender, Gender.feminine);
    });

    test('is case-insensitive on the article', () {
      final json = _makeJson([
        _item(id: '009', learnText: 'Der Vater', displayText: 'il padre'),
      ]);
      final nouns = parser.parse(json);
      expect(nouns.length, 1);
      expect(nouns.first.gender, Gender.masculine);
    });

    test('returns empty list for empty vocabulary', () {
      final json = _makeJson([]);
      expect(parser.parse(json), isEmpty);
    });
  });

  group('JsonParserService — error handling', () {
    test('throws FormatException on invalid JSON', () {
      expect(() => parser.parse('not json'), throwsA(isA<FormatException>()));
    });

    test('throws FormatException when vocabulary key is missing', () {
      final json = jsonEncode({'user': 'test'});
      expect(() => parser.parse(json), throwsA(isA<FormatException>()));
    });

    test('throws FormatException when top level is not an object', () {
      final json = jsonEncode([1, 2, 3]);
      expect(() => parser.parse(json), throwsA(isA<FormatException>()));
    });
  });
}
