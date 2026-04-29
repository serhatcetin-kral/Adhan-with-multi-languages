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

  String getHijriMonth(int month, String lang) {
    const months = {
      'en': [
        "Muharram","Safar","Rabi al-Awwal","Rabi al-Thani",
        "Jumada al-Awwal","Jumada al-Thani",
        "Rajab","Sha'ban","Ramadan","Shawwal",
        "Dhul-Qi'dah","Dhul-Hijjah"
      ],
      'tr': [
        "Muharrem","Safer","Rebiülevvel","Rebiülahir",
        "Cemaziyelevvel","Cemaziyelahir",
        "Recep","Şaban","Ramazan","Şevval",
        "Zilkade","Zilhicce"
      ],
      'ar': [
        "محرم","صفر","ربيع الأول","ربيع الثاني",
        "جمادى الأولى","جمادى الآخرة",
        "رجب","شعبان","رمضان","شوال",
        "ذو القعدة","ذو الحجة"
      ],
      'fr': [
        "Mousharram", "Safar", "Rabi' al-awwal", "Rabi' ath-thani",
        "Joumada al-oula", "Joumada ath-thania",
        "Rajab", "Cha'bane", "Ramadan", "Chawwal",
        "Dhou al-qi'da", "Dhou al-hijja"
      ],
      'de': [
        "Muharram", "Safar", "Rabi' al-awwal", "Rabi' ath-thani",
        "Dschumada l-ula", "Dschumada th-thaniya",
        "Radschab", "Scha'ban", "Ramadan", "Schawwal",
        "Dhu l-qa'da", "Dhu l-hiddscha"
      ],
      'zh': [
        "穆哈兰姆月", "色法尔月", "雷比欧阿沃尔月", "雷比欧阿色尼月",
        "朱马达·欧拉月", "朱马达·阿色尼月",
        "赖哲卜月", "舍尔班月", "赖买丹月", "闪瓦鲁月",
        "都尔喀德月", "都尔黑哲月"
      ]
    };

    return months[lang]?[month - 1] ?? months['en']![month - 1];
  }

  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
    startTimer();

  }
  Future<void> _loadCityFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        setState(() {
          _cityName = "Unknown location";
        });
        return;
      }

      final place = placemarks.first;

      setState(() {
        _cityName =
        "${place.locality ?? 'Unknown'}, ${place.subAdministrativeArea ?? ''}";
      });

    } catch (e) {
      setState(() {
        _cityName = "Location error";
      });
    }
  }
  Future<void> _loadCity() async {
    try {
      final position = await LocationService.getUserLocation();

      if (position == null) {
        setState(() {
          _cityName = "Location off";
        });
        return;
      }

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        setState(() {
          _cityName = "Unknown location";
        });
        return;
      }

      final place = placemarks.first;

      setState(() {
        _cityName =
        "${place.locality ?? 'Unknown'}, ${place.subAdministrativeArea ?? ''}";
      });

    } catch (e) {
      setState(() {
        _cityName = "Location error";
      });
    }
  }
  Widget _buildHeader() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final lang = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 📍 LOCATION
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _cityName?.isNotEmpty == true
                        ? _cityName!
                        : "Fetching location...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📅 GREGORIAN DATE (MULTI LANGUAGE)
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  DateFormat.yMMMMEEEEd(lang).format(now),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 🌙 HIJRI DATE (MULTI LANGUAGE)
            Row(
              children: [
                const Icon(Icons.brightness_2,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${hijri.hDay} ${getHijriMonth(hijri.hMonth, lang)} ${hijri.hYear}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scheduleAllPrayers() async {
    await NotificationService.cancelAll();

    int id = 1;
    final now = DateTime.now();

    for (final entry in prayerTimes.entries) {
      final name = entry.key;
      final time = entry.value;

      DateTime scheduleTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // 🔥 FIX: if time passed → schedule for tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      await NotificationService.schedulePrayer(
        id: id++,
        title: "Prayer Time",
        body: "$name time",
        time: scheduleTime,
      );
    }
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

      // ✅ LOAD CACHED FIRST
      final cached = prefs.getString('cached_prayers');

      if (cached != null) {
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
          isOffline = true;
        });

        calculateNextPrayer();
      }

      // 🔥 INTERNET UPDATE
      final hasInternet = connectivity != ConnectivityResult.none;
      if (!hasInternet) {
        print("Offline mode");
      } else {
        final pos = await LocationService.getUserLocation();

        if (pos != null) {
          await _loadCityFromPosition(pos);

          final result = await PrayerApiService.getPrayerTimes(
            latitude: pos.latitude,
            longitude: pos.longitude,
            method: method,
            madhhab: madhhab,
          );

          await prefs.setString('cached_prayers', jsonEncode(result));

          setState(() {
            prayerTimes = {
              "fajr": applyOffset(parseTime(result["fajr"] ?? "00:00"), fajrOffset),
              "sunrise": parseTime(result["sunrise"] ?? "00:00"),
              "dhuhr": applyOffset(parseTime(result["dhuhr"] ?? "00:00"), dhuhrOffset),
              "asr": applyOffset(parseTime(result["asr"] ?? "00:00"), asrOffset),
              "maghrib": applyOffset(parseTime(result["maghrib"] ?? "00:00"), maghribOffset),
              "isha": applyOffset(parseTime(result["isha"] ?? "00:00"), ishaOffset),
            };
            isOffline = false;
            firstLoadFailed = false;
          });

          calculateNextPrayer();
        }
      }

      // ✅ NOTIFICATIONS (ONLY ONCE)
      if (enabled) {
        await scheduleAllPrayers();
      } else {
        await NotificationService.cancelAll();
      }

    } catch (e) {
      print("Error: $e");
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

          // ✅ HEADER ADDED
          _buildHeader(),

          const SizedBox(height: 10),

          // 🔥 NEXT PRAYER
          Text(
            loc.nextPrayer,
            style: const TextStyle(fontSize: 16),
          ),

          Text(
            getPrayerName(loc, nextPrayer),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            formatDuration(remainingTime),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 10),
          const Divider(),

          // 🔥 PRAYER LIST
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
      ),
    );
  }

  IconData getPrayerIcon(String key) {
    switch (key) {
      case "fajr":
        return Icons.nightlight_round;
      case "sunrise":
        return Icons.wb_sunny_outlined;
      case "dhuhr":
        return Icons.wb_sunny;
      case "asr":
        return Icons.wb_twilight;
      case "maghrib":
        return Icons.brightness_3;
      case "isha":
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }

  Widget buildPrayerTile(AppLocalizations loc, String key) {
    final time = prayerTimes[key];
    if (time == null) return const SizedBox();

    final isNext = key == nextPrayer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isNext ? Colors.green.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          getPrayerIcon(key),
          color: isNext ? Colors.green : Colors.grey,
        ),

        title: Text(
          getPrayerName(loc, key),
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        trailing: Text(
          formatTime(time),
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.orange,
      child: const Text(
        "Offline Mode - Showing saved data",
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