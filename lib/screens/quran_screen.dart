import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/quran_service.dart';
import 'quran_reader_screen.dart';
import '../l10n/app_localizations.dart';
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranTestScreenState();
}

class _QuranTestScreenState extends State<QuranScreen> {
  List surahs = [];

  int? lastSurah;
  String? lastTitle;
  String? lastTitleAr;

  @override
  void initState() {
    super.initState();
    load();
    loadLastRead();
  }

  Future<void> load() async {
    final data = await QuranService.loadSurahList();

    setState(() {
      surahs = data;
    });
  }

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      lastSurah = prefs.getInt('lastSurah');
      lastTitle = prefs.getString('lastTitle');
      lastTitleAr = prefs.getString('lastTitleAr');
    });
  }

  String getSurahName(Map s, String lang) {
    if (lang == 'ar') {
      return s['titleAr'] ?? '';
    }
    return s['title'] ?? '';
  }

  Widget buildContinueReadingCard(AppLocalizations loc) {
    if (lastSurah == null) return const SizedBox();

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranReaderScreen(
              surahNumber: lastSurah!,
              title: lastTitle ?? '',
              titleAr: lastTitleAr ?? '',
            ),
          ),
        );

        loadLastRead();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.white, size: 30),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.continueReading,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    lastTitle?.isNotEmpty == true
                        ? lastTitle!
                        : "${loc.surah} $lastSurah",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (lastTitleAr != null && lastTitleAr!.isNotEmpty)
                    Text(
                      lastTitleAr!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSurahCard(Map s, String lang) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranReaderScreen(
              surahNumber: int.parse(s['index'] ?? '1'),
              title: s['title'] ?? '',
              titleAr: s['titleAr'] ?? '',
            ),
          ),
        );

        loadLastRead();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Text(
                s['index'] ?? '',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getSurahName(s, lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    s['titleAr'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.quran),
      ),
      body: surahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: surahs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildContinueReadingCard(loc);
          }

          final s = surahs[index - 1] ?? {};
          return buildSurahCard(s, lang);
        },
      ),
    );
  }
}