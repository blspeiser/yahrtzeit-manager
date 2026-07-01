import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

    tz.initializeTimeZones();

    // Detect and set the device's local timezone
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      // If timezone detection fails, fall back to UTC rather than crashing
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
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

  /// Schedules notifications for the given yahrtzeits.
  /// 
  /// When called with a subset of yahrtzeits (e.g., after add/update),
  /// only those yahrtzeits' notifications are cancelled and rescheduled.
  /// For a full reschedule, call [cancelAllNotifications] first, then this method.
  Future<void> scheduleYahrtzeitNotifications(List<Yahrtzeit> yahrtzeits,
      int daysBefore, bool notificationsEnabled) async {
    if (!notificationsEnabled) {
      await cancelAllNotifications();
      return;
    }

    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final currentJewishYear = JewishDate().getJewishYear();

    for (var yahrtzeit in yahrtzeits) {
      if (yahrtzeit.day == null || yahrtzeit.month == null) {
        continue;
      }

      // Cancel existing notifications for this specific yahrtzeit before rescheduling
      await cancelYahrtzeitNotifications(yahrtzeit.id);

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

          if (notificationDate.isAfter(now)) {
            final reminderDate =
                notificationDate.subtract(Duration(days: daysBefore));

            if (reminderDate.isAfter(now)) {
              await _scheduleNotification(
                id: _getNotificationId(yahrtzeit.id, yearOffset, 0),
                title: 'Yahrtzeit Reminder',
                body:
                    'Yahrtzeit for ${yahrtzeit.englishName ?? yahrtzeit.hebrewName} is in $daysBefore day${daysBefore == 1 ? '' : 's'}',
                scheduledDate: reminderDate,
                payload: yahrtzeit.id,
              );
            }

            await _scheduleNotification(
              id: _getNotificationId(yahrtzeit.id, yearOffset, 1),
              title: 'Yahrtzeit Today',
              body:
                  'Today is the Yahrtzeit of ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}',
              scheduledDate: notificationDate,
              payload: yahrtzeit.id,
            );
          }
        } catch (e) {
          // Skip this yahrtzeit/year if date conversion fails
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
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
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
      payload: payload,
    );
  }

  /// Generates a notification ID using the full 31-bit positive integer range.
  /// [type]: 0 = advance reminder, 1 = day-of notification
  int _getNotificationId(String yahrtzeitId, int yearOffset, int type) {
    final combined = '${yahrtzeitId}_${yearOffset}_$type';
    return combined.hashCode.abs();
  }

  Future<void> cancelYahrtzeitNotifications(String yahrtzeitId) async {
    for (int yearOffset = 0; yearOffset <= 1; yearOffset++) {
      await _notifications.cancel(id: _getNotificationId(yahrtzeitId, yearOffset, 0));
      await _notifications.cancel(id: _getNotificationId(yahrtzeitId, yearOffset, 1));
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
