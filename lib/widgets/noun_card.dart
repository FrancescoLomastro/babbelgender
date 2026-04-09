import 'package:flutter/material.dart';
import '../models/noun.dart';
import '../theme/app_theme.dart';

class NounCard extends StatelessWidget {
  final Noun noun;
  final bool translationVisible;
  final bool draggable;
  final VoidCallback onTranslationToggle;

  const NounCard({
    super.key,
    required this.noun,
    required this.translationVisible,
    required this.onTranslationToggle,
    this.draggable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardFace = Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // German word — first word in warm orange, rest in dark
            _NounWordText(word: noun.word, baseStyle: theme.textTheme.displaySmall),
            const SizedBox(height: 20),
            // Translation toggle
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTranslationToggle,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: translationVisible
                    ? Text(
                        noun.translation.isEmpty ? '—' : noun.translation,
                        key: const ValueKey('shown'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF333333),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Row(
                        key: const ValueKey('hidden'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 15,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'mostra traduzione',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!draggable) return cardFace;

    return Draggable<Noun>(
      data: noun,
      feedback: Transform.scale(
        scale: 1.05,
        child: Opacity(opacity: 0.90, child: cardFace),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: cardFace),
      child: cardFace,
    );
  }
}

// ---------------------------------------------------------------------------
// Helper: colors first word in warm orange, remaining words in dark
// ---------------------------------------------------------------------------

class _NounWordText extends StatelessWidget {
  final String word;
  final TextStyle? baseStyle;

  const _NounWordText({required this.word, this.baseStyle});

  static const Color _highlightColor = Color(0xFFF57C00); // warm orange
  static const Color _restColor = Color(0xFF1A1A2E);       // near-black

  @override
  Widget build(BuildContext context) {
    final style = baseStyle?.copyWith(fontWeight: FontWeight.w800) ??
        const TextStyle(fontWeight: FontWeight.w800);

    final parts = word.split(' ');

    // Find the index of the first word that starts with an uppercase letter
    // (in German, nouns are always capitalized — that's the target word).
    final highlightIndex = parts.indexWhere(
      (p) => p.isNotEmpty && p[0] == p[0].toUpperCase() && p[0] != p[0].toLowerCase(),
    );

    return Text.rich(
      TextSpan(
        children: parts.asMap().entries.map((entry) {
          final i = entry.key;
          final part = entry.value;
          final isHighlighted = i == highlightIndex;
          return TextSpan(
            text: i == 0 ? part : ' $part',
            style: style.copyWith(
              color: isHighlighted ? _highlightColor : _restColor,
            ),
          );
        }).toList(),
      ),
      textAlign: TextAlign.center,
    );
  }
}
