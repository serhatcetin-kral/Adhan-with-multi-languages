import 'package:adhan_app/screens/dua_screen.dart';
import 'package:adhan_app/screens/hijri_calendar.dart';
import 'package:adhan_app/screens/quran_screen.dart';
import 'package:adhan_app/screens/settings_screen.dart';
import 'package:adhan_app/screens/zikr_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';

// 🔽 SCREENS
import 'screens/splash_screen.dart';
import 'screens/mosque_map_screen.dart';
import 'screens/support_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔔 INIT NOTIFICATIONS
  await NotificationService.init();

  // 🌍 INIT DATE FORMATTING
  await initializeDateFormatting();

  // 🔒 LOCK PORTRAIT
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // 🌍 CHANGE LANGUAGE FROM ANYWHERE
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    loadSavedLocale();
  }

  // ✅ CONVERT SAVED CODE TO LOCALE
  Locale _localeFromCode(String code) {
    switch (code) {
      case 'pt_BR':
        return const Locale('pt', 'BR');

      case 'pt_PT':
        return const Locale('pt', 'PT');

      default:
        return Locale(code);
    }
  }

  // ✅ CONVERT LOCALE TO SAVED CODE
  String _codeFromLocale(Locale locale) {
    if (locale.languageCode == 'pt') {
      if (locale.countryCode == 'BR') {
        return 'pt_BR';
      }

      if (locale.countryCode == 'PT') {
        return 'pt_PT';
      }
    }

    return locale.languageCode;
  }

  // 🔥 LOAD SAVED LANGUAGE
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language');

    if (langCode != null) {
      setState(() {
        _locale = _localeFromCode(langCode);
      });
    }
  }

  // 🔥 CHANGE LANGUAGE
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'language',
      _codeFromLocale(locale),
    );

    if (!mounted) return;

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: _locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),

      routes: {
        '/home': (_) => const SplashScreen(),
        '/dua': (context) => const DuaScreen(),
        '/zikr': (context) => const ZikrScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/quran-test': (_) => const QuranScreen(),
        '/settings': (_) => const SettingsScreen(),
      },

      home: UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(
            days: 3,
          ),
        ),
        child: const SplashScreen(),
      ),
    );
  }
}