import 'package:flutter/material.dart';
import '../models/session_result.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as SessionResult?;

    return Scaffold(
      appBar: AppBar(title: const Text('Risultati')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: AppTheme.correctColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Sessione completata!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              if (result != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${result.correctFirstTryCount} / ${result.total} al primo tentativo',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (_) => false,
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Torna alla Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
