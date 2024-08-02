import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import 'package:kosher_dart/kosher_dart.dart' as kj;

class YahrtzeitsManager {
  static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
  final List<Yahrtzeit> _yahrtzeits = []; // In-memory storage
  final dc.DeviceCalendarPlugin _deviceCalendarPlugin =
      dc.DeviceCalendarPlugin();

  static const platform = MethodChannel('com.yahrtzeits/manager');

  Future<Map<String, dynamic>> nextYahrtzeit(
      Map<String, dynamic> yahrtzeit) async {
    final result = await platform.invokeMethod<Map<String, dynamic>>(
        'nextYahrtzeit', yahrtzeit);
    return result!;
  }

  factory YahrtzeitsManager() {
    return _instance;
  }

  YahrtzeitsManager._internal();

  dc.DeviceCalendarPlugin get deviceCalendarPlugin => _deviceCalendarPlugin;

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
        for (var calendar in calendarsResult!.data!) {
          print('Retrieving events from calendar: ${calendar.name}');
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            dc.RetrieveEventsParams(
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
                final yahrtzeit = Yahrtzeit(
                  englishName: event.title ?? 'Unknown',
                  hebrewName: hebrewName,
                  day: event.start!.day,
                  month: event.start!.month,
                  year: event.start!.year,
                  gregorianDate: event.start!,
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

  // Future<void> addYahrtzeit(Yahrtzeit yahrtzeit) async {
  //   if (!_yahrtzeits.any((y) =>
  //       y.englishName == yahrtzeit.englishName &&
  //       y.hebrewName == yahrtzeit.hebrewName &&
  //       y.gregorianDate == yahrtzeit.gregorianDate
  //       )) {
  //     _yahrtzeits.add(yahrtzeit);
  //     await _addToCalendar(yahrtzeit);

  //   }
  // }
  Future<void> addYahrtzeit(Yahrtzeit yahrtzeit) async {
    final nextYearGregorianDate =
        _getNextGregorianDate(yahrtzeit.day, yahrtzeit.month);
    if (!_yahrtzeits.any((y) =>
        y.englishName == yahrtzeit.englishName &&
        y.hebrewName == y.hebrewName &&
        y.day == yahrtzeit.day &&
        y.month == yahrtzeit.month &&
        y.gregorianDate == nextYearGregorianDate)) {
      final newYahrtzeit = Yahrtzeit(
        englishName: yahrtzeit.englishName,
        hebrewName: yahrtzeit.hebrewName,
        day: yahrtzeit.day,
        month: yahrtzeit.month,
        year: yahrtzeit.year,
        gregorianDate: nextYearGregorianDate,
      );
      _yahrtzeits.add(newYahrtzeit);
      await _addToCalendar(newYahrtzeit);
      print('Yahrtzeit added: ${newYahrtzeit.englishName}');
    }
  }

  // Future<void> updateYahrtzeit( Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit) async {
  //   await deleteYahrtzeit(oldYahrtzeit);
  //   await addYahrtzeit(newYahrtzeit);
  // }

  Future<void> updateYahrtzeit(
      Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit) async {
    final nextYearGregorianDateOld =
        _getNextGregorianDate(oldYahrtzeit.day, oldYahrtzeit.month);
    final nextYearGregorianDateNew =
        _getNextGregorianDate(newYahrtzeit.day, newYahrtzeit.month);

    final index = _yahrtzeits.indexWhere((y) =>
        y.englishName == oldYahrtzeit.englishName &&
        y.hebrewName == oldYahrtzeit.hebrewName &&
        y.day == oldYahrtzeit.day &&
        y.month == oldYahrtzeit.month &&
        y.gregorianDate == nextYearGregorianDateOld);
    if (index != -1) {
      final updatedYahrtzeit = Yahrtzeit(
        englishName: newYahrtzeit.englishName,
        hebrewName: newYahrtzeit.hebrewName,
        day: newYahrtzeit.day,
        month: newYahrtzeit.month,
        year: newYahrtzeit.year,
        gregorianDate: nextYearGregorianDateNew,
      );
      _yahrtzeits[index] = updatedYahrtzeit;
      await _deleteFromCalendar(oldYahrtzeit);
      await _addToCalendar(updatedYahrtzeit);
      print('Yahrtzeit updated: ${updatedYahrtzeit.englishName}');
    }
  }

  // Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
  //   _yahrtzeits.removeWhere((y) =>
  //       y.englishName == yahrtzeit.englishName &&
  //       y.hebrewName == yahrtzeit.hebrewName &&
  //       y.gregorianDate == yahrtzeit.gregorianDate);
  //   await _deleteFromCalendar(yahrtzeit);
  // }
  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      final nextYearGregorianDate =
          _getNextGregorianDate(yahrtzeit.day, yahrtzeit.month);
      _yahrtzeits.removeWhere((y) =>
          y.englishName == yahrtzeit.englishName &&
          y.hebrewName == y.hebrewName &&
          y.day == yahrtzeit.day &&
          y.month == y.month &&
          y.gregorianDate == nextYearGregorianDate);
      await _deleteFromCalendar(yahrtzeit);
      print('Yahrtzeit deleted: ${yahrtzeit.englishName}');
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
    }
  }

  Future<List<Yahrtzeit>> getAllYahrtzeits() async {
    await syncWithCalendar();
    print('All yahrtzeits fetched: ${_yahrtzeits.length}');
    return _yahrtzeits;
  }

  // Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 20}) async {
  //   final allYahrtzeits = await getAllYahrtzeits();
  //   final now = tz.TZDateTime.now(tz.local);
  //   final upcomingYahrtzeits = allYahrtzeits.where((yahrtzeit) {
  //     final yahrtzeitDate =
  //         tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local);
  //     return yahrtzeitDate.isAfter(now) &&
  //         yahrtzeitDate.isBefore(now.add(Duration(days: days)));
  //   }).toList();
  //   return upcomingYahrtzeits;
  // }

  Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 1000}) async {
    final allYahrtzeits = await getAllYahrtzeits();
    final now = tz.TZDateTime.now(tz.local);
    final upcomingYahrtzeits = allYahrtzeits.where((yahrtzeit) {
      final yahrtzeitDate =
          tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local);
      return yahrtzeitDate.isAfter(now) &&
          yahrtzeitDate.isBefore(now.add(Duration(days: days)));
    }).toList();
    print('Upcoming yahrtzeits fetched: ${upcomingYahrtzeits.length}');
    return upcomingYahrtzeits;
  }

  Future<void> _addToCalendar(Yahrtzeit yahrtzeit) async {
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
        for (var calendar in calendarsResult!.data!) {
          print('Adding event to calendar: ${calendar.name}');
          final event = dc.Event(
            calendar.id!,
            title: yahrtzeit.englishName,
            description:
                'Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})',
            start: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local),
            end: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local)
                .add(Duration(hours: 1)),
          );
          print(
              'Event Details: ${event.title}, ${event.description}, ${event.start}, ${event.end}');
          final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
          print(
              'Create or Update Event Result for ${calendar.name}: ${result?.data}');
          if (result?.isSuccess == false) {
            print(
                'Error creating or updating event for ${calendar.name}: ${result?.data}');
          }
        }
      } else {
        print('No calendars available or failed to retrieve calendars');
      }
    } on PlatformException catch (e) {
      print('Error adding event to calendar: $e');
    }
  }

  //  Future<void> _deleteFromCalendar(Yahrtzeit yahrtzeit) async {
  //   try {
  //     final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  //     if (calendarsResult?.isSuccess == true &&
  //         calendarsResult?.data!.isNotEmpty == true) {
  //       for (var calendar in calendarsResult!.data!) {
  //         final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
  //           calendar.id!,
  //           RetrieveEventsParams(
  //             startDate:
  //                 tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
  //             endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
  //           ),
  //         );
  //         if (eventsResult?.isSuccess == true &&
  //             eventsResult?.data!.isNotEmpty == true) {
  //           for (var event in eventsResult!.data!) {
  //             if (event.description?.startsWith(
  //                     'Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})') ==
  //                 true) {
  //               await _deviceCalendarPlugin.deleteEvent(
  //                   calendar.id!, event.eventId!);
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } on PlatformException catch (e) {
  //     print('Error deleting event from calendar: $e');
  //   }
  // }

  Future<void> _deleteFromCalendar(Yahrtzeit yahrtzeit) async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted?.isSuccess == true &&
          permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted?.isSuccess == false ||
            permissionsGranted?.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult?.isSuccess == true &&
          calendarsResult?.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult!.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            dc.RetrieveEventsParams(
              startDate:
                  tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult?.isSuccess == true &&
              eventsResult?.data!.isNotEmpty == true) {
            for (var event in eventsResult!.data!) {
              if (event.title == yahrtzeit.englishName) {
                final result = await _deviceCalendarPlugin.deleteEvent(
                    calendar.id!, event.eventId!);
                if (result?.isSuccess == false) {
                  print(
                      'Error deleting event for ${calendar.name}: ${result?.data}');
                }
              }
            }
          }
        }
      }
    } on PlatformException catch (e) {
      print('Error deleting event from calendar: $e');
    }
  }

  List<YahrtzeitDate> nextMultiple(List<Yahrtzeit> yahrtzeits) {
    final dates = yahrtzeits
        .map((yahrtzeit) => YahrtzeitDate.fromYahrtzeit(yahrtzeit))
        .toList();
    dates.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    return dates;
  }

  String _extractHebrewName(String description) {
    final regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(description);
    return match != null ? match.group(1)! : 'Unknown';
  }

  String _extractEnglishName(String description) {
    final regex = RegExp(r'Group Yahrtzeit for (.*?) \(');
    final match = regex.firstMatch(description);
    return match != null ? match.group(1)! : 'Unknown';
  }

  bool _compareYahrtzeitLists(List<Yahrtzeit> list1, List<Yahrtzeit> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    for (var yahrtzeit in list1) {
      if (!list2.any((element) =>
          element.englishName == yahrtzeit.englishName &&
          element.hebrewName == yahrtzeit.hebrewName &&
          element.gregorianDate == yahrtzeit.gregorianDate)) {
        return false;
      }
    }
    return true;
  }

  DateTime _getNextGregorianDate(int day, int month) {
    try {
      final now = DateTime.now();
      final jewishDate = kj.JewishDate();
      final hebrewYear = kj.JewishDate.fromDateTime(now).getJewishYear() +
          1; // Always use next Hebrew year
      // final hebrewYear = kj.JewishDate.fromDateTime(now).getJewishYear() ; // Always use next Hebrew year

      jewishDate.setJewishDate(hebrewYear, month, day);
      final gregorianDate = jewishDate.getGregorianCalendar();

      print('Next Year Gregorian Date: $gregorianDate');
      return gregorianDate;
    } catch (e) {
      print('Error converting date: $e');
      throw ArgumentError('Invalid Hebrew date provided.');
    }
  }
}
