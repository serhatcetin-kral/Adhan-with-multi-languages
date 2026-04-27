import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../l10n/app_localizations.dart';
import 'main_screen.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String selectedLanguage = 'en';
  String calculationMethod = 'ISNA';
  String madhhab = 'shafi';

  bool notificationsEnabled = true;
  bool adhanEnabled = true;

  int fajrOffset = 0;
  int dhuhrOffset = 0;
  int asrOffset = 0;
  int maghribOffset = 0;
  int ishaOffset = 0;

  final List<String> methods = [
    'MWL', 'ISNA', 'Egypt', 'Makkah', 'Karachi', 'Turkey'
  ];

  final List<String> madhhabs = [
    'hanafi', 'shafi'
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMethod = prefs.getString('method');
    final savedMadhhab = prefs.getString('madhhab');
    final savedLang = prefs.getString('language');

    if (!mounted) return;

    setState(() {
      selectedLanguage = ['en', 'tr', 'ar'].contains(savedLang)
          ? savedLang!
          : 'en';

      calculationMethod = methods.contains(savedMethod)
          ? savedMethod!
          : 'ISNA';

      madhhab = madhhabs.contains(savedMadhhab)
          ? savedMadhhab!
          : 'shafi';

      notificationsEnabled = prefs.getBool('notifications') ?? true;
      adhanEnabled = prefs.getBool('adhan') ?? true;

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
    await prefs.setBool('adhan', adhanEnabled);

    await prefs.setInt('fajrOffset', fajrOffset);
    await prefs.setInt('dhuhrOffset', dhuhrOffset);
    await prefs.setInt('asrOffset', asrOffset);
    await prefs.setInt('maghribOffset', maghribOffset);
    await prefs.setInt('ishaOffset', ishaOffset);

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

  String getMethodLabel(String method) {
    switch (method) {
      case 'MWL':
        return "MWL (Muslim World League)";
      case 'ISNA':
        return "ISNA (North America)";
      case 'Egypt':
        return "Egypt (Egyptian Authority)";
      case 'Makkah':
        return "Makkah (Umm Al-Qura)";
      case 'Karachi':
        return "Karachi (University of Karachi)";
      case 'Turkey':
        return "Turkey (Diyanet)";
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // 🌐 LANGUAGE
          _buildSectionCard(
            title: loc.language,
            icon: Icons.language,
            children: [
              _buildSimpleItem("English", () => changeLanguage('en')),
              _buildSimpleItem("Türkçe", () => changeLanguage('tr')),
              _buildSimpleItem("العربية", () => changeLanguage('ar')),
            ],
          ),

          // ⚙️ CALCULATION METHOD
          _buildSectionCard(
            title: loc.calculationMethod,
            icon: Icons.calculate,
            children: [
              DropdownButton<String>(
                value: calculationMethod,
                isExpanded: true,
                items: methods.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(getMethodLabel(m)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    calculationMethod = val;
                  });
                },
              ),
            ],
          ),

          // 🕌 MADHHAB
          _buildSectionCard(
            title: loc.madhhab,
            icon: Icons.menu_book,
            children: [
              DropdownButton<String>(
                value: madhhab,
                isExpanded: true,
                items: madhhabs.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m == 'hanafi' ? "Hanafi" : "Shafi / Hanbali / Maliki"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    madhhab = val;
                  });
                },
              ),
            ],
          ),

          // 🔔 NOTIFICATIONS
          _buildSectionCard(
            title: loc.notifications,
            icon: Icons.notifications,
            children: [
              SwitchListTile(
                title: Text(loc.notifications),
                value: notificationsEnabled,
                onChanged: (val) async {
                  setState(() {
                    notificationsEnabled = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('notifications', val);

                  if (!val) {
                    await NotificationService.cancelAll();
                  }
                },
              ),

              SwitchListTile(
                title: Text(loc.adhanSound),
                value: adhanEnabled,
                onChanged: (val) async {
                  setState(() {
                    adhanEnabled = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('adhan', val);
                },
              ),
            ],
          ),

          // ⏱ OFFSET
          _buildSectionCard(
            title: loc.offsetSettings,
            icon: Icons.access_time,
            children: [
              buildOffsetTile(loc.fajrOffset, fajrOffset, (v) => setState(() => fajrOffset = v)),
              buildOffsetTile(loc.dhuhrOffset, dhuhrOffset, (v) => setState(() => dhuhrOffset = v)),
              buildOffsetTile(loc.asrOffset, asrOffset, (v) => setState(() => asrOffset = v)),
              buildOffsetTile(loc.maghribOffset, maghribOffset, (v) => setState(() => maghribOffset = v)),
              buildOffsetTile(loc.ishaOffset, ishaOffset, (v) => setState(() => ishaOffset = v)),
            ],
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: saveSettings,
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleItem(String text, VoidCallback onTap) {
    return ListTile(
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget buildOffsetTile(String title, int value, Function(int) onChanged) {
    final loc = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (value > -30) onChanged(value - 1);
            },
          ),
          Text("$value ${loc.minutesShort}"),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (value < 30) onChanged(value + 1);
            },
          ),
        ],
      ),
    );
  }
}