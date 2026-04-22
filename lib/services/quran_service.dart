import 'dart:convert';
import 'package:flutter/services.dart';

class QuranService {

  // 📖 Load all surahs list
  static Future<List<dynamic>> loadSurahList() async {
    final jsonString =
    await rootBundle.loadString('assets/quran/surah.json');

    final data = jsonDecode(jsonString);

    return data;
  }


  // 📖 Load one surah (full ayahs)
  static Future<Map<String, dynamic>> loadSurah(int number) async {
    final jsonString = await rootBundle
        .loadString('assets/quran/surah/surah_$number.json');

    return jsonDecode(jsonString);
  }
}