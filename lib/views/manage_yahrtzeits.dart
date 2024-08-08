// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:kosher_dart/kosher_dart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../localizations/app_localizations.dart';
// import '../models/yahrtzeit.dart';
// import '../models/yahrtzeit_date.dart';
// import '../services/yahrtzeits_manager.dart';
// import '../widgets/format.dart';
// import 'add_yahrtzeit.dart';
// import 'dart:convert';

// class ManageYahrtzeits extends StatefulWidget {
//   final int yearsToSync;
//   final bool syncSettings;
//   final bool notifications;
//   final String language;
//   final String jewishLanguage;
//   final String calendar;
//   final int years;
//   final int days;
//   final int months;
//   final VoidCallback toggleSyncSettings;
//   final VoidCallback toggleNotifications;
//   final Function(String) changeLanguage;
//   final Function(String) changeJewishLanguage;
//   final Function(String) changeCalendar;
//   final Function(int) changeYears;
//   final Function(int) changeDays;
//   final Function(int) changeMonths;

//   const ManageYahrtzeits({
//     required this.yearsToSync,
//     required this.syncSettings,
//     required this.notifications,
//     required this.language,
//     required this.jewishLanguage,
//     required this.calendar,
//     required this.years,
//     required this.days,
//     required this.months,
//     required this.toggleSyncSettings,
//     required this.toggleNotifications,
//     required this.changeLanguage,
//     required this.changeJewishLanguage,
//     required this.changeCalendar,
//     required this.changeYears,
//     required this.changeDays,
//     required this.changeMonths,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
// }

// class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
//   List<YahrtzeitDate> yahrtzeitDates = [];
//   List<Yahrtzeit> _yahrtzeits = [];
//   List<DateTime> _upcomingDates = [];
//   bool isLoading = true;
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

//   final YahrtzeitsManager manager = YahrtzeitsManager();
//   List<YahrtzeitDate> filteredYahrtzeitDates = [];
//   String searchQuery = '';

//   static const Map<int, String> hebrewMonths = {
//     JewishDate.TISHREI: 'Tishrei',
//     JewishDate.CHESHVAN: 'Cheshvan',
//     JewishDate.KISLEV: 'Kislev',
//     JewishDate.TEVES: 'Teves',
//     JewishDate.SHEVAT: 'Shevat',
//     JewishDate.ADAR: 'Adar',
//     JewishDate.ADAR_II: 'Adar II',
//     JewishDate.NISSAN: 'Nissan',
//     JewishDate.IYAR: 'Iyar',
//     JewishDate.SIVAN: 'Sivan',
//     JewishDate.TAMMUZ: 'Tammuz',
//     JewishDate.AV: 'Av',
//     JewishDate.ELUL: 'Elul',
//   };

//   @override
//   void initState() {
//     super.initState();
//     fetchYahrtzeits();
//   }

//   Future<void> writeData(List<Map<String, dynamic>> data) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('yahrtzeit_data', json.encode(data));
//     print('Written Data: ${json.encode(data)}');
//   }

//   Future<List<Yahrtzeit>> readData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? jsonString = prefs.getString('yahrtzeit_data');
//     print('Read JSON String: $jsonString');
//     if (jsonString != null) {
//       List<Map<String, dynamic>> jsonData =
//           List<Map<String, dynamic>>.from(json.decode(jsonString));
//       print('Parsed JSON Data: $jsonData');
//       return jsonData.map((data) => Yahrtzeit.fromJson(data)).toList();
//     } else {
//       return [];
//     }
//   }

//   Future<void> fetchYahrtzeits() async {
//     try {
//       final fetchedYahrtzeits = await readData();

//       setState(() {
//         yahrtzeitDates = _filterDuplicateYahrtzeits(fetchedYahrtzeits);
//         filteredYahrtzeitDates = yahrtzeitDates;
//         isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_listKey.currentState != null) {
//           for (var i = 0; i < filteredYahrtzeitDates.length; i++) {
//             _listKey.currentState?.insertItem(i);
//           }
//         }
//       });
//     } catch (e) {
//       print('Error fetching yahrtzeits: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   List<YahrtzeitDate> _filterDuplicateYahrtzeits(List<Yahrtzeit> yahrtzeits) {
//     final uniqueNames = <String>{};
//     final filteredList = <YahrtzeitDate>[];

//     for (var yahrtzeit in yahrtzeits) {
//       if (yahrtzeit.englishName != null &&
//           uniqueNames.add(yahrtzeit.englishName!)) {
//         filteredList.add(YahrtzeitDate.fromYahrtzeit(yahrtzeit));
//       }
//     }

//     return filteredList;
//   }

//   String _getHebrewDateString(JewishDate date) {
//     final hebrewFormatter = HebrewDateFormatter()
//       ..hebrewFormat = true
//       ..useGershGershayim = true;
//     String fullDate = hebrewFormatter.format(date);
//     List<String> dateParts = fullDate.split(' ');
//     return '${dateParts[0]} ${dateParts[1]}';
//   }

//   String _getEnglishDateString(JewishDate date) {
//     final englishFormatter = DateFormat('MMMM d');
//     return '${date.getJewishDayOfMonth()} ${_getEnglishMonthName(date.getJewishMonth())}';
//   }

//   String _getEnglishMonthName(int month) {
//     return hebrewMonths[month] ?? '';
//   }

//   Future<void> _editYahrtzeit(Yahrtzeit yahrtzeit) async {
//     try {
//       await _deleteYahrtzeitFromFile(yahrtzeit);

//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AddYahrtzeitPage(
//             yearsToSync: widget.yearsToSync,
//             yahrtzeit: yahrtzeit,
//             isEditing: true,
//             syncSettings: widget.syncSettings,
//             notifications: widget.notifications,
//             language: widget.language,
//             jewishLanguage: widget.jewishLanguage,
//             calendar: widget.calendar,
//             years: widget.years,
//             days: widget.days,
//             months: widget.months,
//             toggleSyncSettings: widget.toggleSyncSettings,
//             toggleNotifications: widget.toggleNotifications,
//             changeLanguage: widget.changeLanguage,
//             changeJewishLanguage: widget.changeJewishLanguage,
//             changeCalendar: widget.changeCalendar,
//             changeYears: widget.changeYears,
//             changeDays: widget.changeDays,
//             changeMonths: widget.changeMonths,
//           ),
//         ),
//       );

//       if (result != null && result is Yahrtzeit) {
//         await _addYahrtzeitToFile(result);
//         setState(() {
//           fetchYahrtzeits();
//         });
//       }
//     } catch (e) {
//       print('Error editing Yahrtzeit: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppLocalizations.of(context)!.translate('edit_failed')),
//         ),
//       );
//     }
//   }

//   Future<void> _addYahrtzeitToFile(Yahrtzeit yahrtzeit) async {
//     try {
//       List<Yahrtzeit> yahrtzeits = await readData();
//       yahrtzeits.add(yahrtzeit);
//       List<Map<String, dynamic>> jsonData =
//           yahrtzeits.map((y) => y.toJson()).toList();
//       await writeData(jsonData);
//     } catch (e) {
//       print('Error adding yahrtzeit: $e');
//     }
//   }

//   Future<void> _deleteYahrtzeitFromFile(Yahrtzeit yahrtzeit) async {
//     try {
//       List<Yahrtzeit> yahrtzeits = await readData();
//       yahrtzeits.removeWhere((element) => element.id == yahrtzeit.id);
//       List<Map<String, dynamic>> jsonData =
//           yahrtzeits.map((y) => y.toJson()).toList();
//       await writeData(jsonData);
//     } catch (e) {
//       print('Error deleting yahrtzeit: $e');
//     }
//   }

//   void _showDeleteConfirmationDialog(Yahrtzeit yahrtzeit) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title:
//               Text(AppLocalizations.of(context)!.translate('confirm_delete')),
//           content: Text(
//               AppLocalizations.of(context)!.translate('are_you_sure_delete')),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // סגור את הדיאלוג אם לא מאשרים
//               },
//               child: Text(AppLocalizations.of(context)!.translate('cancel')),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // סגור את הדיאלוג אחרי אישור
//                 await _deleteYahrtzeitFromFile(yahrtzeit);
//                 setState(() {
//                   fetchYahrtzeits();
//                 });
//               },
//               child: Text(AppLocalizations.of(context)!.translate('delete')),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _filterYahrtzeits(String query) {
//     setState(() {
//       searchQuery = query;
//       if (query.isEmpty) {
//         filteredYahrtzeitDates = yahrtzeitDates;
//       } else {
//         filteredYahrtzeitDates = yahrtzeitDates.where((yahrtzeitDate) {
//           return yahrtzeitDate.yahrtzeit.group != null &&
//               yahrtzeitDate.yahrtzeit.group!
//                   .toLowerCase()
//                   .contains(query.toLowerCase());
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.translate('manage_yahrzeits'),
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.grey[600],
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AddYahrtzeitPage(
//                     yearsToSync: widget.yearsToSync,
//                     syncSettings: widget.syncSettings,
//                     notifications: widget.notifications,
//                     language: widget.language,
//                     jewishLanguage: widget.jewishLanguage,
//                     calendar: widget.calendar,
//                     years: widget.years,
//                     days: widget.days,
//                     months: widget.months,
//                     toggleSyncSettings: widget.toggleSyncSettings,
//                     toggleNotifications: widget.toggleNotifications,
//                     changeLanguage: widget.changeLanguage,
//                     changeJewishLanguage: widget.changeJewishLanguage,
//                     changeCalendar: widget.changeCalendar,
//                     changeYears: widget.changeYears,
//                     changeDays: widget.changeDays,
//                     changeMonths: widget.changeMonths,
//                   ),
//                 ),
//               ).then((result) {
//                 if (result == true) {
//                   fetchYahrtzeits();
//                 }
//               });
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.info, color: Colors.white),
//             onPressed: _showStoredData,
//           ),
//         ],
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
//                           .translate('you_have_not_added_any_yahrtzeits_yet.'),
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   )
//                 : AnimatedList(
//                     key: _listKey,
//                     initialItemCount: yahrtzeitDates.length,
//                     itemBuilder: (context, index, animation) {
//                       if (index >= yahrtzeitDates.length) {
//                         return SizedBox.shrink();
//                       }
//                       return FadeTransition(
//                         opacity: animation,
//                         child: _buildYahrtzeitTile(yahrtzeitDates[index]),
//                       );
//                     },
//                   ),
//       ),
//       floatingActionButtonLocation: widget.syncSettings
//           ? FloatingActionButtonLocation.centerDocked
//           : null,
//       floatingActionButton: widget.syncSettings
//           ? Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SizedBox(
//                 height: 50,
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       List<Yahrtzeit> yahrtzeits = await readData();
//                       manager.onSyncButtonPressed(
//                           yahrtzeits, widget.yearsToSync);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Sync successful'),
//                         ),
//                       );
//                     } catch (e) {
//                       print('Sync failed: $e');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Sync failed'),
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[600],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                   ),
//                   child: Text(
//                     'Sync',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ),
//               ),
//             )
//           : null,
//     );
//   }

//   Widget _buildYahrtzeitTile(YahrtzeitDate yahrtzeitDate) {
//     String hebrewDate = _getHebrewDateString(yahrtzeitDate.hebrewDate);
//     String englishDate = _getEnglishDateString(yahrtzeitDate.hebrewDate);

//     // Check language preferences
//     bool isBothEnglish =
//         widget.language == 'en' && widget.jewishLanguage == 'en';
//     bool isBothHebrew =
//         widget.language == 'he' && widget.jewishLanguage == 'he';
//     bool isEnglishAndHebrew =
//         (widget.language == 'en' && widget.jewishLanguage == 'he') ||
//             (widget.language == 'he' && widget.jewishLanguage == 'en');

//     return Dismissible(
//       key: Key(yahrtzeitDate.yahrtzeit.id.toString()),
//       direction: DismissDirection.endToStart,
//       // onDismissed: (direction) {
//       //   _deleteYahrtzeit(yahrtzeitDate.yahrtzeit);
//       // },
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Icon(Icons.delete, color: Colors.white),
//             SizedBox(width: 20),
//           ],
//         ),
//       ),
//       child: Card(
//         elevation: 5,
//         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: ListTile(
//           contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 yahrtzeitDate.yahrtzeit.englishName!,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(height: 5),
//               // Display dates based on language settings
//               if (isBothHebrew) ...[
//                 Text(
//                   hebrewDate,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ] else if (isBothEnglish) ...[
//                 Text(
//                   englishDate,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ] else if (isEnglishAndHebrew) ...[
//                 Text(
//                   englishDate,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   hebrewDate,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   Icons.edit,
//                   color: Colors.grey[600],
//                 ),
//                 onPressed: () => _editYahrtzeit(yahrtzeitDate.yahrtzeit),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';
import '../widgets/format.dart';
import 'add_yahrtzeit.dart';
import 'dart:convert';

class ManageYahrtzeits extends StatefulWidget {
  final int yearsToSync;
  final bool syncSettings;
  final bool notifications;
  final String language;
  final String jewishLanguage;
  final String calendar;
  final int years;
  final int days;
  final int months;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;
  final Function(int) changeMonths;

  const ManageYahrtzeits({
    required this.yearsToSync,
    required this.syncSettings,
    required this.notifications,
    required this.language,
    required this.jewishLanguage,
    required this.calendar,
    required this.years,
    required this.days,
    required this.months,
    required this.toggleSyncSettings,
    required this.toggleNotifications,
    required this.changeLanguage,
    required this.changeJewishLanguage,
    required this.changeCalendar,
    required this.changeYears,
    required this.changeDays,
    required this.changeMonths,
    Key? key,
  }) : super(key: key);

  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  List<YahrtzeitDate> yahrtzeitDates = [];
  List<Yahrtzeit> _yahrtzeits = [];
  List<DateTime> _upcomingDates = [];
  bool isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<YahrtzeitDate> filteredYahrtzeitDates = [];
  String searchQuery = '';

  static const Map<int, String> hebrewMonths = {
    JewishDate.TISHREI: 'Tishrei',
    JewishDate.CHESHVAN: 'Cheshvan',
    JewishDate.KISLEV: 'Kislev',
    JewishDate.TEVES: 'Teves',
    JewishDate.SHEVAT: 'Shevat',
    JewishDate.ADAR: 'Adar',
    JewishDate.ADAR_II: 'Adar II',
    JewishDate.NISSAN: 'Nissan',
    JewishDate.IYAR: 'Iyar',
    JewishDate.SIVAN: 'Sivan',
    JewishDate.TAMMUZ: 'Tammuz',
    JewishDate.AV: 'Av',
    JewishDate.ELUL: 'Elul',
  };

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> writeData(List<Map<String, dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('yahrtzeit_data', json.encode(data));
    print('Written Data: ${json.encode(data)}');
  }

  Future<List<Yahrtzeit>> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    print('Read JSON String: $jsonString');
    if (jsonString != null) {
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      print('Parsed JSON Data: $jsonData');
      return jsonData.map((data) => Yahrtzeit.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final fetchedYahrtzeits = await readData();

      setState(() {
        yahrtzeitDates = _filterDuplicateYahrtzeits(fetchedYahrtzeits);
        filteredYahrtzeitDates = yahrtzeitDates;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listKey.currentState != null) {
          for (var i = 0; i < filteredYahrtzeitDates.length; i++) {
            _listKey.currentState?.insertItem(i);
          }
        }
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<YahrtzeitDate> _filterDuplicateYahrtzeits(List<Yahrtzeit> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeit in yahrtzeits) {
      if (yahrtzeit.englishName != null &&
          uniqueNames.add(yahrtzeit.englishName!)) {
        filteredList.add(YahrtzeitDate.fromYahrtzeit(yahrtzeit));
      }
    }

    return filteredList;
  }

  String _getHebrewDateString(JewishDate date) {
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;
    String fullDate = hebrewFormatter.format(date);
    List<String> dateParts = fullDate.split(' ');
    return '${dateParts[0]} ${dateParts[1]}';
  }

  String _getEnglishDateString(JewishDate date) {
    final englishFormatter = DateFormat('MMMM d');
    return '${date.getJewishDayOfMonth()} ${_getEnglishMonthName(date.getJewishMonth())}';
  }

  String _getEnglishMonthName(int month) {
    return hebrewMonths[month] ?? '';
  }

  Future<void> _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await _deleteYahrtzeitFromFile(yahrtzeit);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddYahrtzeitPage(
            yearsToSync: widget.yearsToSync,
            yahrtzeit: yahrtzeit,
            isEditing: true,
            syncSettings: widget.syncSettings,
            notifications: widget.notifications,
            language: widget.language,
            jewishLanguage: widget.jewishLanguage,
            calendar: widget.calendar,
            years: widget.years,
            days: widget.days,
            months: widget.months,
            toggleSyncSettings: widget.toggleSyncSettings,
            toggleNotifications: widget.toggleNotifications,
            changeLanguage: widget.changeLanguage,
            changeJewishLanguage: widget.changeJewishLanguage,
            changeCalendar: widget.changeCalendar,
            changeYears: widget.changeYears,
            changeDays: widget.changeDays,
            changeMonths: widget.changeMonths,
          ),
        ),
      );

      if (result != null && result is Yahrtzeit) {
        await _addYahrtzeitToFile(result);
        setState(() {
          fetchYahrtzeits();
        });
      }
    } catch (e) {
      print('Error editing Yahrtzeit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('edit_failed')),
        ),
      );
    }
  }

  Future<void> _addYahrtzeitToFile(Yahrtzeit yahrtzeit) async {
    try {
      List<Yahrtzeit> yahrtzeits = await readData();
      yahrtzeits.add(yahrtzeit);
      List<Map<String, dynamic>> jsonData =
          yahrtzeits.map((y) => y.toJson()).toList();
      await writeData(jsonData);
    } catch (e) {
      print('Error adding yahrtzeit: $e');
    }
  }

  Future<void> _deleteYahrtzeitFromFile(Yahrtzeit yahrtzeit) async {
    try {
      List<Yahrtzeit> yahrtzeits = await readData();
      yahrtzeits.removeWhere((element) => element.id == yahrtzeit.id);
      List<Map<String, dynamic>> jsonData =
          yahrtzeits.map((y) => y.toJson()).toList();
      await writeData(jsonData);
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
    }
  }

  void _showDeleteConfirmationDialog(Yahrtzeit yahrtzeit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context)!.translate('confirm_delete')),
          content: Text(
              AppLocalizations.of(context)!.translate('are_you_sure_delete')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // סגור את הדיאלוג אם לא מאשרים
              },
              child: Text(AppLocalizations.of(context)!.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // סגור את הדיאלוג אחרי אישור
                await _deleteYahrtzeitFromFile(yahrtzeit);
                setState(() {
                  fetchYahrtzeits();
                });
              },
              child: Text(AppLocalizations.of(context)!.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  void _filterYahrtzeits(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredYahrtzeitDates = yahrtzeitDates;
      } else {
        filteredYahrtzeitDates = yahrtzeitDates.where((yahrtzeitDate) {
          return yahrtzeitDate.yahrtzeit.group != null &&
              yahrtzeitDate.yahrtzeit.group!
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('manage_yahrzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddYahrtzeitPage(
                    yearsToSync: widget.yearsToSync,
                    syncSettings: widget.syncSettings,
                    notifications: widget.notifications,
                    language: widget.language,
                    jewishLanguage: widget.jewishLanguage,
                    calendar: widget.calendar,
                    years: widget.years,
                    days: widget.days,
                    months: widget.months,
                    toggleSyncSettings: widget.toggleSyncSettings,
                    toggleNotifications: widget.toggleNotifications,
                    changeLanguage: widget.changeLanguage,
                    changeJewishLanguage: widget.changeJewishLanguage,
                    changeCalendar: widget.changeCalendar,
                    changeYears: widget.changeYears,
                    changeDays: widget.changeDays,
                    changeMonths: widget.changeMonths,
                  ),
                ),
              ).then((result) {
                if (result == true) {
                  fetchYahrtzeits();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.info, color: Colors.white),
            onPressed: (){},
            // onPressed: _showStoredData,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : yahrtzeitDates.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('you_have_not_added_any_yahrtzeits_yet.'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: yahrtzeitDates.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= yahrtzeitDates.length) {
                        return SizedBox.shrink();
                      }
                      return FadeTransition(
                        opacity: animation,
                        child: _buildYahrtzeitTile(yahrtzeitDates[index]),
                      );
                    },
                  ),
      ),
      floatingActionButtonLocation: widget.syncSettings
          ? FloatingActionButtonLocation.centerDocked
          : null,
      floatingActionButton: widget.syncSettings
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      List<Yahrtzeit> yahrtzeits = await readData();
                      manager.onSyncButtonPressed(
                          yahrtzeits, widget.yearsToSync);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sync successful'),
                        ),
                      );
                    } catch (e) {
                      print('Sync failed: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sync failed'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Sync',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildYahrtzeitTile(YahrtzeitDate yahrtzeitDate) {
    String hebrewDate = _getHebrewDateString(yahrtzeitDate.hebrewDate);
    String englishDate = _getEnglishDateString(yahrtzeitDate.hebrewDate);

    // Check language preferences
    bool isBothEnglish =
        widget.language == 'en' && widget.jewishLanguage == 'en';
    bool isBothHebrew =
        widget.language == 'he' && widget.jewishLanguage == 'he';
    bool isEnglishAndHebrew =
        (widget.language == 'en' && widget.jewishLanguage == 'he') ||
            (widget.language == 'he' && widget.jewishLanguage == 'en');

    return Dismissible(
      key: Key(yahrtzeitDate.yahrtzeit.id.toString()),
      direction: DismissDirection.endToStart,
      // onDismissed: (direction) {
      //   _deleteYahrtzeit(yahrtzeitDate.yahrtzeit);
      // },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 20),
          ],
        ),
      ),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                yahrtzeitDate.yahrtzeit.englishName!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5),
              // Display dates based on language settings
              if (isBothHebrew) ...[
                Text(
                  hebrewDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ] else if (isBothEnglish) ...[
                Text(
                  englishDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ] else if (isEnglishAndHebrew) ...[
                Text(
                  englishDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  hebrewDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.grey[600],
                ),
                onPressed: () => _editYahrtzeit(yahrtzeitDate.yahrtzeit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
