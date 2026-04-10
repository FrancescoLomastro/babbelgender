import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/results_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final settings = SettingsProvider();
  final vocabulary = VocabularyProvider();
  await Future.wait([
    settings.load(),
    vocabulary.loadFromPrefs(),
  ]);

  FlutterNativeSplash.remove();
  runApp(BabbelGenderApp(settings: settings, vocabulary: vocabulary));
}

class BabbelGenderApp extends StatelessWidget {
  final SettingsProvider settings;
  final VocabularyProvider vocabulary;

  const BabbelGenderApp({super.key, required this.settings, required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: vocabulary),
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
