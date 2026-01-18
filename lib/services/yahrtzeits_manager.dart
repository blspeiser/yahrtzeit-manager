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
import 'dart:io' show Platform;
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

  /// Selects the main calendar to use for syncing.
  /// Filters for writable, visible calendars and prefers the user's default/primary calendar.
  /// Returns null if no suitable calendar is found.
  Future<dc.Calendar?> _selectMainCalendar() async {
    print('DEBUG SYNC: Starting calendar selection...');

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess ||
        calendarsResult.data == null ||
        calendarsResult.data!.isEmpty) {
      print('DEBUG SYNC: No calendars available for selection');
      return null;
    }

    final allCalendars = calendarsResult.data!;
    print('DEBUG SYNC: Found ${allCalendars.length} calendars');

    // Filter calendars: must be writable and not read-only
    final writableCalendars = allCalendars.where((cal) {
      final isReadOnly = cal.isReadOnly ?? false;
      return !isReadOnly;
    }).toList();

    print('DEBUG SYNC: ${writableCalendars.length} writable calendars found');

    if (writableCalendars.isEmpty) {
      print('DEBUG SYNC: No writable calendars found');
      return null;
    }

    // Platform-specific selection logic
    dc.Calendar? selectedCalendar;

    if (Platform.isIOS) {
      // Prefer calendars from common account types (user's own accounts)
      final userAccountCalendars = writableCalendars.where((cal) {
        final accountType = cal.accountType?.toLowerCase() ?? '';
        return accountType.contains('local') ||
            accountType.contains('google') ||
            accountType.isEmpty;
      }).toList();

      selectedCalendar = userAccountCalendars.isNotEmpty
          ? userAccountCalendars.first
          : writableCalendars.first;
    } else if (Platform.isAndroid) {
      // Prefer primary calendar (user's own account, not shared)
      final primaryCandidates = writableCalendars.where((cal) {
        final accountName = cal.accountName?.toLowerCase() ?? '';
        final accountType = cal.accountType?.toLowerCase() ?? '';
        return !accountName.contains('shared') &&
            !accountName.contains('subscription') &&
            (accountType.contains('google') || accountType.isEmpty);
      }).toList();

      selectedCalendar = primaryCandidates.isNotEmpty
          ? primaryCandidates.first
          : writableCalendars.first;
    } else {
      selectedCalendar = writableCalendars.first;
    }

    print(
        'DEBUG SYNC: Selected calendar: "${selectedCalendar.name}" (${selectedCalendar.accountName})');

    return selectedCalendar;
  }

  /// Syncs local yahrtzeits to the calendar (ONE-WAY: app → calendar only).
  /// This method does NOT read from the calendar or modify local data.
  /// It only ensures that all local yahrtzeits are present in the calendar.
  Future<SyncResult> syncWithCalendar() async {
    print(
        'DEBUG SYNC: Starting syncWithCalendar() - ONE-WAY sync (app → calendar)');
    try {
      print('DEBUG SYNC: Checking calendar permissions...');
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      print(
          'DEBUG SYNC: Initial permission check - isSuccess: ${permissionsGranted.isSuccess}, data: ${permissionsGranted.data}');
      if (permissionsGranted.isSuccess && permissionsGranted.data == false) {
        print('DEBUG SYNC: Permissions not granted, requesting...');
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        print(
            'DEBUG SYNC: Permission request result - isSuccess: ${permissionsGranted.isSuccess}, data: ${permissionsGranted.data}');
        if (permissionsGranted.isSuccess == false ||
            permissionsGranted.data == false) {
          print('DEBUG SYNC: Calendar permissions not granted, aborting sync');
          return SyncResult.failure('Calendar permissions not granted');
        }
      }
      print('DEBUG SYNC: Permissions granted, proceeding with sync');

      // Select the main calendar to use
      final selectedCalendar = await _selectMainCalendar();
      if (selectedCalendar == null) {
        print('DEBUG SYNC: No suitable calendar found for syncing');
        return SyncResult.failure(
          'No suitable calendar found. Please ensure you have at least one writable calendar available.',
        );
      }

      print(
          'DEBUG SYNC: Selected calendar for sync - Name: "${selectedCalendar.name}", ID: ${selectedCalendar.id}');

      // Load local yahrtzeits from preferences (DO NOT clear or modify them!)
      await loadYahrtzeitsFromPreferences();
      print(
          'DEBUG SYNC: Loaded ${_yahrtzeits.length} local yahrtzeits from storage');

      // Get years setting from SharedPreferences (default: 5)
      final prefs = await SharedPreferences.getInstance();
      final yearsToSync = prefs.getInt('years') ?? 5;
      print(
          'DEBUG SYNC: Will sync ${yearsToSync} years of events for each yahrtzeit');

      if (_yahrtzeits.isEmpty) {
        print('DEBUG SYNC: No local yahrtzeits to sync');
        return SyncResult.success(
          0,
          'No yahrtzeits to sync',
        );
      }

      // Sync each local yahrtzeit to the calendar
      int syncedCount = 0;
      int skippedCount = 0;

      for (var yahrtzeit in _yahrtzeits) {
        // Skip yahrtzeits without required data
        if (yahrtzeit.day == null || yahrtzeit.month == null) {
          print(
              'DEBUG SYNC: Skipping yahrtzeit "${yahrtzeit.englishName ?? yahrtzeit.hebrewName}" - missing day or month');
          skippedCount++;
          continue;
        }

        try {
          // Use the existing _addToCalendar method to sync this yahrtzeit
          await _addToCalendar(yahrtzeit, yearsToSync);
          syncedCount++;
          print(
              'DEBUG SYNC: Synced "${yahrtzeit.englishName ?? yahrtzeit.hebrewName}" (group: ${yahrtzeit.group ?? "none"}) to calendar');
        } catch (e) {
          print(
              'DEBUG SYNC: Error syncing yahrtzeit "${yahrtzeit.englishName ?? yahrtzeit.hebrewName}": $e');
          skippedCount++;
        }
      }

      print(
          'DEBUG SYNC: Sync completed successfully. Synced $syncedCount yahrtzeits to calendar "${selectedCalendar.name}", skipped $skippedCount');

      // IMPORTANT: Do NOT save yahrtzeits to preferences - we didn't modify them!
      // Local data remains unchanged.

      return SyncResult.success(
        syncedCount,
        'Synced $syncedCount yahrtzeits to calendar',
      );
    } on PlatformException catch (e) {
      print('DEBUG SYNC: PlatformException during sync: $e');
      return SyncResult.failure('Error syncing with calendar: $e');
    } catch (e, stackTrace) {
      print('DEBUG SYNC: Unexpected exception during sync: $e');
      print('DEBUG SYNC: Stack trace: $stackTrace');
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
    }
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
    }
  }

  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await loadYahrtzeitsFromPreferences();
      _yahrtzeits.removeWhere((y) => y.id == yahrtzeit.id);
      await saveYahrtzeitsToPreferences();
      await _deleteFromCalendar(yahrtzeit);
      await _notificationService.cancelYahrtzeitNotifications(yahrtzeit.id);
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
    }
  }

  Future<List<Yahrtzeit>> getAllYahrtzeits() async {
    await loadYahrtzeitsFromPreferences(); // טען את הנתונים מ-SharedPreferences
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
      return isUpcoming;
    }).toList();
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

      // Select the main calendar to use
      final selectedCalendar = await _selectMainCalendar();
      if (selectedCalendar == null) {
        print('DEBUG SYNC: No suitable calendar found for adding events');
        return;
      }

      print(
          'DEBUG SYNC: Selected calendar for adding events - Name: "${selectedCalendar.name}", ID: ${selectedCalendar.id}');

      // Add events only to the selected calendar
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
          selectedCalendar.id!,
          title: 'Yahrtzeit: ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}',
          description: description,
          start: tz.TZDateTime.from(gregorianDate, tz.local),
          end: tz.TZDateTime.from(gregorianDate, tz.local)
              .add(Duration(hours: 1)),
        );
        await _deviceCalendarPlugin.createOrUpdateEvent(event);
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

      // Select the main calendar to use
      final selectedCalendar = await _selectMainCalendar();
      if (selectedCalendar == null) {
        print('DEBUG SYNC: No suitable calendar found for deleting events');
        return;
      }

      print(
          'DEBUG SYNC: Selected calendar for deleting events - Name: "${selectedCalendar.name}", ID: ${selectedCalendar.id}');

      // Search for and delete events only from the selected calendar
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        selectedCalendar.id!,
        dc.RetrieveEventsParams(
          startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
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
                  event.description?.contains(yahrtzeit.hebrewName!) == true)) {
            await _deviceCalendarPlugin.deleteEvent(
                selectedCalendar.id!, event.eventId!);
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

  String? _extractIdFromEvent(dc.Event event) {
    if (event.description == null) return null;
    // Extract ID from description: "ID: ..."
    final regex = RegExp(r'ID:\s*([^\n]+)');
    final match = regex.firstMatch(event.description!);
    return match != null ? match.group(1)!.trim() : null;
  }
}
