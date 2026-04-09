import 'package:flutter/material.dart';
import '../models/noun.dart';
import '../theme/app_theme.dart';

class GenderDropZone extends StatelessWidget {
  final Gender gender;
  final void Function(Gender) onDrop;

  /// null = idle, true = correct flash, false = wrong flash
  final bool? feedbackResult;

  const GenderDropZone({
    super.key,
    required this.gender,
    required this.onDrop,
    this.feedbackResult,
  });

  // Neutral color for idle and hover states — no gender hint.
  static const Color _neutralColor = Color(0xFF607D8B); // blue-grey

  String get _icon {
    switch (gender) {
      case Gender.masculine:
        return '♂';
      case Gender.feminine:
        return '♀';
      case Gender.neuter:
        return '⚥';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Noun>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (_) => onDrop(gender),
      builder: (context, candidateData, _) {
        final isHovering = candidateData.isNotEmpty;

        // Priority: feedback > hover > idle
        final Color activeColor;
        final double bgOpacity;
        final double borderOpacity;
        final double borderWidth;

        if (feedbackResult != null) {
          activeColor =
              feedbackResult! ? AppTheme.correctColor : AppTheme.wrongColor;
          bgOpacity = 0.22;
          borderOpacity = 1.0;
          borderWidth = 2.5;
        } else if (isHovering) {
          activeColor = _neutralColor;
          bgOpacity = 0.18;
          borderOpacity = 0.85;
          borderWidth = 2.5;
        } else {
          activeColor = _neutralColor;
          bgOpacity = 0.08;
          borderOpacity = 0.40;
          borderWidth = 1.5;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(bgOpacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activeColor.withOpacity(borderOpacity),
              width: borderWidth,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _icon,
                  style: TextStyle(
                    fontSize: 22,
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gender.article.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
