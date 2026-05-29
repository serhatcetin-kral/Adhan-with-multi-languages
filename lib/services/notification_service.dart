import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ✅ INIT
  static Future<void> init() async {
    tzdata.initializeTimeZones();

    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(settings);

    // ✅ Android permission
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // ✅ iOS permission
    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ✅ SCHEDULE ONE PRAYER
  static Future<void> schedulePrayer({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool adhanEnabled,
  }) async {
    final scheduled = tz.TZDateTime.from(time, tz.local);

    print("Scheduled notification at: $scheduled");

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel_v1',
      'Prayer Notifications',
      channelDescription: 'Daily prayer notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: adhanEnabled,

      sound: adhanEnabled
          ? const RawResourceAndroidNotificationSound('adhan')
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: adhanEnabled,

      sound: adhanEnabled
          ? 'adhan.caf'
          : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // // ✅ SCHEDULE ALL PRAYERS
  // static Future<void> scheduleAllPrayers(   {
  //   required Map<String, DateTime> prayerTimes,
  // }) async {
  //   for (final prayer in prayerTimes.entries) {
  //
  //     // ❌ SKIP SUNRISE
  //     if (prayer.key.toLowerCase() == 'sunrise') {
  //       continue;
  //     }
  //
  //     // ❌ SKIP OLD TIMES
  //     if (prayer.value.isBefore(DateTime.now())) {
  //       continue;
  //     }
  //
  //     await schedulePrayer(
  //       id: prayer.key.hashCode,
  //       title: '${prayer.key} Prayer Time',
  //       body: 'It is time for ${prayer.key} prayer',
  //       time: prayer.value,
  //     );
  //   }
  // }

  // ✅ CANCEL ALL
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}