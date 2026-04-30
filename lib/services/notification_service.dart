import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    tzdata.initializeTimeZones();

    // ✅ SIMPLE SAFE FIX
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

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ✅ SCHEDULE ONE
  static Future<void> schedulePrayer({
    required int id,
    required String title,
    required String body,
    required DateTime time,

  }) async {
    final scheduled = tz.TZDateTime.from(time, tz.local);
    print("Scheduled notification at: $scheduled");

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel_v1',
      'Prayer Notifications',
      channelDescription: 'Daily prayer notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
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

  // ✅ CANCEL
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ✅ TEST
  // static Future<void> testNotification() async {
  //   await _plugin.show(
  //     999,
  //     "Test Notification",
  //     "Instant test working",
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'test_channel_simple',
  //         'Test Channel',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         playSound: true,
  //       ),
  //     ),
  //   );
  // }
}