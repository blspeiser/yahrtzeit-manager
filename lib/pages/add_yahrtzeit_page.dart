// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import '../model/yahrtzeit.dart';

// class AddYahrtzeitPage extends StatefulWidget {
//   @override
//   _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
// }

// class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _hebrewNameController = TextEditingController();
//   final _foreignNameController = TextEditingController();
//   final _gregorianDateController = TextEditingController();
//   final _hebrewDateController = TextEditingController();
//   final _tombPlaceController = TextEditingController();

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     return File('$path/yahrtzeit.json');
//   }

//   // Future<File> writeData(Yahrtzeit yahrtzeit) async {
//   //   final file = await _localFile;
//   //   return file.writeAsString(json.encode(yahrtzeit.toJson()));
//   // }

//   // void _submitForm() {
//   //   if (_formKey.currentState!.validate()) {
//   //     _formKey.currentState!.save();
//   //     Yahrtzeit yahrtzeit = Yahrtzeit(
//   //       hebrewName: _hebrewNameController.text,
//   //       foreignName: _foreignNameController.text,
//   //       gregorianDate: _gregorianDateController.text,
//   //       hebrewDate: _hebrewDateController.text,
//   //       tombPlace: _tombPlaceController.text,
//   //     );
//   //     writeData(yahrtzeit);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Data saved!')),
//   //     );
//   //   }
//   // }

//   Future<File> writeData(Yahrtzeit yahrtzeit) async {
//     try {
//       final file = await _localFile;
//       List<Yahrtzeit> yahrtzeits = [];

//       if (await file.exists()) {
//         String contents = await file.readAsString();
//         List<dynamic> jsonData;
//         try {
//           jsonData = json.decode(contents);
//         } catch (e) {
//           jsonData = [];
//         }
//         if (jsonData is List<dynamic>) {
//           yahrtzeits = jsonData.map((item) => Yahrtzeit.fromJson(item)).toList();
//         } else {
//           // Handle case where the file content is not a list (initial state)
//           yahrtzeits = [];
//         }
//       }

//       yahrtzeits.add(yahrtzeit);

//       return file.writeAsString(json.encode(yahrtzeits.map((e) => e.toJson()).toList()));
//     } catch (e) {
//       print('Error writing file: $e');
//       rethrow;
//     }
//   }

//  Future<void> readData() async {
//     try {
//       final file = await _localFile;
//       if (await file.exists()) {
//         String contents = await file.readAsString();
//         print('File path: ${file.path}');
//         print('File contents: $contents');
//       } else {
//         print('File does not exist');
//       }
//     } catch (e) {
//       print('Error reading file: $e');
//     }
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       Yahrtzeit yahrtzeit = Yahrtzeit(
//         hebrewName: _hebrewNameController.text,
//         foreignName: _foreignNameController.text,
//         gregorianDate: _gregorianDateController.text,
//         hebrewDate: _hebrewDateController.text,
//         tombPlace: _tombPlaceController.text,
//       );
//       writeData(yahrtzeit).then((_) {
//         readData();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Data saved!')),
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Yahrtzeit'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               TextFormField(
//                 controller: _hebrewNameController,
//                 decoration: InputDecoration(labelText: 'Hebrew Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the Hebrew name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _foreignNameController,
//                 decoration: InputDecoration(labelText: 'Foreign Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the Foreign name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _gregorianDateController,
//                 decoration: InputDecoration(labelText: 'Gregorian Date'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the Gregorian date';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _hebrewDateController,
//                 decoration: InputDecoration(labelText: 'Hebrew Date'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the Hebrew date';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _tombPlaceController,
//                 decoration: InputDecoration(labelText: 'Tomb Place'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the Tomb place';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../model/yahrtzeit.dart';

class AddYahrtzeitPage extends StatefulWidget {
  @override
  _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
}

class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
  final _formKey = GlobalKey<FormState>();
  final _hebrewNameController = TextEditingController();
  final _foreignNameController = TextEditingController();
  final _gregorianDateController = TextEditingController();
  final _hebrewDateController = TextEditingController();
  final _tombPlaceController = TextEditingController();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/yahrtzeit.json');
  }

  Future<File> writeData(Yahrtzeit yahrtzeit) async {
    try {
      final file = await _localFile;
      List<Yahrtzeit> yahrtzeits = [];

      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonData;
        try {
          jsonData = json.decode(contents);
        } catch (e) {
          jsonData = [];
        }
        if (jsonData is List<dynamic>) {
          yahrtzeits = jsonData.map((item) => Yahrtzeit.fromJson(item)).toList();
        } else {
          yahrtzeits = [];
        }
      }

      yahrtzeits.add(yahrtzeit);
      return file.writeAsString(json.encode(yahrtzeits.map((e) => e.toJson()).toList()));
    } catch (e) {
      print('Error writing file: $e');
      rethrow;
    }
  }

  Future<void> readData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        print('File path: ${file.path}');
        print('File contents: $contents');
      } else {
        print('File does not exist');
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  Future<void> deleteYahrtzeit(int index) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonData = json.decode(contents);
        List<Yahrtzeit> yahrtzeits = jsonData.map((item) => Yahrtzeit.fromJson(item)).toList();
        yahrtzeits.removeAt(index);
        await file.writeAsString(json.encode(yahrtzeits.map((e) => e.toJson()).toList()));
      }
    } catch (e) {
      print('Error deleting Yahrtzeit: $e');
    }
  }

  // Future<void> exportYahrtzeits() async {
  //   try {
  //     final file = await _localFile;
  //     if (await file.exists()) {
  //       Share.shareFiles([file.path], text: 'Yahrtzeit data');
  //     } else {
  //       print('File does not exist');
  //     }
  //   } catch (e) {
  //     print('Error exporting file: $e');
  //   }
  // }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Yahrtzeit yahrtzeit = Yahrtzeit(
        hebrewName: _hebrewNameController.text,
        foreignName: _foreignNameController.text,
        gregorianDate: _gregorianDateController.text,
        hebrewDate: _hebrewDateController.text,
        tombPlace: _tombPlaceController.text,
      );
      writeData(yahrtzeit).then((_) {
        readData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved!')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Yahrtzeit'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.share),
        //     onPressed: exportYahrtzeits,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _hebrewNameController,
                decoration: InputDecoration(labelText: 'Hebrew Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Hebrew name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _foreignNameController,
                decoration: InputDecoration(labelText: 'Foreign Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Foreign name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _gregorianDateController,
                decoration: InputDecoration(labelText: 'Gregorian Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Gregorian date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewDateController,
                decoration: InputDecoration(labelText: 'Hebrew Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Hebrew date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tombPlaceController,
                decoration: InputDecoration(labelText: 'Tomb Place'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Tomb place';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
