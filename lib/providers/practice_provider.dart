import 'package:flutter/foundation.dart';
import '../models/noun.dart';
import '../models/session_result.dart';

/// Manages the state of a single practice session.
/// Created fresh for every session; lives only in PracticeScreen.
class PracticeProvider extends ChangeNotifier {
  final List<Noun> _queue;
  final List<NounAttempt> _attempts;
  final DateTime _startTime;

  int _currentIndex = 0;
  bool _isComplete = false;

  PracticeProvider({required List<Noun> nouns})
      : _queue = (List<Noun>.from(nouns)..shuffle()),
        _attempts = [],
        _startTime = DateTime.now() {
    _attempts.addAll(_queue.map((n) => NounAttempt(noun: n)));
  }

  Noun? get currentNoun => _isComplete ? null : _queue[_currentIndex];

  /// 1-based progress counter for display (e.g. "5 / 20").
  int get currentPosition => _currentIndex + 1;

  int get total => _queue.length;
  bool get isComplete => _isComplete;

  /// Checks [chosen] against the current noun's gender.
  /// Increments mistakes on wrong answer and notifies listeners.
  /// Returns true if the answer is correct.
  bool checkAnswer(Gender chosen) {
    if (_isComplete) return false;
    final isCorrect = chosen == _queue[_currentIndex].gender;
    if (!isCorrect) {
      _attempts[_currentIndex].mistakes++;
      notifyListeners();
    }
    return isCorrect;
  }

  /// Advances to the next noun. Must be called only after a correct answer.
  void advance() {
    if (_isComplete) return;
    _currentIndex++;
    if (_currentIndex >= _queue.length) _isComplete = true;
    notifyListeners();
  }

  SessionResult buildResult() {
    return SessionResult(
      attempts: List.unmodifiable(_attempts),
      duration: DateTime.now().difference(_startTime),
    );
  }
}
