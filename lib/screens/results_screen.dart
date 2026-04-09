import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risultati')),
      body: const Center(
        child: Text(
          'Results Screen\n— coming soon —',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
