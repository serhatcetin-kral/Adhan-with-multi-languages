import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ============================================================
  // 🔔 INITIALIZE NOTIFICATIONS + TIMEZONE
  // ============================================================

  static Future<void> init() async {
    if (_initialized) return;

    // Load timezone database
    tzdata.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initializationSettings,
    );

    // ============================================================
    // 🤖 ANDROID PERMISSION
    // ============================================================

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // ============================================================
    // 🍎 IOS PERMISSION
    // ============================================================

    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;

    print('✅ NotificationService initialized');
  }

  // ============================================================
  // 🕌 SCHEDULE ONE PRAYER
  // ============================================================

  static Future<void> schedulePrayer({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required bool adhanEnabled,
  }) async {
    // Safety check
    if (!_initialized) {
      await init();
    }

    // Convert normal DateTime to timezone DateTime
    final scheduled = tz.TZDateTime.from(
      time,
      tz.local,
    );

    print('🔔 Scheduled notification at: $scheduled');

    // ============================================================
    // 🤖 ANDROID NOTIFICATION
    // ============================================================

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel_v1',
      'Prayer Notifications',
      channelDescription:
      'Daily prayer notifications',

      importance: Importance.max,
      priority: Priority.high,

      playSound: adhanEnabled,

      sound: adhanEnabled
          ? const RawResourceAndroidNotificationSound(
        'adhan',
      )
          : null,
    );

    // ============================================================
    // 🍎 IOS NOTIFICATION
    // ============================================================

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

    // ============================================================
    // ⏰ SCHEDULE
    // ============================================================

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,

      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,

      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print(
      '✅ Prayer notification scheduled: '
          '$title at $scheduled',
    );
  }

  // ============================================================
  // 🧪 TEMPORARY TEST NOTIFICATION
  // ============================================================
  //
  // Schedules a notification 1 minute from now.
  //
  // DELETE THIS METHOD AFTER THE TEST IS FINISHED.
  // ============================================================

  static Future<void> testNotification() async {
    if (!_initialized) {
      await init();
    }

    final testTime = DateTime.now().add(
      const Duration(minutes: 1),
    );

    print(
      '🧪 TEST notification scheduled for: $testTime',
    );

    await schedulePrayer(
      id: 999,
      title: 'Prayer Time Test',
      body: 'Testing Adhan notification',
      time: testTime,
      adhanEnabled: true,
    );
  }

  // ============================================================
  // 🗑️ CANCEL ONE NOTIFICATION
  // ============================================================

  static Future<void> cancel(
      int id,
      ) async {
    if (!_initialized) {
      await init();
    }

    await _plugin.cancel(id);

    print(
      '🗑️ Notification cancelled: $id',
    );
  }

  // ============================================================
  // 🗑️ CANCEL ALL NOTIFICATIONS
  // ============================================================

  static Future<void> cancelAll() async {
    if (!_initialized) {
      await init();
    }

    await _plugin.cancelAll();

    print(
      '🗑️ All prayer notifications cancelled',
    );
  }
}