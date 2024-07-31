// import 'package:device_calendar/device_calendar.dart';
// import 'package:flutter/services.dart';
// import 'package:timezone/timezone.dart' as tz;
// import '../models/yahrtzeit.dart';
// import '../models/yahrtzeit_date.dart';

// class YahrtzeitsManager {
//   static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
//   final List<Yahrtzeit> _yahrtzeits = []; // In-memory storage
//   final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

//   factory YahrtzeitsManager() {
//     return _instance;
//   }

//   YahrtzeitsManager._internal();

//   DeviceCalendarPlugin get deviceCalendarPlugin => _deviceCalendarPlugin;

//   Future<void> syncWithCalendar() async {
//     try {
//       var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
//       print('Permissions Granted: $permissionsGranted');
//       if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
//         permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
//         print('Requested Permissions: $permissionsGranted');
//         if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
//           print('Calendar permissions not granted');
//           return;
//         }
//       }

//       final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
//       print('Calendars Result: $calendarsResult');
//       if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
//         _yahrtzeits.clear();
//         for (var calendar in calendarsResult!.data!) {
//           print('Retrieving events from calendar: ${calendar.name}');
//           final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
//             calendar.id!,
//             RetrieveEventsParams(
//               startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
//               endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
//             ),
//           );
//           if (eventsResult?.isSuccess == true && eventsResult?.data!.isNotEmpty == true) {
//             for (var event in eventsResult!.data!) {
//               if (event.description?.startsWith('Yahrtzeit for') == true) {
//                 final hebrewName = _extractHebrewName(event.description!);
//                 final yahrtzeit = Yahrtzeit(
//                   englishName: event.title ?? 'Unknown',
//                   hebrewName: hebrewName,
//                   day: event.start!.day,
//                   month: event.start!.month,
//                   year: event.start!.year,
//                   gregorianDate: event.start!,
//                 );
//                 if (!_yahrtzeits.any((y) =>
//                     y.englishName == yahrtzeit.englishName &&
//                     y.hebrewName == yahrtzeit.hebrewName &&
//                     y.gregorianDate == yahrtzeit.gregorianDate)) {
//                   _yahrtzeits.add(yahrtzeit);
//                 }
//               }
//             }
//           }
//         }
//       } else {
//         print('No calendars available or failed to retrieve calendars');
//       }
//     } on PlatformException catch (e) {
//       print('Error syncing with calendar: $e');
//     }
//   }

//   Future<void> addYahrtzeit(Yahrtzeit yahrtzeit) async {
//     if (!_yahrtzeits.any((y) =>
//         y.englishName == yahrtzeit.englishName &&
//         y.hebrewName == yahrtzeit.hebrewName &&
//         y.gregorianDate == yahrtzeit.gregorianDate)) {
//       _yahrtzeits.add(yahrtzeit);
//       await _addToCalendar(yahrtzeit);
//     }
//   }

//   Future<List<Yahrtzeit>> getAllYahrtzeits() async {
//     await syncWithCalendar();
//     return _yahrtzeits;
//   }

//   Future<List<Yahrtzeit>> getUpcomingYahrtzeits({int days = 10}) async {
//     final allYahrtzeits = await getAllYahrtzeits();
//     final now = tz.TZDateTime.now(tz.local);
//     final upcomingYahrtzeits = allYahrtzeits.where((yahrtzeit) {
//       final yahrtzeitDate = tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local);
//       return yahrtzeitDate.isAfter(now) && yahrtzeitDate.isBefore(now.add(Duration(days: days)));
//     }).toList();
//     return upcomingYahrtzeits;
//   }

//   Future<void> _addToCalendar(Yahrtzeit yahrtzeit) async {
//     try {
//       var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
//       print('Permissions Granted: $permissionsGranted');
//       if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
//         permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
//         print('Requested Permissions: $permissionsGranted');
//         if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
//           print('Calendar permissions not granted');
//           return;
//         }
//       }

//       final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
//       print('Calendars Result: $calendarsResult');
//       if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
//         for (var calendar in calendarsResult!.data!) {
//           print('Adding event to calendar: ${calendar.name}');
//           final event = Event(
//             calendar.id!,
//             title: yahrtzeit.englishName,
//             description: 'Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})',
//             start: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local),
//             end: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local).add(Duration(hours: 1)),
//           );
//           print('Event Details: ${event.title}, ${event.description}, ${event.start}, ${event.end}');
//           final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
//           print('Create or Update Event Result for ${calendar.name}: ${result?.data}');
//           if (result?.isSuccess == false) {
//             print('Error creating or updating event for ${calendar.name}: ${result?.data}');
//           }
//         }
//       } else {
//         print('No calendars available or failed to retrieve calendars');
//       }
//     } on PlatformException catch (e) {
//       print('Error adding event to calendar: $e');
//     }
//   }

//   List<YahrtzeitDate> nextMultiple(List<Yahrtzeit> yahrtzeits) {
//     final dates = yahrtzeits.map((yahrtzeit) => YahrtzeitDate.fromYahrtzeit(yahrtzeit)).toList();
//     dates.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
//     return dates;
//   }

//   String _extractHebrewName(String description) {
//     final regex = RegExp(r'\((.*?)\)');
//     final match = regex.firstMatch(description);
//     return match != null ? match.group(1)! : 'Unknown';
//   }
// }


import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../models/group.dart';

class YahrtzeitsManager {
  static final YahrtzeitsManager _instance = YahrtzeitsManager._internal();
  final List<Yahrtzeit> _yahrtzeits = []; // In-memory storage
  final List<Group> _groups = []; // In-memory storage for groups
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  factory YahrtzeitsManager() {
    return _instance;
  }

  YahrtzeitsManager._internal();

  DeviceCalendarPlugin get deviceCalendarPlugin => _deviceCalendarPlugin;

  // Future<void> syncWithCalendar() async {
  //   try {
  //     var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
  //     if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
  //       permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
  //       if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
  //         return;
  //       }
  //     }

  //     final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  //     if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
  //       _yahrtzeits.clear();
  //       for (var calendar in calendarsResult!.data!) {
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
  //                   y.hebrewName == y.hebrewName &&
  //                   y.gregorianDate == y.gregorianDate)) {
  //                 _yahrtzeits.add(yahrtzeit);
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }

  //     await _loadGroupsFromCalendar(calendarsResult!.data!);
  //   } on PlatformException catch (e) {
  //     print('Error syncing with calendar: $e');
  //   }
  // }

  Future<void> syncWithCalendar() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
        _yahrtzeits.clear();
        for (var calendar in calendarsResult!.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            RetrieveEventsParams(
              startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult?.isSuccess == true && eventsResult?.data!.isNotEmpty == true) {
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
      }
    } catch (e) {
      print('Error syncing with calendar: $e');
    }
  }













  Future<void> _loadGroupsFromCalendar(List<Calendar> calendars) async {
    try {
      _groups.clear();
      for (var calendar in calendars) {
        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id!,
          RetrieveEventsParams(
            startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
            endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
          ),
        );
        if (eventsResult?.isSuccess == true && eventsResult?.data!.isNotEmpty == true) {
          final groupsMap = <String, List<Yahrtzeit>>{};
          for (var event in eventsResult!.data!) {
            if (event.description?.startsWith('Group Yahrtzeit for') == true) {
              final groupName = event.title ?? 'Unknown Group';
              final yahrtzeit = Yahrtzeit(
                englishName: _extractEnglishName(event.description!),
                hebrewName: _extractHebrewName(event.description!),
                day: event.start!.day,
                month: event.start!.month,
                year: event.start!.year,
                gregorianDate: event.start!,
              );
              if (groupsMap.containsKey(groupName)) {
                groupsMap[groupName]!.add(yahrtzeit);
              } else {
                groupsMap[groupName] = [yahrtzeit];
              }
            }
          }
          for (var entry in groupsMap.entries) {
            _groups.add(Group(name: entry.key, yahrtzeits: entry.value));
          }
        }
      }
    } on PlatformException catch (e) {
      print('Error loading groups from calendar: $e');
    }
  }

  // Future<void> addYahrtzeit(Yahrtzeit yahrtzeit) async {
  //   if (!_yahrtzeits.any((y) =>
  //       y.englishName == yahrtzeit.englishName &&
  //       y.hebrewName == y.hebrewName &&
  //       y.gregorianDate == y.gregorianDate)) {
  //     _yahrtzeits.add(yahrtzeit);
  //     await _addToCalendar(yahrtzeit);
  //   }
  // }

  Future<void> addYahrtzeit(Yahrtzeit yahrtzeit) async {
    _yahrtzeits.add(yahrtzeit);
  }




















  Future<void> deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    _yahrtzeits.removeWhere((y) =>
        y.englishName == yahrtzeit.englishName &&
        y.hebrewName == y.hebrewName &&
        y.gregorianDate == y.gregorianDate);
    await _deleteFromCalendar(yahrtzeit);
  }

  Future<void> updateYahrtzeit(Yahrtzeit oldYahrtzeit, Yahrtzeit newYahrtzeit) async {
    final index = _yahrtzeits.indexWhere((y) =>
        y.englishName == oldYahrtzeit.englishName &&
        y.hebrewName == oldYahrtzeit.hebrewName &&
        y.gregorianDate == oldYahrtzeit.gregorianDate);
    if (index != -1) {
      _yahrtzeits[index] = newYahrtzeit;
      await _deleteFromCalendar(oldYahrtzeit);
      await _addToCalendar(newYahrtzeit);
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
      final yahrtzeitDate = tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local);
      return yahrtzeitDate.isAfter(now) && yahrtzeitDate.isBefore(now.add(Duration(days: days)));
    }).toList();
    return upcomingYahrtzeits;
  }

  Future<void> _addToCalendar(Yahrtzeit yahrtzeit) async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult!.data!) {
          final event = Event(
            calendar.id!,
            title: yahrtzeit.englishName,
            description: 'Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})',
            start: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local),
            end: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local).add(Duration(hours: 1)),
          );
          final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
          if (result?.isSuccess == false) {
            print('Error creating or updating event for ${calendar.name}: ${result?.data}');
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
      if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult!.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            RetrieveEventsParams(
              startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult?.isSuccess == true && eventsResult?.data!.isNotEmpty == true) {
            for (var event in eventsResult!.data!) {
              if (event.title == yahrtzeit.englishName) {
                final result = await _deviceCalendarPlugin.deleteEvent(calendar.id!, event.eventId!);
                if (result?.isSuccess == false) {
                  print('Error deleting event for ${calendar.name}: ${result?.data}');
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

// Future<void> createGroup(String name, List<Yahrtzeit> yahrtzeits) async {
//   final existingGroup = _groups.firstWhere(
//     (group) => group.name == name && _compareYahrtzeitLists(group.yahrtzeits, yahrtzeits),
//     orElse: () => Group(name: '', yahrtzeits: []),
//   );

//   if (existingGroup.name == '' && existingGroup.yahrtzeits.isEmpty) {
//     final newGroup = Group(name: name, yahrtzeits: yahrtzeits);
//     _groups.add(newGroup);
//     await _addGroupToCalendar(newGroup);
//   }
// }

  Future<void> createGroup(String groupName, List<Yahrtzeit> yahrtzeits) async {
    final group = Group(name: groupName, yahrtzeits: yahrtzeits);
    _groups.add(group);
  }


  Future<void> updateGroup(String oldName, String newName, List<Yahrtzeit> yahrtzeits) async {
    final index = _groups.indexWhere((g) => g.name == oldName);
    if (index != -1) {
      _groups[index] = Group(name: newName, yahrtzeits: yahrtzeits);
    }
  }

  Future<void> deleteGroup(String name) async {
    final group = _groups.firstWhere((group) => group.name == name);
    _groups.remove(group);
    await _deleteGroupFromCalendar(group);
  }

  Future<void> _addGroupToCalendar(Group group) async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult!.data!) {
          for (var yahrtzeit in group.yahrtzeits) {
            final event = Event(
              calendar.id!,
              title: group.name,
              description: 'Group Yahrtzeit for ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})',
              start: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local),
              end: tz.TZDateTime.from(yahrtzeit.getGregorianDate(), tz.local).add(Duration(hours: 1)),
            );
            final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
            if (result?.isSuccess == false) {
              print('Error creating or updating event for ${calendar.name}: ${result?.data}');
            }
          }
        }
      }
    } on PlatformException catch (e) {
      print('Error adding group to calendar: $e');
    }
  }

  Future<void> _deleteGroupFromCalendar(Group group) async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted?.isSuccess == true && permissionsGranted?.data == false) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult?.isSuccess == true && calendarsResult?.data!.isNotEmpty == true) {
        for (var calendar in calendarsResult!.data!) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id!,
            RetrieveEventsParams(
              startDate: tz.TZDateTime.now(tz.local).subtract(Duration(days: 365)),
              endDate: tz.TZDateTime.now(tz.local).add(Duration(days: 365)),
            ),
          );
          if (eventsResult?.isSuccess == true && eventsResult?.data!.isNotEmpty == true) {
            for (var event in eventsResult!.data!) {
              if (event.title == group.name) {
                final result = await _deviceCalendarPlugin.deleteEvent(calendar.id!, event.eventId!);
                if (result?.isSuccess == false) {
                  print('Error deleting event for ${calendar.name}: ${result?.data}');
                }
              }
            }
          }
        }
      }
    } on PlatformException catch (e) {
      print('Error deleting group from calendar: $e');
    }
  }

  Future<List<Group>> getGroups() async {
    await syncWithCalendar();
    return _groups;
  }

  List<YahrtzeitDate> nextMultiple(List<Yahrtzeit> yahrtzeits) {
    final dates = yahrtzeits.map((yahrtzeit) => YahrtzeitDate.fromYahrtzeit(yahrtzeit)).toList();
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
    if (!list2.any((element) => element.englishName == yahrtzeit.englishName && element.hebrewName == yahrtzeit.hebrewName && element.gregorianDate == yahrtzeit.gregorianDate)) {
      return false;
    }
  }
  return true;
}

}
