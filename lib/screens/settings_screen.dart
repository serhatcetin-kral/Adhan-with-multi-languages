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

  // These are INTERNAL values.
  // Do not translate/change these codes.
  final List<String> methods = [
    'MWL',
    'ISNA',
    'Egypt',
    'Makkah',
    'Karachi',
    'Turkey',
  ];

  // These are INTERNAL values.
  // Do not translate/change these codes.
  final List<String> madhhabs = [
    'hanafi',
    'shafi',
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      selectedLanguage = prefs.getString('language') ?? 'en';
      calculationMethod = prefs.getString('method') ?? 'ISNA';
      madhhab = prefs.getString('madhhab') ?? 'shafi';

      notificationsEnabled = prefs.getBool('notifications') ?? true;
      adhanEnabled = prefs.getBool('adhan') ?? true;

      fajrOffset = prefs.getInt('fajrOffset') ?? 0;
      dhuhrOffset = prefs.getInt('dhuhrOffset') ?? 0;
      asrOffset = prefs.getInt('asrOffset') ?? 0;
      maghribOffset = prefs.getInt('maghribOffset') ?? 0;
      ishaOffset = prefs.getInt('ishaOffset') ?? 0;
    });
  }

  // ============================================================
  // SAVE SETTINGS
  // ============================================================

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

    // First setup is now complete.
    await prefs.setBool('first_launch', false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.save,
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  // ============================================================
  // LANGUAGE / LOCALE
  // ============================================================

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

  void changeLanguage(String code) {
    setState(() {
      selectedLanguage = code;
    });

    MyApp.setLocale(
      context,
      _localeFromCode(code),
    );
  }

  // ============================================================
  // LOCALIZED CALCULATION METHOD LABELS
  // ============================================================

  String getMethodLabel(
      AppLocalizations loc,
      String method,
      ) {
    switch (method) {
      case 'MWL':
        return loc.methodMWL;

      case 'ISNA':
        return loc.methodISNA;

      case 'Egypt':
        return loc.methodEgypt;

      case 'Makkah':
        return loc.methodMakkah;

      case 'Karachi':
        return loc.methodKarachi;

      case 'Turkey':
        return loc.methodTurkey;

      default:
        return method;
    }
  }

  // ============================================================
  // LOCALIZED MADHHAB LABELS
  // ============================================================

  String getMadhhabLabel(
      AppLocalizations loc,
      String value,
      ) {
    switch (value) {
      case 'hanafi':
        return loc.hanafi;

      case 'shafi':
        return loc.shafi;

      default:
        return value;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          loc.settings,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ========================================================
      // BACKGROUND
      // ========================================================

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // =================================================
              // LANGUAGE
              // =================================================

              _section(
                loc.language,
                Icons.language,
                [
                  _tile(
                    "🇺🇸 English",
                    "en",
                  ),
                  _tile(
                    "🇹🇷 Türkçe",
                    "tr",
                  ),
                  _tile(
                    "🇸🇦 العربية",
                    "ar",
                  ),
                  _tile(
                    "🇫🇷 Français",
                    "fr",
                  ),
                  _tile(
                    "🇩🇪 Deutsch",
                    "de",
                  ),
                  _tile(
                    "🇪🇸 Español",
                    "es",
                  ),

                  // Portuguese - Brazil
                  _tile(
                    "🇧🇷 Português (Brasil)",
                    "pt_BR",
                  ),

                  // Portuguese - Portugal
                  _tile(
                    "🇵🇹 Português (Portugal)",
                    "pt_PT",
                  ),

                  _tile(
                    "🇮🇳 हिन्दी",
                    "hi",
                  ),
                  _tile(
                    "🇵🇰 اردو",
                    "ur",
                  ),
                  _tile(
                    "🇷🇺 Русский",
                    "ru",
                  ),
                  _tile(
                    "🇨🇳 中文",
                    "zh",
                  ),

                  // Indonesian
                  _tile(
                    "🇮🇩 Bahasa Indonesia",
                    "id",
                  ),

                  // Malay
                  _tile(
                    "🇲🇾 Bahasa Melayu",
                    "ms",
                  ),
                ],
              ),

              // =================================================
              // CALCULATION METHOD
              // =================================================

              _section(
                loc.calculationMethod,
                Icons.calculate,
                [
                  DropdownButton<String>(
                    value: calculationMethod,
                    isExpanded: true,
                    items: methods.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          getMethodLabel(
                            loc,
                            m,
                          ),
                        ),
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

              // =================================================
              // MADHHAB
              // =================================================

              _section(
                loc.madhhab,
                Icons.menu_book,
                [
                  DropdownButton<String>(
                    value: madhhab,
                    isExpanded: true,
                    items: madhhabs.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          getMadhhabLabel(
                            loc,
                            m,
                          ),
                        ),
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

              // =================================================
              // NOTIFICATIONS
              // =================================================

              _section(
                loc.notifications,
                Icons.notifications,
                [
                  SwitchListTile(
                    title: Text(
                      loc.notifications,
                    ),
                    value: notificationsEnabled,
                    onChanged: (val) async {
                      setState(() {
                        notificationsEnabled = val;
                      });

                      final prefs =
                      await SharedPreferences.getInstance();

                      await prefs.setBool(
                        'notifications',
                        val,
                      );

                      if (!val) {
                        await NotificationService.cancelAll();
                      } else {
                        // TODO:
                        // Reschedule prayer notifications here.
                      }
                    },
                  ),

                  SwitchListTile(
                    title: Text(
                      loc.adhanSound,
                    ),
                    value: adhanEnabled,
                    onChanged: notificationsEnabled
                        ? (val) async {
                      setState(() {
                        adhanEnabled = val;
                      });

                      final prefs =
                      await SharedPreferences.getInstance();

                      await prefs.setBool(
                        'adhan',
                        val,
                      );
                    }
                        : null,
                  ),
                ],
              ),

              // =================================================
              // PRAYER TIME OFFSETS
              // =================================================

              _section(
                loc.offsetSettings,
                Icons.access_time,
                [
                  _offset(
                    loc.fajrOffset,
                    fajrOffset,
                        (v) {
                      setState(() {
                        fajrOffset = v;
                      });
                    },
                  ),
                  _offset(
                    loc.dhuhrOffset,
                    dhuhrOffset,
                        (v) {
                      setState(() {
                        dhuhrOffset = v;
                      });
                    },
                  ),
                  _offset(
                    loc.asrOffset,
                    asrOffset,
                        (v) {
                      setState(() {
                        asrOffset = v;
                      });
                    },
                  ),
                  _offset(
                    loc.maghribOffset,
                    maghribOffset,
                        (v) {
                      setState(() {
                        maghribOffset = v;
                      });
                    },
                  ),
                  _offset(
                    loc.ishaOffset,
                    ishaOffset,
                        (v) {
                      setState(() {
                        ishaOffset = v;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================================
              // SAVE BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: Text(
                    loc.save,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _section(
      String title,
      IconData icon,
      List<Widget> children,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.95,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.teal,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LANGUAGE TILE
  // ============================================================

  Widget _tile(
      String text,
      String code,
      ) {
    final isSelected =
        selectedLanguage == code;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 250,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.teal.withOpacity(
          0.12,
        )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.language,
          color: isSelected
              ? Colors.teal
              : Colors.grey,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(
          Icons.check_circle,
          color: Colors.teal,
        )
            : null,
        onTap: () {
          changeLanguage(
            code,
          );
        },
      ),
    );
  }

  // ============================================================
  // PRAYER OFFSET
  // ============================================================

  Widget _offset(
      String title,
      int value,
      Function(int) onChanged,
      ) {
    final loc =
    AppLocalizations.of(context)!;

    return ListTile(
      title: Text(
        title,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove,
            ),
            onPressed: () {
              if (value > -30) {
                onChanged(
                  value - 1,
                );
              }
            },
          ),
          Text(
            "$value ${loc.minutesShort}",
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {
              if (value < 30) {
                onChanged(
                  value + 1,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}