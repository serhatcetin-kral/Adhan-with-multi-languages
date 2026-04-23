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
  List<MapEntry<String, dynamic>> ayahs = [];
  final ScrollController _scrollController = ScrollController();
  bool _positionRestored = false;

  @override
  void initState() {
    super.initState();
    loadSurah();

    _scrollController.addListener(() {
      saveScrollPosition();
    });
  }

  Future<void> loadSurah() async {
    try {
      final data = await QuranService.loadSurah(widget.surahNumber);

      final dynamic verseData = data['verse'] ?? data['verses'];

      if (verseData == null) {
        throw Exception('No verse/verses key found in JSON');
      }

      final verseMap = Map<String, dynamic>.from(verseData);

      setState(() {
        ayahs = verseMap.entries.toList();
      });

      restoreScrollPosition();
    } catch (e) {
      debugPrint("ERROR loading surah: $e");
    }
  }

  Future<void> saveScrollPosition() async {
    if (!_scrollController.hasClients) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah', widget.surahNumber);
    await prefs.setDouble('last_scroll_offset', _scrollController.offset);
  }

  Future<void> restoreScrollPosition() async {
    if (_positionRestored) return;

    final prefs = await SharedPreferences.getInstance();
    final lastSurah = prefs.getInt('last_surah');
    final lastOffset = prefs.getDouble('last_scroll_offset') ?? 0.0;

    if (lastSurah == widget.surahNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        final maxScroll = _scrollController.position.maxScrollExtent;
        final safeOffset = lastOffset.clamp(0.0, maxScroll);

        _scrollController.jumpTo(safeOffset);
        _positionRestored = true;
      });
    } else {
      _positionRestored = true;
    }
  }

  @override
  void dispose() {
    saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Column(
          children: [
            Text(widget.title),
            Text(
              widget.titleAr,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: ayahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: ayahs.length,
        itemBuilder: (context, index) {
          final entry = ayahs[index];
          final verseText = entry.value.toString();

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
        },
      ),
    );
  }
}