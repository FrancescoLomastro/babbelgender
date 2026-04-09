import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsProvider();
  await settings.load();
  runApp(BabbelGenderApp(settings: settings));
}

class BabbelGenderApp extends StatelessWidget {
  final SettingsProvider settings;

  const BabbelGenderApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
