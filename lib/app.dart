import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/settings_providers.dart';
import 'features/home/screens/home_screen.dart';

/// Widget racine de l'application Kana SRS.
/// Root widget for Kana SRS application.
class KanaSrsApp extends ConsumerWidget {
  const KanaSrsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Kana SRS - Japonais Fluide',
      debugShowCheckedModeBanner: false,

      // Thème clair Material 3
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4), // Violet japonais
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'NotoSansJP',
      ),

      // Thème sombre Material 3
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'NotoSansJP',
      ),

      themeMode: themeMode,

      // Localisation fr/en/ja
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ja'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('fr'),

      home: const HomeScreen(),
    );
  }
}
