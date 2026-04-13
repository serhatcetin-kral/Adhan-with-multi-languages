import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerApiService {
  static Future<Map<String, String>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int madhhab,
  }) async {
    final url =
        "https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=$method&school=$madhhab";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final timings = data['data']['timings'];

      return {
        "fajr": timings['Fajr'],
        "sunrise": timings['Sunrise'],
        "dhuhr": timings['Dhuhr'],
        "asr": timings['Asr'],
        "maghrib": timings['Maghrib'],
        "isha": timings['Isha'],
      };
    } else {
      throw Exception("Failed to load prayer times");
    }
  }
}