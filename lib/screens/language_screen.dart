import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'settings_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void selectLanguage(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language', code);
    await prefs.setBool('language_selected', true);

    MyApp.setLocale(context, Locale(code));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Language")),
      body: Column(
        children: [
          ListTile(title: const Text("English"), onTap: () => selectLanguage(context, 'en')),
          ListTile(title: const Text("Türkçe"), onTap: () => selectLanguage(context, 'tr')),
          ListTile(title: const Text("العربية"), onTap: () => selectLanguage(context, 'ar')),
        ],
      ),
    );
  }
}