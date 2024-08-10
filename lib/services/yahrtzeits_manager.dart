import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import 'package:kosher_dart/kosher_dart.dart' as kj;
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
                );
                if (!_yahrtzeits.any((y) =>
                    y.englishName == yahrtzeit.englishName &&
                    y.hebrewName == yahrtzeit.hebrewName)) {
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
    await saveYahrtzeitsToPreferences(); // שמירה ל-SharedPreferences לאחר הסנכרון עם היומן
  }

  Future<void> saveYahrtzeitsToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonData =
        _yahrtzeits.map((yahrtzeit) => yahrtzeit.toJson()).toList();
    await prefs.setString('yahrtzeit_data', json.encode(jsonData));
  }

  Future<void> loadYahrtzeitsFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    if (jsonString != null) {
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      _yahrtzeits.clear();
      _yahrtzeits
          .addAll(jsonData.map((data) => Yahrtzeit.fromJson(data)).toList());
    }
  }

  Future<void> addYahrtzeit(
      Yahrtzeit yahrtzeit, int yearsToSync, bool syncSettings) async {
    await loadYahrtzeitsFromPreferences();
    if (!_yahrtzeits.any((y) =>
        y.englishName == yahrtzeit.englishName &&
        y.hebrewName == y.hebrewName &&
        y.day == yahrtzeit.day &&
        y.month == yahrtzeit.month)) {
      final newYahrtzeit = Yahrtzeit(
        englishName: yahrtzeit.englishName,
        hebrewName: yahrtzeit.hebrewName,
        day: yahrtzeit.day,
        month: yahrtzeit.month,
      );
      _yahrtzeits.add(newYahrtzeit);
      // if (syncSettings) {
      //   await _addToCalendar(newYahrtzeit, yearsToSync);
      // }
      await saveYahrtzeitsToPreferences(); // שמור את הנתונים ב-SharedPreferences
      print('Yahrtzeit added: ${newYahrtzeit.englishName}');
    } else {
      print('Yahrtzeit already exists: ${yahrtzeit.englishName}');
    }
    print('Current yahrtzeits: ${_yahrtzeits.length}');
  }

  Future<void> updateYahrtzeit(Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit,
      int yearsToSync, bool syncSettings) async {
    await deleteYahrtzeit(oldYahrtzeit); // מחיקת היארצייט הישן
    await addYahrtzeit(
        newYahrtzeit, yearsToSync, syncSettings); // הוספת היארצייט החדש
    print('Yahrtzeit updated: ${newYahrtzeit.englishName}');
  }

  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await loadYahrtzeitsFromPreferences();
      _yahrtzeits.removeWhere((y) =>
          y.englishName == yahrtzeit.englishName &&
          y.hebrewName == y.hebrewName &&
          y.day == yahrtzeit.day &&
          y.month == yahrtzeit.month);
      await saveYahrtzeitsToPreferences(); // עדכן את הנתונים ב-SharedPreferences
      await _deleteFromCalendar(yahrtzeit);
      print('Yahrtzeit deleted: ${yahrtzeit.englishName}');
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
    }
  }

  Future<List<Yahrtzeit>> getAllYahrtzeits() async {
    await loadYahrtzeitsFromPreferences(); // טען את הנתונים מ-SharedPreferences
    print('All yahrtzeits fetched: ${_yahrtzeits.length}');
    return _yahrtzeits;
  }

  Future<List<String>> getAllGroups() async {
    await loadYahrtzeitsFromPreferences(); // טען את הנתונים מ-SharedPreferences
    Set<String> uniqueGroups = {};
    for (var yahrtzeit in _yahrtzeits) {
      if (yahrtzeit.group != null && yahrtzeit.group!.isNotEmpty) {
        uniqueGroups.add(yahrtzeit.group!);
      }
    }
    return uniqueGroups.toList();
  }

  Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 1000}) async {
    await loadYahrtzeitsFromPreferences(); // טען את הנתונים מ-SharedPreferences
    final now = tz.TZDateTime.now(tz.local);
    final upcomingYahrtzeits = _yahrtzeits.where((yahrtzeit) {
      final yahrtzeitDate =
          tz.TZDateTime.from(yahrtzeit.getGregorianDate()!, tz.local);
      final isUpcoming = yahrtzeitDate.isAfter(now) &&
          yahrtzeitDate.isBefore(now.add(Duration(days: days)));
      print(
          'Yahrtzeit: ${yahrtzeit.englishName}, Date: $yahrtzeitDate, Is upcoming: $isUpcoming');
      return isUpcoming;
    }).toList();
    print('Upcoming yahrtzeits fetched: ${upcomingYahrtzeits.length}');
    return upcomingYahrtzeits;
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

  List<YahrtzeitDate> filterUpcomingByMonths(
      List<YahrtzeitDate> yahrtzeits, int months) {
    final futureDate = DateTime(
      DateTime.now().year,
      (DateTime.now().month + months),
      DateTime.now().day,
    );

    // סינון התאריכים לפי התאריך הגרגוריאני
    final filteredDates = yahrtzeits.where((yahrtzeitDate) {
      final gregorianDate = yahrtzeitDate.gregorianDate;
      if (gregorianDate != null) {
        return gregorianDate.isBefore(futureDate);
      }
      return false;
    }).toList();

    filteredDates.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));

    return filteredDates;
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
          element.hebrewName == yahrtzeit.hebrewName)) {
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

  Future<List<Event>> fetchYahrtzeitManagerEvents() async {
    List<Event> yahrtzeitManagerEvents = [];

    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          print('Calendar permissions not granted');
          return yahrtzeitManagerEvents;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        for (var calendar in calendarsResult.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            RetrieveEventsParams(
              startDate:
                  tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult.isSuccess && eventsResult.data != null) {
            for (var event in eventsResult.data!) {
              if (event.description?.startsWith('Yahrtzeit Manager') == true) {
                yahrtzeitManagerEvents.add(event);
              }
            }
          }
        }
      } else {
        print('No calendars available or failed to retrieve calendars');
      }
    } on PlatformException catch (e) {
      print('Error fetching events: $e');
    }

    return yahrtzeitManagerEvents;
  }

  // פונקציה שבודקת אם ישנו אירוע תואם
  bool exists(Yahrtzeit yahrtzeit, String hebrewDate, List<Event> events) {
    for (Event event in events) {
      String? summary = event.title;
      String? description = event.description;
      if (summary == null ||
          description == null ||
          summary.isEmpty ||
          description.isEmpty) continue;

      if (isMatchingYahrtzeitEvent(summary, yahrtzeit, hebrewDate) ||
          isMatchingYahrtzeitEvent(description, yahrtzeit, hebrewDate)) {
        return true;
      }
    }
    return false;
  }

  bool isMatchingYahrtzeitEvent(
      String summary, Yahrtzeit yahrtzeit, String hebrewDate) {
    final String englishName = yahrtzeit.englishName ?? '';
    final String hebrewName = yahrtzeit.hebrewName ?? '';

    return summary.contains(englishName) ||
        summary.contains(hebrewName) ||
        summary.contains(hebrewDate);
  }

  Future<void> syncYahrtzeits(
      List<Yahrtzeit> yahrtzeits, int yearsToSync) async {
    List<Event> yahrtzeitManagerEvents = await fetchYahrtzeitManagerEvents();

    for (Yahrtzeit yahrtzeit in yahrtzeits) {
      bool existsInCalendar = false;

      for (int i = 0; i < yearsToSync; i++) {
        int year = JewishDate().getJewishYear() + i;
        JewishDate jewishDate = JewishDate.initDate(
            jewishYear: year,
            jewishMonth: yahrtzeit.month!,
            jewishDayOfMonth: yahrtzeit.day!);
        String hebrewDate =
            "${jewishDate.getJewishYear()}-${jewishDate.getJewishMonth()}-${jewishDate.getJewishDayOfMonth()}";

        if (exists(yahrtzeit, hebrewDate, yahrtzeitManagerEvents)) {
          existsInCalendar = true;
          break;
        }
      }

      if (!existsInCalendar) {
        await _addToCalendar(yahrtzeit, yearsToSync);
      }
    }
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
          // Retrieve existing events to check for duplicates
          final existingEventsResult =
              await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            dc.RetrieveEventsParams(
              startDate:
                  tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );

          List<Event> existingEvents = [];
          if (existingEventsResult?.isSuccess == true &&
              existingEventsResult?.data != null) {
            existingEvents = existingEventsResult!.data!;
          }

          for (int i = 0; i < yearsToSync; i++) {
            int year = JewishDate().getJewishYear() + i;
            JewishDate jewishDate = JewishDate.initDate(
                jewishYear: year,
                jewishMonth: yahrtzeit.month!,
                jewishDayOfMonth: yahrtzeit.day!);
            DateTime gregorianDate = DateTime(
                jewishDate.getGregorianYear(),
                jewishDate.getGregorianMonth(),
                jewishDate.getGregorianDayOfMonth());
            final event = dc.Event(
              calendar.id!,
              title: 'Yahrtzeit: ${yahrtzeit.englishName}',
              description:
                  'Hebrew Name: ${yahrtzeit.hebrewName}, Date: ${jewishDate.getJewishDayOfMonth()}-${jewishDate.getJewishMonth()}-${jewishDate.getJewishYear()}',
              start: tz.TZDateTime.from(gregorianDate, tz.local),
              end: tz.TZDateTime.from(gregorianDate, tz.local)
                  .add(Duration(hours: 1)),
            );

            if (!exists(
                yahrtzeit,
                '${jewishDate.getJewishDayOfMonth()}-${jewishDate.getJewishMonth()}-${jewishDate.getJewishYear()}',
                existingEvents)) {
              final result =
                  await _deviceCalendarPlugin.createOrUpdateEvent(event);
              if (result?.isSuccess == false) {
                print(
                    'Error creating or updating event for ${calendar.name}: ${result?.data}');
              }
            }
          }
        }
      }
    } on PlatformException catch (e) {
      print('Error adding event to calendar: $e');
    }
  }

  void onSyncButtonPressed(List<Yahrtzeit> yahrtzeits, int yearsToSync) async {
    await syncYahrtzeits(yahrtzeits, yearsToSync);
  }
}
