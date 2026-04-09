import 'package:flutter/material.dart';
import '../models/noun.dart';
import '../models/session_result.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Color _genderColor(Gender g) {
    switch (g) {
      case Gender.masculine:
        return AppTheme.masculineColor;
      case Gender.feminine:
        return AppTheme.feminineColor;
      case Gender.neuter:
        return AppTheme.neuterColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as SessionResult?;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Risultati')),
        body: const Center(child: Text('Nessun risultato disponibile.')),
      );
    }

    final accuracy = result.accuracyPercent;
    final mistakeList = result.withMistakes;

    return Scaffold(
      appBar: AppBar(title: const Text('Risultati')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Accuracy ring + headline ---
              _AccuracyRing(accuracy: accuracy),
              const SizedBox(height: 28),

              // --- Stats row ---
              _StatsRow(result: result),
              const SizedBox(height: 28),

              // --- Mistakes list (only when there are any) ---
              if (mistakeList.isNotEmpty) ...[
                Text(
                  'Sostantivi con errori',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...mistakeList.map(
                  (attempt) => _MistakeCard(
                    attempt: attempt,
                    genderColor: _genderColor(attempt.noun.gender),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // --- Home button ---
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (_) => false,
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Torna alla Home'),
              ),

              const SizedBox(height: 8),

              // --- Practice again button ---
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/practice',
                  (_) => false,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Pratica ancora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accuracy ring widget
// ---------------------------------------------------------------------------

class _AccuracyRing extends StatelessWidget {
  final double accuracy;

  const _AccuracyRing({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final Color ringColor = accuracy >= 80
        ? AppTheme.correctColor
        : accuracy >= 50
            ? const Color(0xFFFFA726) // orange
            : AppTheme.wrongColor;

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: accuracy / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${accuracy.round()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: ringColor,
                    ),
                  ),
                  Text(
                    'precisione',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _headline(accuracy),
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _headline(double pct) {
    if (pct == 100) return 'Perfetto!';
    if (pct >= 80) return 'Ottimo lavoro!';
    if (pct >= 50) return 'Buon tentativo!';
    return 'Continua a praticare!';
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final SessionResult result;

  const _StatsRow({required this.result});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          icon: Icons.check_circle_rounded,
          color: AppTheme.correctColor,
          value: '${result.correctFirstTryCount}/${result.total}',
          label: 'Al primo\ntentativo',
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.close_rounded,
          color: AppTheme.wrongColor,
          value: '${result.totalMistakes}',
          label: 'Errori\ntotali',
        ),
        const SizedBox(width: 12),
        _StatTile(
          icon: Icons.timer_rounded,
          color: AppTheme.primaryColor,
          value: _formatDuration(result.duration),
          label: 'Durata\nsessione',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mistake card
// ---------------------------------------------------------------------------

class _MistakeCard extends StatelessWidget {
  final NounAttempt attempt;
  final Color genderColor;

  const _MistakeCard({
    required this.attempt,
    required this.genderColor,
  });

  @override
  Widget build(BuildContext context) {
    final article = attempt.noun.gender.article;
    final word = attempt.noun.word;
    final translation = attempt.noun.translation;
    final mistakes = attempt.mistakes;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: genderColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colored article badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: genderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              article,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Noun + translation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  translation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Mistake count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.wrongColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppTheme.wrongColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '$mistakes',
                  style: const TextStyle(
                    color: AppTheme.wrongColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
