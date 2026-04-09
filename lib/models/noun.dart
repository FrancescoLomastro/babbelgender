/// Grammatical gender of a German noun.
enum Gender {
  masculine, // der
  feminine,  // die
  neuter,    // das
}

extension GenderExtension on Gender {
  /// The definite article for this gender.
  String get article {
    switch (this) {
      case Gender.masculine:
        return 'der';
      case Gender.feminine:
        return 'die';
      case Gender.neuter:
        return 'das';
    }
  }

  /// Human-readable Italian label.
  String get label {
    switch (this) {
      case Gender.masculine:
        return 'Maschile';
      case Gender.feminine:
        return 'Femminile';
      case Gender.neuter:
        return 'Neutro';
    }
  }
}

/// A German noun extracted from a Babbel vocabulary export.
class Noun {
  final String id;

  /// The noun without its article, e.g. "Tee".
  final String word;

  /// Grammatical gender.
  final Gender gender;

  /// Translation in the user's native language, e.g. "il tè".
  final String translation;

  const Noun({
    required this.id,
    required this.word,
    required this.gender,
    required this.translation,
  });

  /// Full German form: article + noun, e.g. "der Tee".
  String get fullText => '${gender.article} $word';

  @override
  String toString() => 'Noun($fullText → $translation)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Noun && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
