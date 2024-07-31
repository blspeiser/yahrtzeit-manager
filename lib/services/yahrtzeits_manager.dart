import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';

class YahrtzeitsManager {
  static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
  final List<Yahrtzeit> _yahrtzeits = []; // In-memory storage
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  factory YahrtzeitsManager() {
    return _instance;
  }

  YahrtzeitsManager._internal();

  DeviceCalendarPlugin get deviceCalendarPlugin => _deviceCalendarPlugin;

  // Future<void> syncWithCalendar() async {
  //   try {
  //     var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
  //     print('Permissions Granted: $permissionsGranted');
  //     if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
  //       permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
  //       print('Requested Permissions: $permissionsGranted');
  //       if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
  //         print('Calendar permissions not granted');
  //         return;
  //       }
  //     }

  //     final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  //     print('Calendars Result: $calendarsResult');
  //     if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
  //       _yahrtzeits.clear();
  //       for (var calendar in calendarsResult!.data!) {
  //         print('Retrieving events from calendar: ${calendar.name}');
  //         final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
  //           calendar.id!,
  //           RetrieveEventsParams(
  //             startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
  //             endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
  //           ),
  //         );
  //         if (eventsResult?.isSuccess == true && eventsResult?.data!.isNotEmpty == true) {
  //           for (var event in eventsResult!.data!) {
  //             if (event.description?.startsWith('Yahrtzeit for') == true) {
  //               final hebrewName = _extractHebrewName(event.description!);
  //               final yahrtzeit = Yahrtzeit(
  //                 englishName: event.title ?? 'Unknown',
  //                 hebrewName: hebrewName,
  //                 day: event.start!.day,
  //                 month: event.start!.month,
  //                 year: event.start!.year,
  //                 gregorianDate: event.start!,
  //               );
  //               if (!_yahrtzeits.any((y) =>
  //                   y.englishName == yahrtzeit.englishName &&
  //                   y.hebrewName == yahrtzeit.hebrewName &&
  //                   y.gregorianDate == yahrtzeit.gregorianDate)) {
  //                 _yahrtzeits.add(yahrtzeit);
  //               }
  //             }
  //           }
  //         }
  //       }
  //     } else {
  //       print('No calendars available or failed to retrieve calendars');
  //     }
  //   } on PlatformException catch (e) {
  //     print('Error syncing with calendar: $e');
  //   }
  // }

  Future<void> syncWithCalendar() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      print('Permissions Granted: $permissionsGranted');
      if (permissionsGranted?.isSuccess == true &&
          permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        print('Requested Permissions: $permissionsGranted');
        if (permissionsGranted?.isSuccess == false ||
            permissionsGranted?.data == false) {
          print('Calendar permissions not granted');
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      print('Calendars Result: $calendarsResult');
      if (calendarsResult?.isSuccess == true &&
          calendarsResult?.data!.isNotEmpty == true) {
        _yahrtzeits.clear();
        final timeZoneProvider = await DateTimeZoneProviders.tzdb;
        final timeZone = timeZoneProvider['Asia/Jerusalem'];
        if (timeZone == null) {
          print('Time zone not found');
          return;
        }

        for (var calendar in calendarsResult!.data!) {
          print('Retrieving events from calendar: ${calendar.name}');
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            RetrieveEventsParams(
              startDate:
                  tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult?.isSuccess == true &&
              eventsResult?.data!.isNotEmpty == true) {
            for (var event in eventsResult!.data!) {
              if (event.description?.startsWith('Yahrtzeit for') == true) {
                final hebrewName = _extractHebrewName(event.description!);

                final localDateTime = DateTime(
                  event.start!.year,
                  event.start!.month,
                  event.start!.day,
                  event.start!.hour ?? 0,
                  event.start!.minute ?? 0,
                  event.start!.second ?? 0,
                );

                final zonedDateTime = ZonedDateTime(
                  localDateTime as Instant,
                  timeZone as DateTimeZone?,
                  Offset.zero
                      as CalendarSystem?, // assuming the event is in UTC, adjust if needed
                );

                final yahrtzeit = Yahrtzeit(
                  englishName: event.title ?? 'Unknown',
                  hebrewName: hebrewName,
                  day: event.start!.day,
                  month: event.start!.month,
                  year: event.start!.year,
                  gregorianDate: zonedDateTime,
                );
                if (!_yahrtzeits.any((y) =>
                    y.englishName == yahrtzeit.englishName &&
                    y.hebrewName == yahrtzeit.hebrewName &&
                    y.gregorianDate == yahrtzeit.gregorianDate)) {
                  _yahrtzeits.add(yahrtzeit);
                }
              }
            }
          }
        }
      } else {
        print('No calendars available or failed to retrieve calendars');
      }
    } on PlatformException catch (e) {
      print('Error syncing with calendar: $e');
    }
  }

  Future<void> addYahrtzeit(Yahrtzeit yahrtzeit) async {
    if (!_yahrtzeits.any((y) =>
        y.englishName == yahrtzeit.englishName &&
        y.hebrewName == yahrtzeit.hebrewName &&
        y.gregorianDate == yahrtzeit.gregorianDate)) {
      _yahrtzeits.add(yahrtzeit);
      await _addToCalendar(yahrtzeit);
    }
  }

  Future<List<Yahrtzeit>> getAllYahrtzeits() async {
    await syncWithCalendar();
    return _yahrtzeits;
  }

  Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 10}) async {
    final allYahrtzeits = await getAllYahrtzeits();
    final now = tz.TZDateTime.now(tz.local);
    final upcomingYahrtzeits = allYahrtzeits.where((yahrtzeit) {
      final yahrtzeitDate = tz.TZDateTime.from(
          yahrtzeit.getGregorianDate() as DateTime, tz.local);
      return yahrtzeitDate.isAfter(now) &&
          yahrtzeitDate.isBefore(now.add(Duration(days: days)));
    }).toList();
    return upcomingYahrtzeits;
  }

  // Future<void> _addToCalendar(Yahrtzeit yahrtzeit) async {
  //   try {
  //     var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
  //     print('Permissions Granted: $permissionsGranted');
  //     if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
  //       permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
  //       print('Requested Permissions: $permissionsGranted');
  //       if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
  //         print('Calendar permissions not granted');
  //         return;
  //       }
  //     }

  //     final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  //     print('Calendars Result: $calendarsResult');
  //     if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
  //       for (var calendar in calendarsResult!.data!) {
  //         print('Adding event to calendar: ${calendar.name}');
  //         final event = Event(
  //           calendar.id!,
  //           title: yahrtzeit.englishName,
  //           description: 'Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})',
  //           start: tz.TZDateTime.from(yahrtzeit.getGregorianDate() as DateTime, tz.local),
  //           end: tz.TZDateTime.from(yahrtzeit.getGregorianDate() as DateTime, tz.local).add(Duration(hours: 1)),
  //         );
  //         print('Event Details: ${event.title}, ${event.description}, ${event.start}, ${event.end}');
  //         final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
  //         print('Create or Update Event Result for ${calendar.name}: ${result?.data}');
  //         if (result?.isSuccess == false) {
  //           print('Error creating or updating event for ${calendar.name}: ${result?.data}');
  //         }
  //       }
  //     } else {
  //       print('No calendars available or failed to retrieve calendars');
  //     }
  //   } on PlatformException catch (e) {
  //     print('Error adding event to calendar: $e');
  //   }
  // }
tz.TZDateTime convertZonedDateTimeToTZDateTime(ZonedDateTime zonedDateTime) {
  final timeZone = tz.getLocation('Asia/Jerusalem'); // Replace with your time zone
  return tz.TZDateTime(
    timeZone,
    zonedDateTime.year,
    zonedDateTime.monthOfYear,
    zonedDateTime.dayOfMonth,
    zonedDateTime.hourOfDay,
    zonedDateTime.minuteOfHour,
    zonedDateTime.secondOfMinute,
    zonedDateTime.millisecondOfSecond,
    zonedDateTime.microsecondOfSecond,
  );
}
  Future<void> _addToCalendar(Yahrtzeit yahrtzeit) async {
  try {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
        print('Calendar permissions not granted');
        return;
      }
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
      for (var calendar in calendarsResult!.data!) {
        // Convert ZonedDateTime to TZDateTime
        final startDateTime = convertZonedDateTimeToTZDateTime(yahrtzeit.gregorianDate);
        final endDateTime = startDateTime.add(Duration(hours: 1)); // Assuming an event lasts 1 hour

        final event = Event(
          calendar.id!,
          title: yahrtzeit.englishName,
          description: 'Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})',
          start: startDateTime,
          end: endDateTime,
        );

        final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
        if (result?.isSuccess == false) {
          print('Error creating or updating event for ${calendar.name}: ${result?.data}');
        }
      }
    } else {
      print('No calendars available or failed to retrieve calendars');
    }
  } on PlatformException catch (e) {
    print('Error adding event to calendar: $e');
  }
}


  List<YahrtzeitDate> nextMultiple(List<Yahrtzeit> yahrtzeits) {
    final dates = yahrtzeits
        .map((yahrtzeit) => YahrtzeitDate.fromYahrtzeit(yahrtzeit))
        .toList();
    dates.sort((a, b) =>
        a.gregorianDate.toInstant().compareTo(b.gregorianDate.toInstant()));
    return dates;
  }

  String _extractHebrewName(String description) {
    final regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(description);
    return match != null ? match.group(1)! : 'Unknown';
  }
}
