import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/noun.dart';
import '../providers/practice_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gender_drop_zone.dart';
import '../widgets/noun_card.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  late final PracticeProvider _practice;
  bool _initialized = false;

  // Local UI state
  bool _translationVisible = false;
  bool _isDropping = false;
  Gender? _feedbackGender;
  bool? _feedbackCorrect;

  // ── Animation controllers ───────────────────────────────────────────────────

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim; // horizontal offset (px)

  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim; // scale factor

  @override
  void initState() {
    super.initState();

    // Shake: left-right oscillation for wrong answers
    _shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -14.0, end: 14.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 14.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    // Bounce: scale up then spring back for correct answers
    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  // ── Initialization ──────────────────────────────────────────────────────────

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final vocab = context.read<VocabularyProvider>();
      final settings = context.read<SettingsProvider>();
      final count = settings.resolveCount(vocab.nouns.length);
      // Shuffle the full pool first so the selected subset is random each session.
      final pool = List<Noun>.from(vocab.nouns)..shuffle();
      _practice = PracticeProvider(nouns: pool.take(count).toList());
    }
  }

  @override
  void dispose() {
    _practice.dispose();
    _shakeCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  // ── Drop handler ────────────────────────────────────────────────────────────

  void _handleDrop(Gender zoneGender) {
    if (_isDropping) return;

    final correct = _practice.checkAnswer(zoneGender);

    if (correct) {
      SoundService.playCorrect();
      _bounceCtrl.forward(from: 0);
    } else {
      SoundService.playWrong();
      _shakeCtrl.forward(from: 0);
    }

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
        _feedbackCorrect = null; // ← null, not false
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

                  const SizedBox(height: 16),

                  // ── Noun card with animations ─────────────────────
                  Center(
                    child: AnimatedBuilder(
                        animation:
                            Listenable.merge([_shakeCtrl, _bounceCtrl]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnim.value, 0),
                            child: Transform.scale(
                              scale: _bounceAnim.value,
                              child: child,
                            ),
                          );
                        },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity:
                              (_isDropping && _feedbackCorrect == true)
                                  ? 0.0
                                  : (_isDropping ? 0.40 : 1.0),
                          child: NounCard(
                            key: ValueKey(noun.id),
                            noun: noun,
                            translationVisible: _translationVisible,
                            draggable: !_isDropping,
                            onTranslationToggle: () => setState(
                              () =>
                                  _translationVisible = !_translationVisible,
                            ),
                          ),
                        ),
                      ),
                  ),

                  const SizedBox(height: 16),

                  // ── Drop zones — fill remaining height ────────────
                  Expanded(
                    child: _DropZoneLayout(
                      feedbackGender: _feedbackGender,
                      feedbackCorrect: _feedbackCorrect,
                      onDrop: _handleDrop,
                    ),
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
        Expanded(
          child: GenderDropZone(
            gender: Gender.masculine,
            onDrop: onDrop,
            feedbackResult: _feedbackFor(Gender.masculine),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GenderDropZone(
            gender: Gender.feminine,
            onDrop: onDrop,
            feedbackResult: _feedbackFor(Gender.feminine),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GenderDropZone(
            gender: Gender.neuter,
            onDrop: onDrop,
            feedbackResult: _feedbackFor(Gender.neuter),
          ),
        ),
      ],
    );
  }
}
