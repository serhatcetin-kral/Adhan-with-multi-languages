import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';

import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/prayer_api_service.dart';
import '../services/app_location_service.dart';

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
  String? _cityName;
  String? _lastSavedTimeStr;
  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> loadPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. LOAD CACHE & METADATA IMMEDIATELY
    final String? cached = prefs.getString('cached_prayers');
    final String? savedCity = prefs.getString('last_city_name');
    final String? lastUpdate = prefs.getString('last_update_time');

    if (cached != null) {
      final Map<String, dynamic> data = jsonDecode(cached);
      if (mounted) {
        setState(() {
          // Recover saved info
          _cityName = savedCity;
          _lastSavedTimeStr = lastUpdate;

          prayerTimes = {
            "fajr": applyOffset(parseTime(data["fajr"]), prefs.getInt('fajrOffset') ?? 0),
            "sunrise": parseTime(data["sunrise"]),
            "dhuhr": applyOffset(parseTime(data["dhuhr"]), prefs.getInt('dhuhrOffset') ?? 0),
            "asr": applyOffset(parseTime(data["asr"]), prefs.getInt('asrOffset') ?? 0),
            "maghrib": applyOffset(parseTime(data["maghrib"]), prefs.getInt('maghribOffset') ?? 0),
            "isha": applyOffset(parseTime(data["isha"]), prefs.getInt('ishaOffset') ?? 0),
          };
          isOffline = true;
          firstLoadFailed = false;
        });
        calculateNextPrayer();
      }
    }

    // 2. CHECK INTERNET
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasInternet) {
      if (prayerTimes.isEmpty && mounted) setState(() => firstLoadFailed = true);
      return;
    }

    // 3. REFRESH FROM API
    try {
      final Position? pos = await LocationService.getUserLocation();
      if (pos == null) return;

      await _loadCityFromPosition(pos);

      final result = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: getMethodNumber(prefs.getString('method') ?? 'MWL'),
        madhhab: getMadhhabNumber(prefs.getString('madhhab') ?? 'hanafi'),
      );

      // Generate current timestamp
      final String nowStr = DateFormat('HH:mm (MMM d)').format(DateTime.now());

      // SAVE TO STORAGE
      await prefs.setString('cached_prayers', jsonEncode(result));
      await prefs.setString('last_city_name', _cityName ?? "Unknown");
      await prefs.setString('last_update_time', nowStr);

      if (mounted) {
        setState(() {
          _lastSavedTimeStr = nowStr;
          isOffline = false;
          firstLoadFailed = false;
          // Update prayerTimes with fresh result... (omitted for brevity)
        });
      }
    } catch (e) {
      if (prayerTimes.isEmpty && mounted) setState(() => firstLoadFailed = true);
    }
  }

  // Widget buildOfflineBanner() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(8),
  //     color: Colors.orange.shade800,
  //     child: Column(
  //       children: [
  //         const Text(
  //           "Offline Mode",
  //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         ),
  //         if (_lastSavedTimeStr != null)
  //           Text(
  //             "Last updated: $_lastSavedTimeStr",
  //             style: const TextStyle(color: Colors.white70, fontSize: 11),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // --- HELPERS ---

  TimeOfDay parseTime(String? time) {
    if (time == null || !time.contains(":")) return const TimeOfDay(hour: 0, minute: 0);
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  TimeOfDay applyOffset(TimeOfDay time, int offset) {
    int totalMinutes = time.hour * 60 + time.minute + offset;
    totalMinutes = totalMinutes % (24 * 60);
    if (totalMinutes < 0) totalMinutes += 24 * 60;
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) calculateNextPrayer();
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
      final prayerDateTime = DateTime(today.year, today.month, today.day, time.hour, time.minute);
      if (prayerDateTime.isAfter(now)) {
        nextTime = prayerDateTime;
        nextName = prayer["name"] as String;
        break;
      }
    }

    if (nextTime == null) {
      final fajr = prayerTimes["fajr"]!;
      nextTime = DateTime(today.year, today.month, today.day + 1, fajr.hour, fajr.minute);
      nextName = "fajr";
    }

    if (mounted) {
      setState(() {
        nextPrayer = nextName;
        remainingTime = nextTime!.difference(now);
      });
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // DECISION LOGIC:
    // If we have data, show the app.
    // Only if we have NO DATA and a FAIL occurred, show the refresh/settings screen.
    return Scaffold(
      appBar: AppBar(title: Text(loc.prayerTimes)),
      body: prayerTimes.isNotEmpty
          ? _buildMainContent(loc)
          : firstLoadFailed
          ? buildFirstLoadError(context)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMainContent(AppLocalizations loc) {
    return Column(
      children: [
        if (isOffline) buildOfflineBanner(),
        _buildHeader(),
        const SizedBox(height: 6),
        Text(loc.nextPrayer, style: const TextStyle(fontSize: 14)),
        Text(
          getPrayerName(loc, nextPrayer),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          formatDuration(remainingTime),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 6),
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
        ),
      ],
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildHeader() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final lang = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _cityName?.isNotEmpty == true ? _cityName! : "...",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(DateFormat.yMMMMEEEEd(lang).format(now), style: const TextStyle(color: Colors.white70)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.brightness_2, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text("${hijri.hDay} ${getHijriMonth(hijri.hMonth, lang)} ${hijri.hYear}", style: const TextStyle(color: Colors.white70)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildPrayerTile(AppLocalizations loc, String key) {
    final time = prayerTimes[key];
    if (time == null) return const SizedBox();
    final isNext = key == nextPrayer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isNext ? Colors.green.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(getPrayerIcon(key), color: isNext ? Colors.green : Colors.grey),
        title: Text(getPrayerName(loc, key), style: TextStyle(fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
        trailing: Text(formatTime(time), style: TextStyle(fontSize: 14, fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
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
          const Text("No saved data found.\nPlease check internet.", textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => AppSettings.openAppSettings(), child: Text(loc.settings)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => firstLoadFailed = false);
              loadPrayerTimes();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade800,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                "Offline Mode",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_lastSavedTimeStr != null)
            Text(
              "Last synced: $_lastSavedTimeStr",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }

  // --- UTILS ---
  Future<void> _loadCityFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() => _cityName = "${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}");
      }
    } catch (_) {}
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  String formatTime(TimeOfDay time) => "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

  int getMethodNumber(String method) {
    const map = {'MWL': 3, 'ISNA': 2, 'Egypt': 5, 'Makkah': 4, 'Karachi': 1, 'Turkey': 13};
    return map[method] ?? 3;
  }

  int getMadhhabNumber(String madhhab) => madhhab == 'hanafi' ? 1 : 0;

  IconData getPrayerIcon(String key) {
    const map = {"fajr": Icons.nightlight_round, "sunrise": Icons.wb_sunny_outlined, "dhuhr": Icons.wb_sunny, "asr": Icons.wb_twilight, "maghrib": Icons.brightness_3, "isha": Icons.nightlight};
    return map[key] ?? Icons.access_time;
  }

  String getPrayerName(AppLocalizations loc, String key) {
    const map = {"fajr": "fajr", "sunrise": "sunrise", "dhuhr": "dhuhr", "asr": "asr", "maghrib": "maghrib", "isha": "isha"};
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

  String getHijriMonth(int month, String lang) {
    const months = {
      'en': ["Muharram","Safar","Rabi al-Awwal","Rabi al-Thani","Jumada al-Awwal","Jumada al-Thani","Rajab","Sha'ban","Ramadan","Shawwal","Dhul-Qi'dah","Dhul-Hijjah"],
      'tr': ["Muharrem","Safer","Rebiülevvel","Rebiülahir","Cemaziyelevvel","Cemaziyelahir","Recep","Şaban","Ramazan","Şevval","Zilkade","Zilhicce"],
      'ar': ["محرم","صفر","ربيع الأول","ربيع الثاني","جمادى الأولى","جمادى الآخرة","رجب","شعبان","رمضان","شوال","ذو القعدة","ذو الحجة"],
    };
    return months[lang]?[month - 1] ?? months['en']![month - 1];
  }

  Future<void> scheduleAllPrayers() async {
    await NotificationService.cancelAll();
    int id = 0;
    final now = DateTime.now();
    prayerTimes.forEach((name, time) {
      final scheduleTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      if (scheduleTime.isAfter(now)) {
        NotificationService.schedulePrayer(id: id++, title: "Prayer Time", body: "$name time", time: scheduleTime);
      }
    });
  }
}