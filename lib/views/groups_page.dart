// import 'package:flutter/material.dart';
// import '../localizations/app_localizations.dart';
// import '../models/yahrtzeit.dart';
// import '../models/group.dart';
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
//               content: Container(
//                 width: double.maxFinite,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       onChanged: (value) {
//                         groupName = value;
//                       },
//                       decoration: InputDecoration(labelText: 'Group Name'),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: selectedYahrtzeits.length,
//                         itemBuilder: (context, index) {
//                           final yahrtzeit = selectedYahrtzeits[index];
//                           return CheckboxListTile(
//                             title: Text(yahrtzeit.englishName),
//                             subtitle: Text(yahrtzeit.hebrewName),
//                             value: yahrtzeit.selected,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 yahrtzeit.selected = value ?? false;
//                               });
//                             },
//                           );
//                         },
//                       ),
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

//   void _editGroup(Group group) async {
//     String groupName = group.name;
//     final selectedYahrtzeits = List<Yahrtzeit>.from(group.yahrtzeits);
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Edit Group'),
//               content: Container(
//                 width: double.maxFinite,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       onChanged: (value) {
//                         groupName = value;
//                       },
//                       decoration: InputDecoration(labelText: 'Group Name', hintText: group.name),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: selectedYahrtzeits.length,
//                         itemBuilder: (context, index) {
//                           final yahrtzeit = selectedYahrtzeits[index];
//                           return CheckboxListTile(
//                             title: Text(yahrtzeit.englishName),
//                             subtitle: Text(yahrtzeit.hebrewName),
//                             value: yahrtzeit.selected,
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 yahrtzeit.selected = value ?? false;
//                               });
//                             },
//                           );
//                         },
//                       ),
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
//                     await manager.updateGroup(group.name, groupName, selectedYahrtzeits.where((y) => y.selected).toList());
//                     fetchGroups();
//                     Navigator.pop(context);
//                   },
//                   child: Text('Save Changes'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _deleteGroup(Group group) async {
//     await manager.deleteGroup(group.name);
//     fetchGroups();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:  Text(AppLocalizations.of(context)!.translate('Groups')),
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
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             _editGroup(group);
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             _deleteGroup(group);
//                           },
//                         ),
//                       ],
//                     ),
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

import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/group.dart';
import '../services/yahrtzeits_manager.dart';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final fetchedGroups = await manager.getGroups();
    setState(() {
      groups = fetchedGroups;
    });
  }

  void _createGroup() async {
    String groupName = '';
    final selectedYahrtzeits = await manager.getAllYahrtzeits();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create New Group'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        groupName = value;
                      },
                      decoration: InputDecoration(labelText: 'Group Name'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedYahrtzeits.length,
                        itemBuilder: (context, index) {
                          final yahrtzeit = selectedYahrtzeits[index];
                          return CheckboxListTile(
                            title: Text(yahrtzeit.englishName),
                            subtitle: Text(yahrtzeit.hebrewName),
                            value: yahrtzeit.selected,
                            onChanged: (bool? value) {
                              setState(() {
                                yahrtzeit.selected = value ?? false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await manager.createGroup(groupName, selectedYahrtzeits.where((y) => y.selected).toList());
                    fetchGroups();
                    Navigator.pop(context);
                  },
                  child: Text('Create Group'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _editGroup(Group group) async {
  String groupName = group.name;
  final selectedYahrtzeits = List<Yahrtzeit>.from(group.yahrtzeits);
  
  // Get all Yahrtzeits that are not in the group
  final allYahrtzeits = await manager.getAllYahrtzeits();
  final notInGroup = allYahrtzeits.where((y) =>
    !selectedYahrtzeits.any((groupYahrtzeit) => 
      groupYahrtzeit.englishName == y.englishName &&
      groupYahrtzeit.hebrewName == y.hebrewName
    )
  ).toList();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Group'),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      groupName = value;
                    },
                    decoration: InputDecoration(labelText: 'Group Name', hintText: group.name),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        // Yahrtzeits already in the group
                        Expanded(
                          child: ListView.builder(
                            itemCount: selectedYahrtzeits.length,
                            itemBuilder: (context, index) {
                              final yahrtzeit = selectedYahrtzeits[index];
                              return CheckboxListTile(
                                title: Text(yahrtzeit.englishName),
                                subtitle: Text(yahrtzeit.hebrewName),
                                value: yahrtzeit.selected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    yahrtzeit.selected = value ?? false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        // Divider to separate the lists
                        Divider(),
                        // Yahrtzeits not in the group
                        Expanded(
                          child: ListView.builder(
                            itemCount: notInGroup.length,
                            itemBuilder: (context, index) {
                              final yahrtzeit = notInGroup[index];
                              return CheckboxListTile(
                                title: Text(yahrtzeit.englishName),
                                subtitle: Text(yahrtzeit.hebrewName),
                                value: yahrtzeit.selected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    yahrtzeit.selected = value ?? false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final selected = selectedYahrtzeits.where((y) => y.selected).toList();
                  final notInGroupSelected = notInGroup.where((y) => y.selected).toList();
                  await manager.updateGroup(group.name, groupName, selected + notInGroupSelected);
                  fetchGroups();
                  Navigator.pop(context);
                },
                child: Text('Save Changes'),
              ),
            ],
          );
        },
      );
    },
  );
}



  void _deleteGroup(Group group) async {
    await manager.deleteGroup(group.name);
    fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title:  Text(AppLocalizations.of(context)!.translate('Groups')),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: groups.isEmpty
          ? Center(child: Text('No groups created yet.'))
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text('${group.yahrtzeits.length} yahrtzeits'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroupDetailsPage(group: group)),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editGroup(group);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteGroup(group);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class GroupDetailsPage extends StatelessWidget {
  final Group group;

  GroupDetailsPage({required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: ListView.builder(
        itemCount: group.yahrtzeits.length,
        itemBuilder: (context, index) {
          final yahrtzeit = group.yahrtzeits[index];
          return ListTile(
            title: Text(yahrtzeit.englishName),
            subtitle: Text(yahrtzeit.hebrewName),
          );
        },
      ),
    );
  }
}
