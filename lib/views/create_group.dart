// import 'package:flutter/material.dart';
// import '../models/yahrtzeit.dart';
// import '../models/group.dart'; // Import the Group class
// import '../services/yahrtzeits_manager.dart';

// class GroupsPage extends StatefulWidget {
//   @override
//   _GroupsPageState createState() => _GroupsPageState();
// }

// class _GroupsPageState extends State<GroupsPage> {
//   final YahrtzeitsManager manager = YahrtzeitsManager();
//   List<Group> groups = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchGroups();
//   }

//   Future<void> fetchGroups() async {
//     final fetchedGroups = await manager.getGroups();
//     setState(() {
//       groups = fetchedGroups;
//     });
//   }

//   void _createGroup() async {
//     String groupName = '';
//     final selectedYahrtzeits = await manager.getAllYahrtzeits();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Create New Group'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       onChanged: (value) {
//                         groupName = value;
//                       },
//                       decoration: InputDecoration(labelText: 'Group Name'),
//                     ),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: selectedYahrtzeits.length,
//                       itemBuilder: (context, index) {
//                         final yahrtzeit = selectedYahrtzeits[index];
//                         return CheckboxListTile(
//                           title: Text(yahrtzeit.englishName),
//                           subtitle: Text(yahrtzeit.hebrewName),
//                           value: yahrtzeit.selected,
//                           onChanged: (bool? value) {
//                             setState(() {
//                               yahrtzeit.selected = value ?? false;
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await manager.createGroup(groupName, selectedYahrtzeits.where((y) => y.selected).toList());
//                     fetchGroups();
//                     Navigator.pop(context);
//                   },
//                   child: Text('Create Group'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Groups'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: _createGroup,
//           ),
//         ],
//       ),
//       body: groups.isEmpty
//           ? Center(child: Text('No groups created yet.'))
//           : ListView.builder(
//               itemCount: groups.length,
//               itemBuilder: (context, index) {
//                 final group = groups[index];
//                 return Card(
//                   elevation: 5,
//                   margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   child: ListTile(
//                     title: Text(group.name),
//                     subtitle: Text('${group.yahrtzeits.length} yahrtzeits'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => GroupDetailsPage(group: group)),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class GroupDetailsPage extends StatelessWidget {
//   final Group group;

//   GroupDetailsPage({required this.group});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(group.name),
//       ),
//       body: ListView.builder(
//         itemCount: group.yahrtzeits.length,
//         itemBuilder: (context, index) {
//           final yahrtzeit = group.yahrtzeits[index];
//           return ListTile(
//             title: Text(yahrtzeit.englishName),
//             subtitle: Text(yahrtzeit.hebrewName),
//           );
//         },
//       ),
//     );
//   }
// }
