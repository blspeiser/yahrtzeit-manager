import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../models/sync_result.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';

class YahrtzeitsManager {
  static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
  final List<Yahrtzeit> _yahrtzeits = []; // In-memory storage
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final NotificationService _notificationService = NotificationService();

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

  Future<SyncResult> syncWithCalendar() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && permissionsGranted.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted.isSuccess == false ||
            permissionsGranted.data == false) {
          return SyncResult.failure('Calendar permissions not granted');
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess &&
          calendarsResult.data!.isNotEmpty == true) {
        final existingYahrtzeits = List<Yahrtzeit>.from(_yahrtzeits);
        _yahrtzeits.clear();
        int syncedCount = 0;

        for (var calendar in calendarsResult.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            dc.RetrieveEventsParams(
              startDate:
                  tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult.isSuccess && eventsResult.data!.isNotEmpty == true) {
            for (var event in eventsResult.data!) {
              // Improved matching: check title pattern and description
              if ((event.title?.contains('Yahrtzeit') == true ||
                      event.title?.startsWith('Yahrtzeit:') == true) &&
                  event.description != null) {
                final hebrewName = _extractHebrewNameFromEvent(event);
                final englishName = _extractEnglishNameFromEvent(event);

                if (hebrewName.isNotEmpty) {
                  // Try to get Hebrew date from event
                  final jewishDate = _extractJewishDateFromEvent(event);

                  final yahrtzeit = Yahrtzeit(
                    englishName: englishName,
                    hebrewName: hebrewName,
                    day: jewishDate != null
                        ? jewishDate.getJewishDayOfMonth()
                        : event.start!.day,
                    month: jewishDate != null
                        ? jewishDate.getJewishMonth()
                        : event.start!.month,
                  );

                  // Check if already exists by ID or by name+date combination
                  if (!_yahrtzeits.any((y) =>
                      (y.id == yahrtzeit.id) ||
                      (y.englishName == yahrtzeit.englishName &&
                          y.hebrewName == yahrtzeit.hebrewName &&
                          y.day == yahrtzeit.day &&
                          y.month == yahrtzeit.month))) {
                    _yahrtzeits.add(yahrtzeit);
                    syncedCount++;
                  }
                }
              }
            }
          }
        }

        // Merge with existing yahrtzeits that weren't found in calendar
        for (var existing in existingYahrtzeits) {
          if (!_yahrtzeits.any((y) => y.id == existing.id)) {
            _yahrtzeits.add(existing);
          }
        }

        await saveYahrtzeitsToPreferences();
        return SyncResult.success(
          syncedCount,
          'Synced $syncedCount yahrtzeits from calendar',
        );
      } else {
        return SyncResult.failure(
          'No calendars available or failed to retrieve calendars',
        );
      }
    } on PlatformException catch (e) {
      print('Error syncing with calendar: $e');
      return SyncResult.failure('Error syncing with calendar: $e');
    }
  }

  Future<void> saveYahrtzeitsToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonData =
        _yahrtzeits.map((yahrtzeit) => yahrtzeit.toJson()).toList();
    await prefs.setString('yahrtzeit_data', json.encode(jsonData));
  }

  // Public method to load yahrtzeits from preferences
  Future<void> loadYahrtzeitsFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    print(
        'DEBUG: loadYahrtzeitsFromPreferences - jsonString is null: ${jsonString == null}');
    if (jsonString != null) {
      print(
          'DEBUG: loadYahrtzeitsFromPreferences - jsonString length: ${jsonString.length}');
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      print(
          'DEBUG: loadYahrtzeitsFromPreferences - decoded ${jsonData.length} yahrtzeits');
      _yahrtzeits.clear();
      _yahrtzeits
          .addAll(jsonData.map((data) => Yahrtzeit.fromJson(data)).toList());
      print(
          'DEBUG: loadYahrtzeitsFromPreferences - loaded ${_yahrtzeits.length} yahrtzeits into memory');
    } else {
      print(
          'DEBUG: loadYahrtzeitsFromPreferences - no data found in SharedPreferences');
      _yahrtzeits.clear();
    }
  }

  Future<void> addYahrtzeit(
      Yahrtzeit yahrtzeit, int yearsToSync, bool syncSettings,
      {bool notificationsEnabled = false, int daysBefore = 10}) async {
    await loadYahrtzeitsFromPreferences();
    // Check for duplicates by ID first, then by name+date
    if (!_yahrtzeits.any((y) =>
        y.id == yahrtzeit.id ||
        ((y.englishName?.toLowerCase().trim() ?? '') ==
                (yahrtzeit.englishName?.toLowerCase().trim() ?? '') &&
            (y.hebrewName?.toLowerCase().trim() ?? '') ==
                (yahrtzeit.hebrewName?.toLowerCase().trim() ?? '') &&
            y.day == yahrtzeit.day &&
            y.month == yahrtzeit.month))) {
      final newYahrtzeit = Yahrtzeit(
        englishName: yahrtzeit.englishName,
        hebrewName: yahrtzeit.hebrewName,
        day: yahrtzeit.day,
        month: yahrtzeit.month,
        group: yahrtzeit.group,
        id: yahrtzeit.id, // Preserve the ID
      );
      _yahrtzeits.add(newYahrtzeit);
      if (syncSettings) {
        await _addToCalendar(newYahrtzeit, yearsToSync);
      }
      await saveYahrtzeitsToPreferences();

      // Schedule notifications if enabled
      if (notificationsEnabled) {
        await _notificationService
            .scheduleYahrtzeitNotifications([newYahrtzeit], daysBefore, true);
      }

      print('Yahrtzeit added: ${newYahrtzeit.englishName}');
    } else {
      print('Yahrtzeit already exists: ${yahrtzeit.englishName}');
    }
    print('Current yahrtzeits: ${_yahrtzeits.length}');
  }

  Future<void> rescheduleAllNotifications(
      bool notificationsEnabled, int daysBefore) async {
    await loadYahrtzeitsFromPreferences();
    await _notificationService.scheduleYahrtzeitNotifications(
        _yahrtzeits, daysBefore, notificationsEnabled);
  }

  Future<void> updateYahrtzeit(Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit,
      int yearsToSync, bool syncSettings,
      {bool notificationsEnabled = false, int daysBefore = 10}) async {
    await loadYahrtzeitsFromPreferences();
    // Find and update the existing yahrtzeit
    final index = _yahrtzeits.indexWhere((y) => y.id == oldYahrtzeit.id);
    if (index != -1) {
      // Cancel old notifications
      await _notificationService.cancelYahrtzeitNotifications(oldYahrtzeit.id);

      // Delete from calendar if synced
      if (syncSettings) {
        await _deleteFromCalendar(oldYahrtzeit);
      }

      // Update the yahrtzeit
      _yahrtzeits[index] = newYahrtzeit;

      // Add to calendar if synced
      if (syncSettings) {
        await _addToCalendar(newYahrtzeit, yearsToSync);
      }

      // Save to preferences
      await saveYahrtzeitsToPreferences();

      // Schedule new notifications if enabled
      if (notificationsEnabled) {
        await _notificationService
            .scheduleYahrtzeitNotifications([newYahrtzeit], daysBefore, true);
      }

      print('Yahrtzeit updated: ${newYahrtzeit.englishName}');
    }
  }

  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await loadYahrtzeitsFromPreferences();
      _yahrtzeits.removeWhere((y) => y.id == yahrtzeit.id);
      await saveYahrtzeitsToPreferences();
      await _deleteFromCalendar(yahrtzeit);
      await _notificationService.cancelYahrtzeitNotifications(yahrtzeit.id);
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
      if (permissionsGranted.isSuccess && permissionsGranted.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted.isSuccess == false ||
            permissionsGranted.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess &&
          calendarsResult.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult.data!) {
          for (int i = 0; i < yearsToSync; i++) {
            int year = JewishDate().getJewishYear() + i;

            // Handle Adar/Adar II in leap years and non-leap years
            int month = yahrtzeit.month!;
            if (month == JewishDate.ADAR) {
              // Check if this is a leap year
              final testDate = JewishDate.initDate(
                  jewishYear: year,
                  jewishMonth: JewishDate.ADAR,
                  jewishDayOfMonth: 1);
              if (testDate.getJewishMonth() == JewishDate.ADAR_II) {
                // In leap years, ADAR becomes ADAR_II
                month = JewishDate.ADAR_II;
              }
            } else if (month == JewishDate.ADAR_II) {
              // Check if this is a leap year
              final testDate = JewishDate.initDate(
                  jewishYear: year,
                  jewishMonth: JewishDate.ADAR,
                  jewishDayOfMonth: 1);
              if (testDate.getJewishMonth() != JewishDate.ADAR_II) {
                // Not a leap year, so ADAR_II should be treated as ADAR
                month = JewishDate.ADAR;
              }
            }

            JewishDate jewishDate = JewishDate.initDate(
                jewishYear: year,
                jewishMonth: month,
                jewishDayOfMonth: yahrtzeit.day!);
            DateTime gregorianDate = DateTime(
                jewishDate.getGregorianYear(),
                jewishDate.getGregorianMonth(),
                jewishDate.getGregorianDayOfMonth());

            // Enhanced description with ID for better matching
            final description =
                'Yahrtzeit for ${yahrtzeit.englishName ?? "Unknown"} (${yahrtzeit.hebrewName})\nID: ${yahrtzeit.id}';

            final event = dc.Event(
              calendar.id!,
              title:
                  'Yahrtzeit: ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}',
              description: description,
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
      if (permissionsGranted.isSuccess && permissionsGranted.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted.isSuccess == false ||
            permissionsGranted.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess &&
          calendarsResult.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            dc.RetrieveEventsParams(
              startDate:
                  tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult.isSuccess && eventsResult.data!.isNotEmpty == true) {
            for (var event in eventsResult.data!) {
              // Improved matching: check ID in description or match by name pattern
              final eventId = _extractIdFromEvent(event);
              final matchesTitle =
                  event.title?.contains(yahrtzeit.englishName ?? '') == true ||
                      (yahrtzeit.hebrewName != null &&
                          event.title?.contains(yahrtzeit.hebrewName!) == true);
              final matchesId = eventId == yahrtzeit.id;

              if (matchesId ||
                  (matchesTitle &&
                      yahrtzeit.hebrewName != null &&
                      event.description?.contains(yahrtzeit.hebrewName!) ==
                          true)) {
                final result = await _deviceCalendarPlugin.deleteEvent(
                    calendar.id!, event.eventId!);
                if (result.isSuccess == false) {
                  print(
                      'Error deleting event for ${calendar.name}: ${result.data}');
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
    final dates = <YahrtzeitDate>[];
    for (var yahrtzeit in yahrtzeits) {
      // Skip yahrtzeits without day/month (incomplete entries)
      if (yahrtzeit.day == null || yahrtzeit.month == null) {
        continue;
      }
      // Validate month and day before attempting conversion
      // Jewish months are 1-12, or 13 (Adar II) in leap years
      if (yahrtzeit.month! < 1 || yahrtzeit.month! > 13) {
        print(
            'WARNING: Skipping yahrtzeit ${yahrtzeit.englishName ?? yahrtzeit.hebrewName} - invalid month ${yahrtzeit.month}');
        continue;
      }
      if (yahrtzeit.day! < 1 || yahrtzeit.day! > 30) {
        print(
            'WARNING: Skipping yahrtzeit ${yahrtzeit.englishName ?? yahrtzeit.hebrewName} - invalid day ${yahrtzeit.day}');
        continue;
      }
      try {
        dates.add(YahrtzeitDate.fromYahrtzeit(yahrtzeit));
      } catch (e) {
        print(
            'ERROR: Failed to convert yahrtzeit ${yahrtzeit.englishName ?? yahrtzeit.hebrewName} to date: $e');
      }
    }
    dates.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    print(
        'Sorted yahrtzeit dates: ${dates.map((d) => d.gregorianDate).toList()}');
    return dates;
  }

  String _extractHebrewNameFromEvent(dc.Event event) {
    if (event.description == null) return '';
    // Try to extract Hebrew name from description
    // Format: "Yahrtzeit for EnglishName (HebrewName)\nID: ..."
    final regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(event.description!);
    return match != null ? match.group(1)! : '';
  }

  String _extractEnglishNameFromEvent(dc.Event event) {
    if (event.title == null) return '';
    // Extract from title: "Yahrtzeit: EnglishName"
    if (event.title!.startsWith('Yahrtzeit:')) {
      return event.title!.substring('Yahrtzeit:'.length).trim();
    }
    return event.title!;
  }

  String? _extractIdFromEvent(dc.Event event) {
    if (event.description == null) return null;
    // Extract ID from description: "ID: ..."
    final regex = RegExp(r'ID:\s*([^\n]+)');
    final match = regex.firstMatch(event.description!);
    return match != null ? match.group(1)!.trim() : null;
  }

  JewishDate? _extractJewishDateFromEvent(dc.Event event) {
    // Try to extract Jewish date if stored in event metadata
    // For now, convert from Gregorian date
    if (event.start == null) return null;
    try {
      return JewishDate.fromDateTime(event.start!);
    } catch (e) {
      return null;
    }
  }
}
