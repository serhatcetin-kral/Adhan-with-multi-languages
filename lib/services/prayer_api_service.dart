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

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data['data']['timings'];

        return {
          "fajr": timings['Fajr'] ?? "00:00",
          "sunrise": timings['Sunrise'] ?? "00:00",
          "dhuhr": timings['Dhuhr'] ?? "00:00",
          "asr": timings['Asr'] ?? "00:00",
          "maghrib": timings['Maghrib'] ?? "00:00",
          "isha": timings['Isha'] ?? "00:00",
        };
      } else {
        throw Exception("API error: ${response.statusCode}");
      }
    } catch (e) {
      print("API ERROR: $e");
      throw Exception("Failed to load prayer times");
    }
  }
}