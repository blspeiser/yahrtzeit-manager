import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:kosher_dart/kosher_dart.dart';
import '../models/yahrtzeit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (await _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>() !=
        null) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Request permissions for iOS
    if (await _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>() !=
        null) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
  }

  Future<void> scheduleYahrtzeitNotifications(List<Yahrtzeit> yahrtzeits,
      int daysBefore, bool notificationsEnabled) async {
    if (!notificationsEnabled) {
      await cancelAllNotifications();
      return;
    }

    await initialize();
    await cancelAllNotifications();

    final now = tz.TZDateTime.now(tz.local);
    final currentJewishYear = JewishDate().getJewishYear();

    for (var yahrtzeit in yahrtzeits) {
      // Skip yahrtzeits without day/month (incomplete entries)
      if (yahrtzeit.day == null || yahrtzeit.month == null) {
        continue;
      }
      // Schedule for current year and next year
      for (int yearOffset = 0; yearOffset <= 1; yearOffset++) {
        int jewishYear = currentJewishYear + yearOffset;

        try {
          // Handle Adar II (month 13) in non-leap years: convert to Adar (month 12)
          int monthToUse = yahrtzeit.month!;
          if (yahrtzeit.month == JewishDate.ADAR_II) {
            // Check if this is a leap year by testing if ADAR becomes ADAR_II
            final testDate = JewishDate.initDate(
                jewishYear: jewishYear,
                jewishMonth: JewishDate.ADAR,
                jewishDayOfMonth: 1);
            if (testDate.getJewishMonth() != JewishDate.ADAR_II) {
              // Not a leap year, so ADAR_II should be treated as ADAR
              monthToUse = JewishDate.ADAR;
            }
          }

          JewishDate jewishDate = JewishDate.initDate(
            jewishYear: jewishYear,
            jewishMonth: monthToUse,
            jewishDayOfMonth: yahrtzeit.day!,
          );

          DateTime gregorianDate = DateTime(
            jewishDate.getGregorianYear(),
            jewishDate.getGregorianMonth(),
            jewishDate.getGregorianDayOfMonth(),
          );

          final notificationDate = tz.TZDateTime.from(gregorianDate, tz.local);

          // Only schedule if the date is in the future
          if (notificationDate.isAfter(now)) {
            final reminderDate =
                notificationDate.subtract(Duration(days: daysBefore));

            // Only schedule reminder if it's in the future
            if (reminderDate.isAfter(now)) {
              await _scheduleNotification(
                id: _getNotificationId(yahrtzeit.id, yearOffset),
                title: 'Yahrtzeit Reminder',
                body:
                    'Yahrtzeit for ${yahrtzeit.englishName ?? yahrtzeit.hebrewName} is in $daysBefore day${daysBefore == 1 ? '' : 's'}',
                scheduledDate: reminderDate,
                payload: yahrtzeit.id,
              );
            }

            // Also schedule notification for the day of
            await _scheduleNotification(
              id: _getNotificationId(yahrtzeit.id, yearOffset) + 10000,
              title: 'Yahrtzeit Today',
              body:
                  'Today is the Yahrtzeit of ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}',
              scheduledDate: notificationDate,
              payload: yahrtzeit.id,
            );
          }
        } catch (e) {
          // Error scheduling notification - continue with others
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'yahrtzeit_channel',
          'Yahrtzeit Reminders',
          channelDescription: 'Notifications for upcoming Yahrtzeits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  int _getNotificationId(String yahrtzeitId, int yearOffset) {
    // Create a unique ID based on yahrtzeit ID and year offset
    // Using hash code to ensure uniqueness
    return (yahrtzeitId.hashCode + yearOffset * 1000).abs() % 10000;
  }

  Future<void> cancelYahrtzeitNotifications(String yahrtzeitId) async {
    // Cancel all notifications for this yahrtzeit (current and next year)
    for (int yearOffset = 0; yearOffset <= 1; yearOffset++) {
      final id = _getNotificationId(yahrtzeitId, yearOffset);
      await _notifications.cancel(id);
      await _notifications
          .cancel(id + 10000); // Also cancel the day-of notification
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
