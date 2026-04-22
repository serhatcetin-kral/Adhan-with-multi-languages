import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import 'quran_reader_screen.dart';

class QuranTestScreen extends StatefulWidget {
  const QuranTestScreen({super.key});

  @override
  State<QuranTestScreen> createState() => _QuranTestScreenState();
}

class _QuranTestScreenState extends State<QuranTestScreen> {
  List surahs = [];

  @override
  void initState() {
    super.initState();
    load();
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

          return ListTile(
            leading: Text(s['index'] ?? ''),

            title: Text(s['title'] ?? 'No name'),

            subtitle: Text(s['titleAr'] ?? ''),

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
          );
        },
      ),
    );
  }
}