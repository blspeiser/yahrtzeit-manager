// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import '../components/yahrtzeit_tile.dart';
// import '../model/yahrtzeit.dart';
// import 'package:share_plus/share_plus.dart';

// class YahrtzeitListPage extends StatefulWidget {

//    final bool isDarkMode;
//   final Function toggleDarkMode;

//   const YahrtzeitListPage({
//     required this.isDarkMode,
//     required this.toggleDarkMode,
//   });
//   @override
//   _YahrtzeitListPageState createState() => _YahrtzeitListPageState();
// }

// class _YahrtzeitListPageState extends State<YahrtzeitListPage> {
//   List<Yahrtzeit> _yahrtzeits = [];

//   @override
//   void initState() {
//     super.initState();
//     _readData();
//   }

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     return File('$path/yahrtzeit.json');
//   }

//   Future<void> _readData() async {
//     try {
//       final file = await _localFile;
//       if (await file.exists()) {
//         String contents = await file.readAsString();
//         List<dynamic> jsonData = json.decode(contents);
//         List<Yahrtzeit> yahrtzeits =
//             jsonData.map((item) => Yahrtzeit.fromJson(item)).toList();

//         setState(() {
//           _yahrtzeits = yahrtzeits;
//         });
//       } else {
//         print('File does not exist');
//       }
//     } catch (e) {
//       print('Error reading file: $e');
//     }
//   }

//   Future<void> exportYahrtzeits() async {
//     try {
//       final file = await _localFile;
//       if (await file.exists()) {
//         Share.shareFiles([file.path], text: 'Yahrtzeit data');
//       } else {
//         print('File does not exist');
//       }
//     } catch (e) {
//       print('Error exporting file: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Yahrtzeit List'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.share),
//             onPressed: exportYahrtzeits,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _yahrtzeits.isEmpty
//             ? Center(child: Text('No Yahrtzeits available'))
//             : ListView.builder(
//                 itemCount: _yahrtzeits.length,
//                 itemBuilder: (context, index) {
//                   return YahrtzeitTile(
//                     yahrtzeit: _yahrtzeits[index],
//                     onPressed: () {},
//                   );
//                 },
//               ),
              
//       ),
      
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../components/colors.dart';
import '../components/yahrtzeit_tile.dart';
import '../model/yahrtzeit.dart';
import 'package:share_plus/share_plus.dart';
import 'add_yahrtzeit_page.dart';

class YahrtzeitListPage extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleDarkMode;

  const YahrtzeitListPage({
    required this.isDarkMode,
    required this.toggleDarkMode,
  });

  @override
  _YahrtzeitListPageState createState() => _YahrtzeitListPageState();
}

class _YahrtzeitListPageState extends State<YahrtzeitListPage> {
  List<Yahrtzeit> _yahrtzeits = [];

  @override
  void initState() {
    super.initState();
    _readData();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/yahrtzeit.json');
  }

  Future<void> _readData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        List<dynamic> jsonData = json.decode(contents);
        List<Yahrtzeit> yahrtzeits =
            jsonData.map((item) => Yahrtzeit.fromJson(item)).toList();

        setState(() {
          _yahrtzeits = yahrtzeits;
        });
      } else {
        print('File does not exist');
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  Future<void> exportYahrtzeits() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        Share.shareFiles([file.path], text: 'Yahrtzeit data');
      } else {
        print('File does not exist');
      }
    } catch (e) {
      print('Error exporting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Yahrtzeit List'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: exportYahrtzeits,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _yahrtzeits.isEmpty
                  ? Center(child: Text('No Yahrtzeits available'))
                  : ListView.builder(
                      itemCount: _yahrtzeits.length,
                      itemBuilder: (context, index) {
                        return YahrtzeitTile(
                          yahrtzeit: _yahrtzeits[index],
                          onPressed: () {},
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 300, bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddYahrtzeitPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100, // Background color
                elevation: 10, // Elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding
              ),
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
