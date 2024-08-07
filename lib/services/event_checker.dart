
import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import '../global.dart' as globals;
import 'calendar_service.dart';
import 'notification_service.dart';

class EventChecker {
  final CalendarService calendarService = CalendarService();

  Future<void> checkForTodayEvents(BuildContext context) async {
    if (!globals.isAlertShown) {
      try {
        bool permissionsGranted = await calendarService.requestPermissions();
        if (!permissionsGranted) {
          print('Permissions not granted');
          return;
        }
        
        List<Calendar> calendars = await calendarService.retrieveCalendars();
        for (var calendar in calendars) {
          List<Event> events = await calendarService.retrieveEventsForToday(calendar.id!);
          for (var event in events) {
            var notificationProviderState = NotificationProvider.of(context);
            if (notificationProviderState != null) {
              var notificationServiceState = notificationProviderState.notificationService;
              if (notificationServiceState != null) {
                await notificationServiceState.showNotification(
                  'Today is Yarzeit of:',
                  event.title ?? 'No title',
                );
              }
            }
          }
        }
      } catch (e) {
        print('Error checking today\'s events: $e');
      }
      globals.isAlertShown = true;
    }
  }
}
