import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../global.dart' as globals;
import 'calendar_service.dart';

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
            showAlert(context, event);
          }
        }
      } catch (e) {
        print('Error checking today\'s events: $e');
      }
      globals.isAlertShown = true;
    }
  }

  void showAlert(BuildContext context, Event event) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Today is Yarzeit of:', style:TextStyle(
              )),
              Text(
                event.title ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text('Details: ${event.description ?? "No details"}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  });
}

}
