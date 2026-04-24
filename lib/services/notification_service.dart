import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ✅ INIT
  static Future<void> init() async {
    tz.initializeTimeZones();

    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

    // Android permission
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS permission
    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ✅ SCHEDULE PRAYER
  static Future<void> schedulePrayer({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final bool notifications = prefs.getBool('notifications') ?? true;
    final bool adhan = prefs.getBool('adhan') ?? true;

    // 🔕 If notifications OFF → stop
    if (!notifications) return;

    final scheduled = tz.TZDateTime.from(time, tz.local);

    // ✅ Android
    final androidDetails = AndroidNotificationDetails(
      'adhan_channel',
      'Adhan Notifications',
      channelDescription: 'Prayer time notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: adhan,
      sound: adhan
          ? const RawResourceAndroidNotificationSound('adhan')
          : null,
    );

    // ✅ iOS
    final iosDetails = DarwinNotificationDetails(
      sound: adhan ? 'adhan.caf' : null,
      presentAlert: true,
      presentBadge: true,
      presentSound: adhan,
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
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ✅ CANCEL ALL
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}