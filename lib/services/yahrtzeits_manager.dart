import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import 'package:kosher_dart/kosher_dart.dart' as kj;
import 'package:device_calendar/device_calendar.dart' as dc;

class YahrtzeitsManager {
  static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
  final List<Yahrtzeit> _yahrtzeits = []; // In-memory storage
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

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
                  // year: event.start!.year,
                  // gregorianDate: event.start!,
                );
                if (!_yahrtzeits.any((y) =>
                        y.englishName == yahrtzeit.englishName &&
                        y.hebrewName == yahrtzeit.hebrewName
                    // && y.gregorianDate == yahrtzeit.gregorianDate
                    )) {
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

  Future<void> addYahrtzeit(Yahrtzeit yahrtzeit, int yearsToSync, bool syncSettings) async {
    if (!_yahrtzeits.any((y) =>
            y.englishName == yahrtzeit.englishName &&
            y.hebrewName == y.hebrewName &&
            y.day == yahrtzeit.day &&
            y.month == yahrtzeit.month
        // && y.gregorianDate == yahrtzeit.gregorianDate
        )) {
      final newYahrtzeit = Yahrtzeit(
        englishName: yahrtzeit.englishName,
        hebrewName: yahrtzeit.hebrewName,
        day: yahrtzeit.day,
        month: yahrtzeit.month,
        // year: yahrtzeit.year,
        // gregorianDate: yahrtzeit.gregorianDate,
      );
      _yahrtzeits.add(newYahrtzeit);
      if(syncSettings){
        await _addToCalendar(newYahrtzeit, yearsToSync);
      }
      
      print('Yahrtzeit added: ${newYahrtzeit.englishName}');
    } else {
      print('Yahrtzeit already exists: ${yahrtzeit.englishName}');
    }
    print('Current yahrtzeits: ${_yahrtzeits.length}');
  }

  Future<void> updateYahrtzeit(
      Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit, int yearsToSync, bool syncSettings) async {
    await deleteYahrtzeit(oldYahrtzeit); // מחיקת היארצייט הישן
    await addYahrtzeit(newYahrtzeit, yearsToSync, syncSettings); // הוספת היארצייט החדש
    await getUpcomingYahrtzeits();
    print('Yahrtzeit updated: ${newYahrtzeit.englishName}');
  }

  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      final nextYearGregorianDate =
          _getNextGregorianDate(yahrtzeit.day, yahrtzeit.month);
      _yahrtzeits.removeWhere((y) =>
              y.englishName == yahrtzeit.englishName &&
              y.hebrewName == y.hebrewName &&
              y.day == yahrtzeit.day &&
              y.month == y.month
          // && y.gregorianDate == nextYearGregorianDate
          );
      await _deleteFromCalendar(yahrtzeit);
      await getUpcomingYahrtzeits();
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

  Future<List<String>> getAllGroups() async {
    await syncWithCalendar(); // Ensure the Yahrtzeits are up-to-date
    Set<String> uniqueGroups = {};
    for (var yahrtzeit in _yahrtzeits) {
      if (yahrtzeit.group != null && yahrtzeit.group!.isNotEmpty) {
        uniqueGroups.add(yahrtzeit.group!);
      }
    }
    return uniqueGroups.toList();
  }

  Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 1000}) async {
    final allYahrtzeits = await getAllYahrtzeits();
    final now = tz.TZDateTime.now(tz.local);
    final upcomingYahrtzeits = allYahrtzeits.where((yahrtzeit) {
      final yahrtzeitDate =
          tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local);
      final isUpcoming = yahrtzeitDate.isAfter(now) &&
          yahrtzeitDate.isBefore(now.add(Duration(days: days)));
      print(
          'Yahrtzeit: ${yahrtzeit.englishName}, Date: $yahrtzeitDate, Is upcoming: $isUpcoming');
      return isUpcoming;
    }).toList();
    print('Upcoming yahrtzeits fetched: ${upcomingYahrtzeits.length}');
    return upcomingYahrtzeits;
  }

  Future<void> _addToCalendar(Yahrtzeit yahrtzeit, int yearsToSync) async {
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
          // final gregorianDate = DateTime(
          //   yahrtzeit.gregorianDate.year,
          //   yahrtzeit.gregorianDate.month,
          //   yahrtzeit.gregorianDate.day,
          // );
          for (int i = 0; i < yearsToSync; i++) {
            int year = JewishDate().getJewishYear() + i;
            JewishDate jewishDate = JewishDate.initDate(
                jewishYear: year,
                jewishMonth: yahrtzeit.month,
                jewishDayOfMonth: yahrtzeit.day);
            DateTime gregorianDate = DateTime(
                jewishDate.getGregorianYear(),
                jewishDate.getGregorianMonth(),
                jewishDate.getGregorianDayOfMonth());
            final event = dc.Event(
              calendar.id!,
              title: 'Yahrtzeit: ${yahrtzeit.englishName}',
              description: '${yahrtzeit.hebrewName}',
              start: tz.TZDateTime.from(gregorianDate, tz.local),
              end: tz.TZDateTime.from(gregorianDate, tz.local)
                  .add(Duration(hours: 1)),
            );
            final result =
                await _deviceCalendarPlugin.createOrUpdateEvent(event);
            if (result?.isSuccess == false) {
              print(
                  'Error creating or updating event for ${calendar.name}: ${result?.data}');
            }
          }
        }
      }
    } on PlatformException catch (e) {
      print('Error adding event to calendar: $e');
    }
  }

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
    print(
        'Sorted yahrtzeit dates: ${dates.map((d) => d.gregorianDate).toList()}');
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
              element.hebrewName == yahrtzeit.hebrewName
          // && element.gregorianDate == yahrtzeit.gregorianDate
          )) {
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
