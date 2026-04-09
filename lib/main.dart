import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const BabbelGenderApp());
}

class BabbelGenderApp extends StatelessWidget {
  const BabbelGenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabbelGender',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/practice': (_) => const PracticeScreen(),
        '/results': (_) => const ResultsScreen(),
      },
    );
  }
}
