import 'package:adhan_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() =>
      _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'en';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    _loadSavedLanguage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD SAVED LANGUAGE
  // ============================================================

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage =
        prefs.getString('language') ?? 'en';

    if (!mounted) return;

    setState(() {
      selectedLanguage = savedLanguage;
    });
  }

  // ============================================================
  // CONVERT SAVED LANGUAGE CODE TO LOCALE
  // ============================================================

  Locale _localeFromCode(String code) {
    switch (code) {
      case 'pt_BR':
        return const Locale('pt', 'BR');

      case 'pt_PT':
        return const Locale('pt', 'PT');

      case 'id':
        return const Locale('id');

      case 'ms':
        return const Locale('ms');

      default:
        return Locale(code);
    }
  }

  // ============================================================
  // SELECT LANGUAGE
  // ============================================================

  void selectLanguage(String code) {
    setState(() {
      selectedLanguage = code;
    });

    // Apply language immediately
    MyApp.setLocale(
      context,
      _localeFromCode(code),
    );
  }

  // ============================================================
  // SAVE LANGUAGE AND CONTINUE
  // ============================================================

  Future<void> saveAndContinue() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'language',
      selectedLanguage,
    );

    // Language has been selected
    await prefs.setBool(
      'language_selected',
      true,
    );

    // IMPORTANT:
    // Do NOT set first_launch = false here.
    // First setup is finished only after Settings are saved.

    MyApp.setLocale(
      context,
      _localeFromCode(selectedLanguage),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // 🕌 MOSQUE ICON
                    const Icon(
                      Icons.mosque,
                      size: 80,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // WELCOME
                    Text(
                      t.welcome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // SELECT LANGUAGE
                    Text(
                      t.selectLanguage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ====================================================
                    // LANGUAGE LIST
                    // ====================================================

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildLangTile(
                              "🇺🇸 English",
                              "en",
                            ),

                            _buildLangTile(
                              "🇹🇷 Türkçe",
                              "tr",
                            ),

                            _buildLangTile(
                              "🇸🇦 العربية",
                              "ar",
                            ),

                            _buildLangTile(
                              "🇫🇷 Français",
                              "fr",
                            ),

                            _buildLangTile(
                              "🇩🇪 Deutsch",
                              "de",
                            ),

                            _buildLangTile(
                              "🇪🇸 Español",
                              "es",
                            ),

                            _buildLangTile(
                              "🇧🇷 Português (Brasil)",
                              "pt_BR",
                            ),

                            _buildLangTile(
                              "🇵🇹 Português (Portugal)",
                              "pt_PT",
                            ),

                            _buildLangTile(
                              "🇮🇳 हिन्दी",
                              "hi",
                            ),

                            _buildLangTile(
                              "🇵🇰 اردو",
                              "ur",
                            ),

                            _buildLangTile(
                              "🇷🇺 Русский",
                              "ru",
                            ),

                            _buildLangTile(
                              "🇨🇳 中文",
                              "zh",
                            ),

                            // 🇮🇩 INDONESIAN
                            _buildLangTile(
                              "🇮🇩 Bahasa Indonesia",
                              "id",
                            ),

                            // 🇲🇾 MALAY
                            _buildLangTile(
                              "🇲🇾 Bahasa Melayu",
                              "ms",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ====================================================
                    // CONTINUE BUTTON
                    // ====================================================

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.white,
                          foregroundColor:
                          Colors.black,
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          t.continueButton,
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LANGUAGE TILE
  // ============================================================

  Widget _buildLangTile(
      String text,
      String code,
      ) {
    final bool selected =
        selectedLanguage == code;

    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 300),
      margin:
      const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white
            : Colors.white.withOpacity(0.10),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? Colors.blue
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 7,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 17,
            color: selected
                ? Colors.black
                : Colors.white,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ),
        trailing: selected
            ? const Icon(
          Icons.check,
          color: Colors.blue,
        )
            : null,
        onTap: () =>
            selectLanguage(code),
      ),
    );
  }
}