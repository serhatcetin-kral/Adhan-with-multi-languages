import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import '../services/connectivity_service.dart';
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

  bool isOffline = false;
  bool firstLoadFailed = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
    startTimer();
  }

  // ================= FORMAT =================

  String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  String formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2,'0')}:"
        "${time.minute.toString().padLeft(2,'0')}";
  }

  // ================= LOAD DATA =================

  Future<void> loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectivity = await Connectivity().checkConnectivity();

      bool hasInternet = connectivity != ConnectivityResult.none;

      // ❌ NO INTERNET
      if (!hasInternet) {
        final cached = prefs.getString('cached_prayers');

        if (cached != null) {
          isOffline = true;

          final data = jsonDecode(cached);

          setState(() {
            prayerTimes = {
              "fajr": parseTime(data["fajr"]),
              "sunrise": parseTime(data["sunrise"]),
              "dhuhr": parseTime(data["dhuhr"]),
              "asr": parseTime(data["asr"]),
              "maghrib": parseTime(data["maghrib"]),
              "isha": parseTime(data["isha"]),
            };
          });

          calculateNextPrayer();
          return;
        } else {
          firstLoadFailed = true;
          setState(() {});
          return;
        }
      }

      // 📶 INTERNET AVAILABLE
      Position pos = await LocationService.getUserLocation();

      final result = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: 3,
        madhhab: 1,
      );

      // 💾 SAVE CACHE
      await prefs.setString('cached_prayers', jsonEncode(result));

      isOffline = false;
      firstLoadFailed = false;

      setState(() {
        prayerTimes = {
          "fajr": parseTime(result["fajr"] ?? "00:00"),
          "sunrise": parseTime(result["sunrise"] ?? "00:00"),
          "dhuhr": parseTime(result["dhuhr"] ?? "00:00"),
          "asr": parseTime(result["asr"] ?? "00:00"),
          "maghrib": parseTime(result["maghrib"] ?? "00:00"),
          "isha": parseTime(result["isha"] ?? "00:00"),
        };
      });

      calculateNextPrayer();

    } catch (e) {
      firstLoadFailed = true;
      setState(() {});
    }
  }

  TimeOfDay parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // ================= TIMER =================

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      calculateNextPrayer();
    });
  }

  void calculateNextPrayer() {
    final now = DateTime.now();
    final today = DateTime.now();

    final prayerList = [
      {"name": "fajr", "time": prayerTimes["fajr"]},
      {"name": "sunrise", "time": prayerTimes["sunrise"]},
      {"name": "dhuhr", "time": prayerTimes["dhuhr"]},
      {"name": "asr", "time": prayerTimes["asr"]},
      {"name": "maghrib", "time": prayerTimes["maghrib"]},
      {"name": "isha", "time": prayerTimes["isha"]},
    ];

    DateTime? nextTime;
    String nextName = "";

    for (var prayer in prayerList) {
      final time = prayer["time"] as TimeOfDay?;
      if (time == null) continue;

      final prayerDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        time.hour,
        time.minute,
      );

      if (prayerDateTime.isAfter(now)) {
        nextTime = prayerDateTime;
        nextName = prayer["name"] as String;
        break;
      }
    }

    // next day fajr
    if (nextTime == null) {
      final fajr = prayerTimes["fajr"]!;
      nextTime = DateTime(
        today.year,
        today.month,
        today.day + 1,
        fajr.hour,
        fajr.minute,
      );
      nextName = "fajr";
    }

    setState(() {
      nextPrayer = nextName;
      remainingTime = nextTime!.difference(now);
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.prayerTimes)),

      body: firstLoadFailed
          ? buildFirstLoadError(context)
          : prayerTimes.isEmpty
          ? Center(child: Text(loc.loading))
          : Column(
        children: [

          // 🟠 OFFLINE BANNER
          if (isOffline) buildOfflineBanner(),

          const SizedBox(height: 20),

          // 🕌 NEXT PRAYER
          Text(
            loc.nextPrayer,
            style: const TextStyle(fontSize: 18),
          ),

          Text(
            getPrayerName(loc, nextPrayer),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // ⏱ COUNTDOWN
          Text(
            formatDuration(remainingTime),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const Divider(),

          // 📜 PRAYER LIST
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

    final isNext = key == nextPrayer;

    return Container(
      color: isNext ? Colors.green.withOpacity(0.1) : null,
      child: ListTile(
        title: Text(
          getPrayerName(loc, key),
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(formatTime(time)),
      ),
    );
  }

  Widget buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.orange,
      child: const Text(
        "Offline Mode",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget buildFirstLoadError(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Icon(Icons.signal_wifi_off, size: 80, color: Colors.grey),

          const SizedBox(height: 20),

          const Text(
            "No internet or location access",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 🔵 OPEN SETTINGS
          ElevatedButton(
            onPressed: () {
              AppSettings.openAppSettings();
            },
            child: Text(loc.settings),
          ),

          const SizedBox(height: 10),

          // 🔄 REFRESH BUTTON
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                firstLoadFailed = false;
                prayerTimes.clear();
              });

              await loadPrayerTimes();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}