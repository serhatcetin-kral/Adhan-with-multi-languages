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
        backgroundColor: Colors.green,
        title: Column(
          children: [
            Text(widget.title),
            Text(
              widget.titleAr,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),

      body: ayahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: ayahs.length,
          itemBuilder: (context, index) {
            final entry = ayahs[index];
            final verseText = entry.value;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  // 🔢 Ayah number badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 📖 Arabic text
                  Text(
                    verseText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
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