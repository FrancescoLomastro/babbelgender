import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/noun.dart';
import '../providers/practice_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gender_drop_zone.dart';
import '../widgets/noun_card.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeProvider _practice;
  bool _initialized = false;

  // Local UI state
  bool _translationVisible = false;
  bool _isDropping = false;
  Gender? _feedbackGender;
  bool? _feedbackCorrect;

  // ── Initialization ──────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final vocab = context.read<VocabularyProvider>();
      final settings = context.read<SettingsProvider>();
      final count = settings.resolveCount(vocab.nouns.length);
      _practice = PracticeProvider(nouns: vocab.nouns.take(count).toList());
    }
  }

  @override
  void dispose() {
    _practice.dispose();
    super.dispose();
  }

  // ── Drop handler ────────────────────────────────────────────────────────────

  void _handleDrop(Gender zoneGender) {
    if (_isDropping) return;

    final correct = _practice.checkAnswer(zoneGender);

    setState(() {
      _isDropping = true;
      _feedbackGender = zoneGender;
      _feedbackCorrect = correct;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      if (correct) {
        _practice.advance();
        if (_practice.isComplete) {
          Navigator.pushReplacementNamed(
            context,
            '/results',
            arguments: _practice.buildResult(),
          );
          return;
        }
      }

      setState(() {
        _isDropping = false;
        _feedbackGender = null;
        _feedbackCorrect = false;
        _translationVisible = false;
      });
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _practice,
      builder: (context, _) {
        final noun = _practice.currentNoun;

        // Safety net while completing (shouldn't be visible)
        if (noun == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Abbandona sessione',
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('${_practice.currentPosition} / ${_practice.total}'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // ── Progress bar ──────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _practice.currentPosition / _practice.total,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Noun card area ────────────────────────────────
                  Expanded(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        // hide card while correct-answer feedback plays
                        opacity: (_isDropping && _feedbackCorrect == true)
                            ? 0.0
                            : (_isDropping ? 0.45 : 1.0),
                        child: NounCard(
                          key: ValueKey(noun.id),
                          noun: noun,
                          translationVisible: _translationVisible,
                          draggable: !_isDropping,
                          onTranslationToggle: () => setState(
                            () => _translationVisible = !_translationVisible,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Drop zones ────────────────────────────────────
                  _DropZoneLayout(
                    feedbackGender: _feedbackGender,
                    feedbackCorrect: _feedbackCorrect,
                    onDrop: _handleDrop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Drop zone layout ──────────────────────────────────────────────────────────

class _DropZoneLayout extends StatelessWidget {
  final Gender? feedbackGender;
  final bool? feedbackCorrect;
  final void Function(Gender) onDrop;

  const _DropZoneLayout({
    required this.feedbackGender,
    required this.feedbackCorrect,
    required this.onDrop,
  });

  bool? _feedbackFor(Gender g) =>
      feedbackGender == g ? feedbackCorrect : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // der (left)  |  die (right)
        Row(
          children: [
            Expanded(
              child: GenderDropZone(
                gender: Gender.masculine,
                onDrop: onDrop,
                feedbackResult: _feedbackFor(Gender.masculine),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GenderDropZone(
                gender: Gender.feminine,
                onDrop: onDrop,
                feedbackResult: _feedbackFor(Gender.feminine),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // das (center bottom)
        Center(
          child: SizedBox(
            width: 180,
            child: GenderDropZone(
              gender: Gender.neuter,
              onDrop: onDrop,
              feedbackResult: _feedbackFor(Gender.neuter),
            ),
          ),
        ),
      ],
    );
  }
}
