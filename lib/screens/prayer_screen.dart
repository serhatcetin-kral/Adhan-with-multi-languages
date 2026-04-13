import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_localizations.dart';
import '../services/prayer_api_service.dart';
import '../services/location_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {

  Map<String, TimeOfDay> prayerTimes = {};
  String nextPrayer = "";
  Duration remainingTime = Duration.zero;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
    startTimer();
  }

  Future<void> loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String methodStr = prefs.getString('method') ?? 'MWL';
      String madhhabStr = prefs.getString('madhhab') ?? 'hanafi';

      int method = getMethodNumber(methodStr);
      int madhhab = getMadhhabNumber(madhhabStr);

      int fajrOffset = prefs.getInt('fajrOffset') ?? 0;
      int dhuhrOffset = prefs.getInt('dhuhrOffset') ?? 0;
      int asrOffset = prefs.getInt('asrOffset') ?? 0;
      int maghribOffset = prefs.getInt('maghribOffset') ?? 0;
      int ishaOffset = prefs.getInt('ishaOffset') ?? 0;

      Position pos = await LocationService.getUserLocation();

      final result = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: method,
        madhhab: madhhab,
      );

      setState(() {
        prayerTimes = {
          "fajr": applyOffset(parseTime(result["fajr"]!), fajrOffset),
          "sunrise": parseTime(result["sunrise"]!),
          "dhuhr": applyOffset(parseTime(result["dhuhr"]!), dhuhrOffset),
          "asr": applyOffset(parseTime(result["asr"]!), asrOffset),
          "maghrib": applyOffset(parseTime(result["maghrib"]!), maghribOffset),
          "isha": applyOffset(parseTime(result["isha"]!), ishaOffset),
        };
      });

      calculateNextPrayer();
    } catch (e) {
      print("Error: $e");
    }
  }

  int getMethodNumber(String method) {
    switch (method) {
      case 'MWL': return 3;
      case 'ISNA': return 2;
      case 'Egypt': return 5;
      case 'Makkah': return 4;
      case 'Karachi': return 1;
      case 'Turkey': return 13;
      default: return 3;
    }
  }

  int getMadhhabNumber(String madhhab) {
    return madhhab == 'hanafi' ? 1 : 0;
  }

  TimeOfDay parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  TimeOfDay applyOffset(TimeOfDay time, int offset) {
    int totalMinutes = time.hour * 60 + time.minute + offset;

    totalMinutes = totalMinutes % (24 * 60);
    if (totalMinutes < 0) totalMinutes += 24 * 60;

    return TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      calculateNextPrayer();
    });
  }

  void calculateNextPrayer() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    String foundPrayer = "";
    int minDiff = 1440;

    prayerTimes.forEach((name, time) {
      int prayerMinutes = time.hour * 60 + time.minute;

      int diff = prayerMinutes - nowMinutes;
      if (diff < 0) diff += 1440;

      if (diff < minDiff) {
        minDiff = diff;
        foundPrayer = name;
      }
    });

    setState(() {
      nextPrayer = foundPrayer;
      remainingTime = Duration(minutes: minDiff);
    });
  }

  String formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.prayerTimes)),
      body: prayerTimes.isEmpty
          ? Center(child: Text(loc.loading))
          : Column(
        children: [
          const SizedBox(height: 20),
          Text(loc.nextPrayer),
          Text(getPrayerName(loc, nextPrayer)),
          const SizedBox(height: 10),
          Text("$remainingTime"),
          Expanded(
            child: ListView(
              children: [
                buildPrayerTile(loc, "fajr"),
                buildPrayerTile(loc, "sunrise"),
                buildPrayerTile(loc, "dhuhr"),
                buildPrayerTile(loc, "asr"),
                buildPrayerTile(loc, "maghrib"),
                buildPrayerTile(loc, "isha"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPrayerTile(AppLocalizations loc, String key) {
    final time = prayerTimes[key];
    if (time == null) return const SizedBox();

    return ListTile(
      title: Text(getPrayerName(loc, key)),
      trailing: Text(formatTime(time)),
    );
  }

  String getPrayerName(AppLocalizations loc, String key) {
    switch (key) {
      case "fajr": return loc.fajr;
      case "sunrise": return loc.sunrise;
      case "dhuhr": return loc.dhuhr;
      case "asr": return loc.asr;
      case "maghrib": return loc.maghrib;
      case "isha": return loc.isha;
      default: return "";
    }
  }
}