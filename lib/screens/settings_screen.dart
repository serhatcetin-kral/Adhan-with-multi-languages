import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../l10n/app_localizations.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String selectedLanguage = 'en';
  String calculationMethod = 'MWL';
  String madhhab = 'hanafi';

  bool notificationsEnabled = true;

  int fajrOffset = 0;
  int dhuhrOffset = 0;
  int asrOffset = 0;
  int maghribOffset = 0;
  int ishaOffset = 0;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedLanguage = prefs.getString('language') ?? 'en';
      calculationMethod = prefs.getString('method') ?? 'MWL';
      madhhab = prefs.getString('madhhab') ?? 'hanafi';

      notificationsEnabled = prefs.getBool('notifications') ?? true;

      fajrOffset = prefs.getInt('fajrOffset') ?? 0;
      dhuhrOffset = prefs.getInt('dhuhrOffset') ?? 0;
      asrOffset = prefs.getInt('asrOffset') ?? 0;
      maghribOffset = prefs.getInt('maghribOffset') ?? 0;
      ishaOffset = prefs.getInt('ishaOffset') ?? 0;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language', selectedLanguage);
    await prefs.setString('method', calculationMethod);
    await prefs.setString('madhhab', madhhab);

    await prefs.setBool('notifications', notificationsEnabled);

    await prefs.setInt('fajrOffset', fajrOffset);
    await prefs.setInt('dhuhrOffset', dhuhrOffset);
    await prefs.setInt('asrOffset', asrOffset);
    await prefs.setInt('maghribOffset', maghribOffset);
    await prefs.setInt('ishaOffset', ishaOffset);

    // IMPORTANT: mark first launch done
    await prefs.setBool('first_launch', false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void changeLanguage(String code) {
    setState(() {
      selectedLanguage = code;
    });

    MyApp.setLocale(context, Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // LANGUAGE
            ListTile(title: Text(loc.language)),
            ListTile(
              title: const Text("English"),
              onTap: () => changeLanguage('en'),
            ),
            ListTile(
              title: const Text("Türkçe"),
              onTap: () => changeLanguage('tr'),
            ),
            ListTile(
              title: const Text("العربية"),
              onTap: () => changeLanguage('ar'),
            ),

            const Divider(),

            // CALCULATION METHOD
            ListTile(title: Text(loc.calculationMethod)),
            DropdownButton<String>(
              value: calculationMethod,
              items: const [
                DropdownMenuItem(value: 'MWL', child: Text("MWL")),
                DropdownMenuItem(value: 'ISNA', child: Text("ISNA")),
                DropdownMenuItem(value: 'Egypt', child: Text("Egypt")),
                DropdownMenuItem(value: 'Makkah', child: Text("Makkah")),
                DropdownMenuItem(value: 'Karachi', child: Text("Karachi")),
                DropdownMenuItem(value: 'Turkey', child: Text("Turkey")),
              ],
              onChanged: (val) {
                setState(() {
                  calculationMethod = val!;
                });
              },
            ),

            const Divider(),

            // MADHHAB
            ListTile(title: Text(loc.madhhab)),
            DropdownButton<String>(
              value: madhhab,
              items: const [
                DropdownMenuItem(value: 'hanafi', child: Text("Hanafi")),
                DropdownMenuItem(value: 'shafi', child: Text("Shafi")),
              ],
              onChanged: (val) {
                setState(() {
                  madhhab = val!;
                });
              },
            ),

            const Divider(),

            // NOTIFICATIONS
            SwitchListTile(
              title: Text(loc.enableNotifications),
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
              },
            ),

            const Divider(),

            // SAVE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: saveSettings,
                child: Text(loc.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}