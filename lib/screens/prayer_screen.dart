import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
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

  Future<void> scheduleAllPrayers() async {
    await NotificationService.cancelAll();

    int id = 0;
    final now = DateTime.now();

    prayerTimes.forEach((name, time) {
      final scheduleTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduleTime.isAfter(now)) {
        NotificationService.schedulePrayer(
          id: id++,
          title: "Prayer Time",
          body: "$name time",
          time: scheduleTime,
        );
      }
    });
  }

  String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  String formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  int getMethodNumber(String method) {
    switch (method) {
      case 'MWL':
        return 3;
      case 'ISNA':
        return 2;
      case 'Egypt':
        return 5;
      case 'Makkah':
        return 4;
      case 'Karachi':
        return 1;
      case 'Turkey':
        return 13;
      default:
        return 3;
    }
  }

  int getMadhhabNumber(String madhhab) {
    return madhhab == 'hanafi' ? 1 : 0;
  }

  Future<void> loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectivity = await Connectivity().checkConnectivity();

      final methodStr = prefs.getString('method') ?? 'MWL';
      final madhhabStr = prefs.getString('madhhab') ?? 'hanafi';

      final method = getMethodNumber(methodStr);
      final madhhab = getMadhhabNumber(madhhabStr);

      final fajrOffset = prefs.getInt('fajrOffset') ?? 0;
      final dhuhrOffset = prefs.getInt('dhuhrOffset') ?? 0;
      final asrOffset = prefs.getInt('asrOffset') ?? 0;
      final maghribOffset = prefs.getInt('maghribOffset') ?? 0;
      final ishaOffset = prefs.getInt('ishaOffset') ?? 0;

      final enabled = prefs.getBool('notifications') ?? true;

      final hasInternet = connectivity != ConnectivityResult.none;

      if (!hasInternet) {
        final cached = prefs.getString('cached_prayers');

        if (cached != null) {
          isOffline = true;

          final data = jsonDecode(cached);

          setState(() {
            prayerTimes = {
              "fajr": applyOffset(parseTime(data["fajr"] ?? "00:00"), fajrOffset),
              "sunrise": parseTime(data["sunrise"] ?? "00:00"),
              "dhuhr": applyOffset(parseTime(data["dhuhr"] ?? "00:00"), dhuhrOffset),
              "asr": applyOffset(parseTime(data["asr"] ?? "00:00"), asrOffset),
              "maghrib": applyOffset(parseTime(data["maghrib"] ?? "00:00"), maghribOffset),
              "isha": applyOffset(parseTime(data["isha"] ?? "00:00"), ishaOffset),
            };
          });

          calculateNextPrayer();

          final prefs = await SharedPreferences.getInstance();
          final enabled = prefs.getBool('notifications') ?? true;

          if (enabled) {
            await scheduleAllPrayers();
          } else {
            await NotificationService.cancelAll();
          }
          return;
        } else {
          firstLoadFailed = true;
          setState(() {});
          return;
        }
      }

      final Position pos = await LocationService.getUserLocation();

      final result = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: method,
        madhhab: madhhab,
      );

      await prefs.setString('cached_prayers', jsonEncode(result));

      isOffline = false;
      firstLoadFailed = false;

      setState(() {
        prayerTimes = {
          "fajr": applyOffset(parseTime(result["fajr"] ?? "00:00"), fajrOffset),
          "sunrise": parseTime(result["sunrise"] ?? "00:00"),
          "dhuhr": applyOffset(parseTime(result["dhuhr"] ?? "00:00"), dhuhrOffset),
          "asr": applyOffset(parseTime(result["asr"] ?? "00:00"), asrOffset),
          "maghrib": applyOffset(parseTime(result["maghrib"] ?? "00:00"), maghribOffset),
          "isha": applyOffset(parseTime(result["isha"] ?? "00:00"), ishaOffset),
        };
      });

      calculateNextPrayer();

      if (enabled) {
        await scheduleAllPrayers();
      } else {
        await NotificationService.cancelAll();
      }
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
    if (prayerTimes.isEmpty) return;

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
          if (isOffline) buildOfflineBanner(),
          const SizedBox(height: 20),
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
          Text(
            formatDuration(remainingTime),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const Divider(),
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
          ElevatedButton(
            onPressed: () {
              AppSettings.openAppSettings();
            },
            child: Text(loc.settings),
          ),
          const SizedBox(height: 10),
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
      case "fajr":
        return loc.fajr;
      case "sunrise":
        return loc.sunrise;
      case "dhuhr":
        return loc.dhuhr;
      case "asr":
        return loc.asr;
      case "maghrib":
        return loc.maghrib;
      case "isha":
        return loc.isha;
      default:
        return "";
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}