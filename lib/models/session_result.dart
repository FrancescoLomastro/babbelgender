import 'noun.dart';

/// Tracks the result of a single noun during a practice session.
class NounAttempt {
  final Noun noun;

  /// Number of wrong answers before the user got it right.
  int mistakes;

  NounAttempt({required this.noun, this.mistakes = 0});

  bool get correctFirstTry => mistakes == 0;
}

/// Aggregated statistics for a completed practice session.
class SessionResult {
  final List<NounAttempt> attempts;
  final Duration duration;

  const SessionResult({
    required this.attempts,
    required this.duration,
  });

  /// Total nouns practised in the session.
  int get total => attempts.length;

  /// Nouns answered correctly on the very first attempt.
  int get correctFirstTryCount =>
      attempts.where((a) => a.correctFirstTry).length;

  /// Sum of all wrong answers across the session.
  int get totalMistakes =>
      attempts.fold(0, (sum, a) => sum + a.mistakes);

  /// Nouns on which the user made at least one mistake.
  List<NounAttempt> get withMistakes =>
      attempts.where((a) => !a.correctFirstTry).toList();

  /// Percentage of nouns answered correctly on the first try (0–100).
  double get accuracyPercent =>
      total == 0 ? 0 : (correctFirstTryCount / total) * 100;
}
