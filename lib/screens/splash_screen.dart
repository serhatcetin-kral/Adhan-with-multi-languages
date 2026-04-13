import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_screen.dart';
import 'settings_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkFirstLaunch();
  }

  Future<void> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    bool languageSelected = prefs.getBool('language_selected') ?? false;
    bool settingsDone = prefs.getBool('settings_done') ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}