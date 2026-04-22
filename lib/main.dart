import 'package:adhan_app/screens/dua_screen.dart';
import 'package:adhan_app/screens/hijri_calendar.dart';
import 'package:adhan_app/screens/quran_test.dart';
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
import 'screens/quran_test.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔔 INIT NOTIFICATIONS
  await NotificationService.init();
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

  // 🔥 LOAD SAVED LANGUAGE
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');

    if (langCode != null) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  // 🔥 CHANGE LANGUAGE
  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌍 CURRENT LANGUAGE
      locale: _locale,

      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('ar'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🎨 THEME
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),

      // 🔀 ROUTES (IMPORTANT)
      routes: {
        '/home': (_) => const SplashScreen(),
        // '/mosque': (_) => const MosqueMapScreen(),
        '/support': (_) => const SupportScreen(),
        '/dua': (context) => const DuaScreen(),
        '/zikr': (context) => const ZikrScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/quran-test': (_) => const QuranTestScreen(),
      },

      // 🚀 START SCREEN
       home: const SplashScreen(),
      // home: const QuranTestScreen(),
    );
  }
}