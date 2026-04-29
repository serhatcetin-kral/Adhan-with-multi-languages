import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.areNotificationsEnabled();
    print("NOTIFICATION PERMISSION: $granted");
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

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();


    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> schedulePrayer({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final notificationsEnabled = prefs.getBool('notifications') ?? true;
    final adhanEnabled = prefs.getBool('adhan') ?? true;

    if (!notificationsEnabled) return;

    final scheduled = tz.TZDateTime.from(time, tz.local);

    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'adhan_channel_v2',
      'Adhan Notifications',
      channelDescription: 'Prayer time notifications with Adhan sound',
      importance: Importance.max,
      priority: Priority.high,
      playSound: adhanEnabled,
      sound: adhanEnabled
          ? const RawResourceAndroidNotificationSound('adhan')
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      sound: adhanEnabled ? 'adhan.caf' : null,
      presentAlert: true,
      presentBadge: true,
      presentSound: adhanEnabled,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> testNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 10));

    print("Scheduling test notification...");
    print("NOW: ${DateTime.now()}");
    print("TARGET: $testTime");

    await schedulePrayer(
      id: 999,
      title: "Test Adhan",
      body: "Should come in 10 seconds",
      time: testTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}