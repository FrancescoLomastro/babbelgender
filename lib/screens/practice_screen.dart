import 'package:flutter/material.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pratica')),
      body: const Center(
        child: Text(
          'Practice Screen\n— coming soon —',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
