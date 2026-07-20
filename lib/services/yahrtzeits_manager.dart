import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kosher_dart/kosher_dart.dart' hide Calendar;
import 'dart:convert';
import 'dart:io' show Platform;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../models/sync_result.dart';
import '../widgets/permission_rationale_dialog.dart';
import 'notification_service.dart';

class YahrtzeitsManager {
  static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
  final List<Yahrtzeit> _yahrtzeits = [];
  final DeviceCalendar _calendarPlugin = DeviceCalendar.instance;
  final NotificationService _notificationService = NotificationService();

  factory YahrtzeitsManager() {
    return _instance;
  }

  YahrtzeitsManager._internal();

  /// Selects the appropriate calendar based on the user's preference setting.
  /// Returns null if no suitable calendar is found.
  Future<Calendar?> _selectCalendarForSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final calendarSetting = prefs.getString('calendar') ?? 'google';

    final calendars = await _calendarPlugin.listCalendars();
    if (calendars.isEmpty) {
      debugPrint('DEBUG SYNC: No calendars available');
      return null;
    }

    final writableCalendars = calendars.where((cal) => !cal.readOnly).toList();
    if (writableCalendars.isEmpty) {
      debugPrint('DEBUG SYNC: No writable calendars found');
      return null;
    }

    debugPrint('DEBUG SYNC: Found ${writableCalendars.length} writable calendars, preference: $calendarSetting');

    Calendar? selectedCalendar;

    if (calendarSetting == 'google') {
      // User wants Google Calendar specifically
      final googleCalendars = writableCalendars.where((cal) {
        final accountType = cal.accountType?.toLowerCase() ?? '';
        return accountType.contains('google');
      }).toList();

      if (googleCalendars.isNotEmpty) {
        // Prefer the primary Google calendar, otherwise first Google calendar
        selectedCalendar = googleCalendars.firstWhere(
          (cal) => cal.isPrimary,
          orElse: () => googleCalendars.first,
        );
      } else {
        debugPrint('DEBUG SYNC: No Google calendar found, falling back to first writable');
        selectedCalendar = writableCalendars.first;
      }
    } else {
      // User wants device/local calendar
      if (Platform.isIOS) {
        final localCalendars = writableCalendars.where((cal) {
          final accountType = cal.accountType?.toLowerCase() ?? '';
          return accountType.contains('local') || accountType.isEmpty;
        }).toList();
        selectedCalendar = localCalendars.isNotEmpty
            ? localCalendars.first
            : writableCalendars.first;
      } else {
        // On Android, prefer non-Google calendars
        final nonGoogleCalendars = writableCalendars.where((cal) {
          final accountType = cal.accountType?.toLowerCase() ?? '';
          return !accountType.contains('google');
        }).toList();
        selectedCalendar = nonGoogleCalendars.isNotEmpty
            ? nonGoogleCalendars.first
            : writableCalendars.first;
      }
    }

    debugPrint('DEBUG SYNC: Selected calendar: "${selectedCalendar.name}" (${selectedCalendar.accountName ?? "unknown"})');
    return selectedCalendar;
  }

  /// Ensures calendar permissions are granted, requesting if needed.
  /// Returns true if permissions are granted.
  ///
  /// When [showRationale] is true and the permission has not yet been decided,
  /// an informative dialog explaining why calendar access is needed is shown
  /// *before* the OS prompt (a Google Play requirement). Background/cleanup
  /// callers leave it false so they never surface a dialog.
  Future<bool> _ensureCalendarPermissions({bool showRationale = false}) async {
    var status = await _calendarPlugin.hasPermissions();
    if (status == CalendarPermissionStatus.granted) return true;

    if (status == CalendarPermissionStatus.notDetermined) {
      if (showRationale) {
        final proceed = await showPermissionRationaleDialog(
          titleKey: 'calendar_permission_title',
          messageKey: 'calendar_permission_rationale',
          icon: Icons.calendar_month_outlined,
        );
        if (!proceed) return false;
      }
      status = await _calendarPlugin.requestPermissions();
    }

    return status == CalendarPermissionStatus.granted;
  }

  /// Syncs local yahrtzeits to the calendar (ONE-WAY: app -> calendar only).
  Future<SyncResult> syncWithCalendar() async {
    debugPrint('DEBUG SYNC: Starting syncWithCalendar() - ONE-WAY sync (app -> calendar)');
    try {
      if (!await _ensureCalendarPermissions(showRationale: true)) {
        debugPrint('DEBUG SYNC: Calendar permissions not granted');
        return SyncResult.failure('Calendar permissions not granted');
      }

      final selectedCalendar = await _selectCalendarForSetting();
      if (selectedCalendar == null) {
        return SyncResult.failure(
          'No suitable calendar found. Please ensure you have at least one writable calendar available.',
        );
      }

      debugPrint('DEBUG SYNC: Selected calendar: "${selectedCalendar.name}", ID: ${selectedCalendar.id}');

      await loadYahrtzeitsFromPreferences();
      debugPrint('DEBUG SYNC: Loaded ${_yahrtzeits.length} local yahrtzeits');

      final prefs = await SharedPreferences.getInstance();
      final yearsToSync = prefs.getInt('years') ?? 5;

      if (_yahrtzeits.isEmpty) {
        return SyncResult.success(0, 'No yahrtzeits to sync');
      }

      int syncedCount = 0;
      int skippedCount = 0;

      for (var yahrtzeit in _yahrtzeits) {
        if (yahrtzeit.day == null || yahrtzeit.month == null) {
          skippedCount++;
          continue;
        }

        try {
          await _addToCalendar(yahrtzeit, yearsToSync, selectedCalendar);
          syncedCount++;
        } catch (e) {
          debugPrint('DEBUG SYNC: Error syncing "${yahrtzeit.englishName ?? yahrtzeit.hebrewName}": $e');
          skippedCount++;
        }
      }

      await saveYahrtzeitsToPreferences();

      debugPrint('DEBUG SYNC: Completed. Synced $syncedCount, skipped $skippedCount');
      return SyncResult.success(syncedCount, 'Synced $syncedCount yahrtzeits to calendar');
    } catch (e, stackTrace) {
      debugPrint('DEBUG SYNC: Exception: $e');
      debugPrint('DEBUG SYNC: Stack trace: $stackTrace');
      return SyncResult.failure('Error syncing with calendar: $e');
    }
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
    } else {
      _yahrtzeits.clear();
    }
  }

  Future<void> addYahrtzeit(
      Yahrtzeit yahrtzeit, int yearsToSync, bool syncSettings,
      {bool notificationsEnabled = false, int daysBefore = 10}) async {
    await loadYahrtzeitsFromPreferences();
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
        id: yahrtzeit.id,
      );
      _yahrtzeits.add(newYahrtzeit);

      if (syncSettings) {
        final calendar = await _selectCalendarForSetting();
        if (calendar != null) {
          await _addToCalendar(newYahrtzeit, yearsToSync, calendar);
        }
      }

      await saveYahrtzeitsToPreferences();

      if (notificationsEnabled) {
        await _notificationService
            .scheduleYahrtzeitNotifications([newYahrtzeit], daysBefore, true);
      }
    }
  }

  Future<void> rescheduleAllNotifications(
      bool notificationsEnabled, int daysBefore,
      {bool forcePermissionPrompt = false}) async {
    await loadYahrtzeitsFromPreferences();
    // Cancel all existing notifications before doing a full reschedule
    await _notificationService.cancelAllNotifications();
    await _notificationService.scheduleYahrtzeitNotifications(
        _yahrtzeits, daysBefore, notificationsEnabled,
        forcePermissionPrompt: forcePermissionPrompt);
  }

  Future<void> updateYahrtzeit(Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit,
      int yearsToSync, bool syncSettings,
      {bool notificationsEnabled = false, int daysBefore = 10}) async {
    await loadYahrtzeitsFromPreferences();
    final index = _yahrtzeits.indexWhere((y) => y.id == oldYahrtzeit.id);
    if (index != -1) {
      await _notificationService.cancelYahrtzeitNotifications(oldYahrtzeit.id);

      if (syncSettings) {
        await _deleteFromCalendar(oldYahrtzeit);
      }

      _yahrtzeits[index] = newYahrtzeit;

      if (syncSettings) {
        final calendar = await _selectCalendarForSetting();
        if (calendar != null) {
          await _addToCalendar(newYahrtzeit, yearsToSync, calendar);
        }
      }

      await saveYahrtzeitsToPreferences();

      if (notificationsEnabled) {
        await _notificationService
            .scheduleYahrtzeitNotifications([newYahrtzeit], daysBefore, true);
      }
    }
  }

  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await loadYahrtzeitsFromPreferences();
      _yahrtzeits.removeWhere((y) => y.id == yahrtzeit.id);
      await saveYahrtzeitsToPreferences();

      // Only delete from calendar if sync is enabled
      final prefs = await SharedPreferences.getInstance();
      final syncEnabled = prefs.getBool('syncSettings') ?? true;
      if (syncEnabled) {
        await _deleteFromCalendar(yahrtzeit);
      }

      await _notificationService.cancelYahrtzeitNotifications(yahrtzeit.id);
    } catch (e) {
      debugPrint('Error deleting yahrtzeit: $e');
    }
  }

  Future<List<Yahrtzeit>> getAllYahrtzeits() async {
    await loadYahrtzeitsFromPreferences();
    return _yahrtzeits;
  }

  Future<List<String>> getAllGroups() async {
    await loadYahrtzeitsFromPreferences();
    Set<String> uniqueGroups = {};
    for (var yahrtzeit in _yahrtzeits) {
      if (yahrtzeit.group != null && yahrtzeit.group!.isNotEmpty) {
        uniqueGroups.add(yahrtzeit.group!);
      }
    }
    return uniqueGroups.toList();
  }

  Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 1000}) async {
    await loadYahrtzeitsFromPreferences();
    final now = DateTime.now();
    final upcomingYahrtzeits = _yahrtzeits.where((yahrtzeit) {
      if (yahrtzeit.day == null || yahrtzeit.month == null) {
        return false;
      }
      try {
        final yahrtzeitDate = yahrtzeit.getGregorianDate();
        return yahrtzeitDate.isAfter(now) &&
            yahrtzeitDate.isBefore(now.add(Duration(days: days)));
      } catch (e) {
        return false;
      }
    }).toList();
    return upcomingYahrtzeits;
  }

  Future<void> _addToCalendar(Yahrtzeit yahrtzeit, int yearsToSync, Calendar calendar) async {
    if (yahrtzeit.day == null || yahrtzeit.month == null) return;

    if (!await _ensureCalendarPermissions(showRationale: true)) return;

    final newEventIds = <String>[];

    for (int i = 0; i < yearsToSync; i++) {
      int year = JewishDate().getJewishYear() + i;

      int month = yahrtzeit.month!;
      if (month == JewishDate.ADAR) {
        final testDate = JewishDate.initDate(
            jewishYear: year, jewishMonth: JewishDate.ADAR, jewishDayOfMonth: 1);
        if (testDate.getJewishMonth() == JewishDate.ADAR_II) {
          month = JewishDate.ADAR_II;
        }
      } else if (month == JewishDate.ADAR_II) {
        final testDate = JewishDate.initDate(
            jewishYear: year, jewishMonth: JewishDate.ADAR, jewishDayOfMonth: 1);
        if (testDate.getJewishMonth() != JewishDate.ADAR_II) {
          month = JewishDate.ADAR;
        }
      }

      try {
        JewishDate jewishDate = JewishDate.initDate(
            jewishYear: year, jewishMonth: month, jewishDayOfMonth: yahrtzeit.day!);
        DateTime gregorianDate = DateTime(
            jewishDate.getGregorianYear(),
            jewishDate.getGregorianMonth(),
            jewishDate.getGregorianDayOfMonth());

        final description =
            'Yahrtzeit for ${yahrtzeit.englishName ?? "Unknown"} (${yahrtzeit.hebrewName ?? ""})\nID: ${yahrtzeit.id}';

        final eventId = await _calendarPlugin.createEvent(
          calendarId: calendar.id,
          title: 'Yahrtzeit: ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}',
          startDate: gregorianDate,
          endDate: gregorianDate.add(Duration(days: 1)),
          isAllDay: true,
          description: description,
        );

        newEventIds.add(eventId);
      } catch (e) {
        debugPrint('Error creating calendar event for year $year: $e');
      }
    }

    // Store the created event IDs on the yahrtzeit for future deletion
    yahrtzeit.calendarEventIds.addAll(newEventIds);
  }

  Future<void> _deleteFromCalendar(Yahrtzeit yahrtzeit) async {
    if (!await _ensureCalendarPermissions()) return;

    // First, try to delete by stored event IDs (reliable path)
    if (yahrtzeit.calendarEventIds.isNotEmpty) {
      for (final eventId in yahrtzeit.calendarEventIds) {
        try {
          await _calendarPlugin.deleteEvent(eventId: eventId);
        } catch (e) {
          debugPrint('DEBUG SYNC: Could not delete event $eventId: $e');
        }
      }
      yahrtzeit.calendarEventIds.clear();
      return;
    }

    // Fallback: search by title/description for events created before event ID tracking
    try {
      final selectedCalendar = await _selectCalendarForSetting();
      if (selectedCalendar == null) return;

      final prefs = await SharedPreferences.getInstance();
      final yearsToSync = prefs.getInt('years') ?? 5;
      final searchWindow = 365 * yearsToSync;

      final now = DateTime.now();
      final events = await _calendarPlugin.listEvents(
        now.subtract(Duration(days: 365)),
        now.add(Duration(days: searchWindow)),
        calendarIds: [selectedCalendar.id],
      );

      for (var event in events) {
        final matchesId = event.description?.contains('ID: ${yahrtzeit.id}') ?? false;
        final matchesTitle = event.title.contains(yahrtzeit.englishName ?? '') ||
            (yahrtzeit.hebrewName != null &&
                event.title.contains(yahrtzeit.hebrewName!));

        if (matchesId || (matchesTitle && (event.description?.contains(yahrtzeit.hebrewName ?? '') ?? false))) {
          try {
            await _calendarPlugin.deleteEvent(eventId: event.instanceId);
          } catch (e) {
            debugPrint('DEBUG SYNC: Could not delete event ${event.instanceId}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting events from calendar: $e');
    }
  }

  List<YahrtzeitDate> nextMultiple(List<Yahrtzeit> yahrtzeits) {
    final dates = <YahrtzeitDate>[];
    for (var yahrtzeit in yahrtzeits) {
      if (yahrtzeit.day == null || yahrtzeit.month == null) {
        continue;
      }
      if (yahrtzeit.month! < 1 || yahrtzeit.month! > 13) {
        continue;
      }
      if (yahrtzeit.day! < 1 || yahrtzeit.day! > 30) {
        continue;
      }
      try {
        dates.add(YahrtzeitDate.fromYahrtzeit(yahrtzeit));
      } catch (e) {
        // Skip invalid dates
      }
    }
    dates.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    return dates;
  }
}
