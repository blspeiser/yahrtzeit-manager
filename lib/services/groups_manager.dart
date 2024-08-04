// import 'package:device_calendar/device_calendar.dart';
// import 'package:flutter/services.dart';
// import 'package:timezone/timezone.dart' as tz;
// import '../models/yahrtzeit.dart';
// import '../models/yahrtzeit_date.dart';
// import '../models/group.dart';

// class GroupsManager{
//   final List<Group> _groups = []; // In-memory storage for groups

//   Future<List<Group>> getGroups() async {
//     return _groups;
//   }

//   Future<void> createGroup(String groupName, ) async {
//     // final newGroup = Group(name: groupName, yahrtzeits: yahrtzeits);
//     // _groups.add(newGroup);
//   }

//   Future<void> addYahrtzeitToGroup(String groupName, Yahrtzeit yahrtzeit) async {
//     final index = _groups.indexWhere((g) => g.name == groupName);
//     if (index != -1) {
//       _groups[index].yahrtzeits.add(yahrtzeit);
//     } else {
//       final newGroup = Group(name: groupName, yahrtzeits: [yahrtzeit]);
//       print('newGroup: ${newGroup.name} ');
//       _groups.add(newGroup);
//       print('after adding: ${_groups.length} ');
    
//     }
//   }

//   Future<void> updateGroup(
//       String oldName, String newName, List<Yahrtzeit> yahrtzeits) async {
//     final index = _groups.indexWhere((g) => g.name == oldName);
//     if (index != -1) {
//       _groups[index] = Group(name: newName, yahrtzeits: yahrtzeits);
//     }
//   }

//   Future<void> deleteGroup(String name) async {
//     final group = _groups.firstWhere((group) => group.name == name);
//     _groups.remove(group);
//   }
// }

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../models/group.dart';

class GroupsManager {
  final List<Group> _groups = []; // In-memory storage for groups

  Future<List<Group>> getGroups() async {
    return _groups;
  }

  Future<void> createGroup(String groupName) async {
    if (_groups.any((group) => group.name == groupName)) {
      print('Group $groupName already exists.');
    } else {
      final newGroup = Group(name: groupName, yahrtzeits: []);
      _groups.add(newGroup);
      print('Group $groupName created.');
    }
  }

  Future<void> addYahrtzeitToGroup(String groupName, Yahrtzeit yahrtzeit) async {
    final index = _groups.indexWhere((g) => g.name == groupName);
    if (index != -1) {
      _groups[index].yahrtzeits.add(yahrtzeit);
      print('Yahrtzeit added to group $groupName.');
    } else {
      final newGroup = Group(name: groupName, yahrtzeits: [yahrtzeit]);
      _groups.add(newGroup);
      print('Group $groupName created and yahrtzeit added.');
    }
  }

  Future<void> updateGroup(
      String oldName, String newName, List<Yahrtzeit> yahrtzeits) async {
    final index = _groups.indexWhere((g) => g.name == oldName);
    if (index != -1) {
      _groups[index] = Group(name: newName, yahrtzeits: yahrtzeits);
      print('Group $oldName updated to $newName.');
    } else {
      print('Group $oldName not found.');
    }
  }

  Future<void> deleteGroup(String name) async {
    final group = _groups.firstWhere((group) => group.name == name);
    _groups.remove(group);
    print('Group $name deleted.');
  }

  void printGroups() {
    for (var group in _groups) {
      print('Group: ${group.name}');
      for (var yahrtzeit in group.yahrtzeits) {
        print('  - Yahrtzeit: ${yahrtzeit.englishName} (${yahrtzeit.hebrewName})');
      }
    }
  }
}
