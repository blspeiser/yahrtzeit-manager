import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<bool> requestPermissions() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        return permissionsGranted.isSuccess && permissionsGranted.data!;
      }
      return permissionsGranted.data!;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Calendar>> retrieveCalendars() async {
    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess) {
        return calendarsResult.data ?? [];
      } else {
        return [];
      }
    } on PlatformException catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<Event>> retrieveEventsForToday(String calendarId) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final startDate = tz.TZDateTime(tz.local, now.year, now.month, now.day);
      final endDate = startDate.add(Duration(days: 1));
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: startDate, endDate: endDate),
      );
      if (eventsResult.isSuccess) {
        return eventsResult.data ?? [];
      } else {
        return [];
      }
    } on PlatformException catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> addEventToCalendar(String calendarId, Event event) async {
    await _deviceCalendarPlugin.createOrUpdateEvent(event);
  }
}
