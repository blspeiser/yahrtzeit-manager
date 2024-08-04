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

//   Future<void> createGroup(String groupName, List<Yahrtzeit> yahrtzeits) async {
//     final newGroup = Group(name: groupName, yahrtzeits: yahrtzeits);
//     _groups.add(newGroup);
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