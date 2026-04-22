import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quran_service.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String title;
  final String titleAr;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.title,
    required this.titleAr,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  List ayahs = [];

  @override
  void initState() {
    super.initState();
    loadSurah();
  }

  Future<void> loadSurah() async {
    try {
      final data = await QuranService.loadSurah(widget.surahNumber);

      final verseMap = data['verse'] as Map<String, dynamic>;

      setState(() {
        ayahs = verseMap.entries.toList(); // ✅ IMPORTANT
      });

    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> saveLastRead(int ayahIndex) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('last_surah', widget.surahNumber);
    await prefs.setInt('last_ayah', ayahIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: ayahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: ayahs.length,
          itemBuilder: (context, index) {
            final entry = ayahs[index];

            final verseKey = entry.key;     // "verse_1"
            final verseText = entry.value;  // actual Arabic text

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  // 🔢 AYAH NUMBER
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text("${index + 1}"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 📖 TEXT
                  Text(
                    verseText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}