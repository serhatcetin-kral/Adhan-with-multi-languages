import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import 'quran_reader_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranTestScreenState();
}

class _QuranTestScreenState extends State<QuranScreen> {
  List surahs = [];

  @override
  void initState() {
    super.initState();
    load();
  }
  String getSurahName(Map s, String lang) {
    if (lang == 'ar') {
      return s['titleAr'] ?? '';
    }
    return s['title'] ?? '';
  }
  Future<void> load() async {
    final data = await QuranService.loadSurahList();

    setState(() {
      surahs = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quran")),
      body: surahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final s = surahs[index] ?? {};
            final lang = Localizations.localeOf(context).languageCode;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuranReaderScreen(
                      surahNumber: int.parse(s['index'] ?? '1'),
                      title: s['title'] ?? '',
                      titleAr: s['titleAr'] ?? '',
                    ),
                  ),
                );
              },

              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                    )
                  ],
                ),

                child: Row(
                  children: [

                    // 🔢 Number
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

                    // 📖 Names
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

                    // ➡️ Arrow
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}