// import 'package:flutter/material.dart';
// import '../localizations/app_localizations.dart';
// import '../models/yahrtzeit.dart';
// import '../models/yahrtzeit_date.dart';
// import '../services/yahrtzeits_manager.dart';
// import '../widgets/yahrtzeit_tile.dart';

// class UpcomingYahrtzeits extends StatefulWidget {
//   @override
//   _UpcomingYahrtzeitsState createState() => _UpcomingYahrtzeitsState();
// }

// class _UpcomingYahrtzeitsState extends State<UpcomingYahrtzeits> {
//   final YahrtzeitsManager manager = YahrtzeitsManager();
//   List<YahrtzeitDate> yahrtzeitDates = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchYahrtzeits();
//   }

//   Future<void> fetchYahrtzeits() async {
//     try {
//       final yahrtzeits = await manager
//           .getAllYahrtzeits(); // טען את כל היארצייטים מ-SharedPreferences
//       print('Fetched yahrtzeits: ${yahrtzeits.length}');
//       setState(() {
//         yahrtzeitDates =
//             _filterDuplicateYahrtzeits(manager.nextMultiple(yahrtzeits));
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching yahrtzeits: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   List<YahrtzeitDate> _filterDuplicateYahrtzeits(
//       List<YahrtzeitDate> yahrtzeits) {
//     final uniqueNames = <String>{};
//     final filteredList = <YahrtzeitDate>[];

//     for (var yahrtzeitDate in yahrtzeits) {
//       if (uniqueNames.add(yahrtzeitDate.yahrtzeit.englishName!)) {
//         filteredList.add(yahrtzeitDate);
//       }
//     }

//     return filteredList;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.translate('upcoming_yahrtzeits'),
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 50, 4, 129),
//         elevation: 0,
//         actionsIconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         color: Colors.white,
//         child: isLoading
//             ? Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                 ),
//               )
//             : yahrtzeitDates.isEmpty
//                 ? Center(
//                     child: Text(
//                       AppLocalizations.of(context)!
//                           .translate('no_upcoming_yahrtzeits_found'),
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: yahrtzeitDates.length,
//                     itemBuilder: (context, index) {
//                       final yahrtzeitDate = yahrtzeitDates[index];
//                       return YahrtzeitTile(yahrtzeitDate: yahrtzeitDate);
//                     },
//                   ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';
import '../widgets/yahrtzeit_tile.dart';
import 'add_yahrtzeit.dart';

class UpcomingYahrtzeits extends StatefulWidget {
  @override
  _UpcomingYahrtzeitsState createState() => _UpcomingYahrtzeitsState();
}

class _UpcomingYahrtzeitsState extends State<UpcomingYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<YahrtzeitDate> yahrtzeitDates = [];
  bool isLoading = true;
  
  // משתנים לאחסון ההגדרות
  late bool _syncSettings;
  late bool _notifications;
  late String _language;
  late String _jewishLanguage;
  late String _calendar;
  late int _years;
  late int _days;

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
    _loadSettings();
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final yahrtzeits = await manager.getAllYahrtzeits(); // טען את כל היארצייטים מ-SharedPreferences
      print('Fetched yahrtzeits: ${yahrtzeits.length}');
      setState(() {
        yahrtzeitDates =
            _filterDuplicateYahrtzeits(manager.nextMultiple(yahrtzeits));
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncSettings = prefs.getBool('syncSettings') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'en';
      _jewishLanguage = prefs.getString('jewishLanguage') ?? 'he';
      _calendar = prefs.getString('calendar') ?? 'google';
      _years = prefs.getInt('years') ?? 1;
      _days = prefs.getInt('days') ?? 0;
    });
  }

  List<YahrtzeitDate> _filterDuplicateYahrtzeits(
      List<YahrtzeitDate> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeitDate in yahrtzeits) {
      if (uniqueNames.add(yahrtzeitDate.yahrtzeit.englishName!)) {
        filteredList.add(yahrtzeitDate);
      }
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('upcoming_yahrtzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              )
            : yahrtzeitDates.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('no_upcoming_yahrtzeits_found'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: yahrtzeitDates.length,
                    itemBuilder: (context, index) {
                      final yahrtzeitDate = yahrtzeitDates[index];
                      return YahrtzeitTile(yahrtzeitDate: yahrtzeitDate);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddYahrtzeitPage(
                yearsToSync: _years,
                syncSettings: _syncSettings,
                notifications: _notifications,
                language: _language,
                jewishLanguage: _jewishLanguage,
                calendar: _calendar,
                years: _years,
                days: _days,
                toggleSyncSettings: () {
                  setState(() {
                    _syncSettings = !_syncSettings;
                  });
                },
                toggleNotifications: () {
                  setState(() {
                    _notifications = !_notifications;
                  });
                },
                changeLanguage: (String lang) {
                  setState(() {
                    _language = lang;
                  });
                },
                changeJewishLanguage: (String lang) {
                  setState(() {
                    _jewishLanguage = lang;
                  });
                },
                changeCalendar: (String cal) {
                  setState(() {
                    _calendar = cal;
                  });
                },
                changeYears: (int year) {
                  setState(() {
                    _years = year;
                  });
                },
                changeDays: (int day) {
                  setState(() {
                    _days = day;
                  });
                },
              ),
            ),
          ).then((result) {
            if (result == true) {
              fetchYahrtzeits();
            }
          });
        },
        backgroundColor: Color.fromARGB(255, 50, 4, 129), // צבע הרקע של הכפתור
        foregroundColor: Colors.white, // צבע האייקון (הפלוס)
        child: Icon(Icons.add),
        shape: CircleBorder(), // מוודא שהכפתור יהיה עגול
      ),
    );
  }
}
