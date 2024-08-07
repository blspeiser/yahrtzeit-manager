// import 'package:flutter/material.dart';
// import '../models/yahrtzeit.dart';
// import '../services/yahrtzeits_manager.dart';
// import 'package:kosher_dart/kosher_dart.dart';
// import '../localizations/app_localizations.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../home_page.dart';

// class AddYahrtzeitPage extends StatefulWidget {
//   final Yahrtzeit? yahrtzeit;
//   final bool isEditing;
//   final int yearsToSync;
//   final bool syncSettings;
//   final bool notifications;
//   final String language;
//   final String jewishLanguage;
//   final String calendar;
//   final int years;
//   final int days;
//   final VoidCallback toggleSyncSettings;
//   final VoidCallback toggleNotifications;
//   final Function(String) changeLanguage;
//   final Function(String) changeJewishLanguage;
//   final Function(String) changeCalendar;
//   final Function(int) changeYears;
//   final Function(int) changeDays;

//   AddYahrtzeitPage({
//     this.yahrtzeit,
//     this.isEditing = false,
//     required this.yearsToSync,
//     required this.syncSettings,
//     required this.notifications,
//     required this.language,
//     required this.jewishLanguage,
//     required this.calendar,
//     required this.years,
//     required this.days,
//     required this.toggleSyncSettings,
//     required this.toggleNotifications,
//     required this.changeLanguage,
//     required this.changeJewishLanguage,
//     required this.changeCalendar,
//     required this.changeYears,
//     required this.changeDays,
//   });

//   @override
//   _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
// }

// class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _englishNameController = TextEditingController();
//   final _hebrewNameController = TextEditingController();
//   final _groupController = TextEditingController();
//   int? _selectedDay;
//   int? _selectedMonth;
//   final YahrtzeitsManager manager = YahrtzeitsManager();

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
//     if (widget.isEditing && widget.yahrtzeit != null) {
//       _englishNameController.text = widget.yahrtzeit!.englishName!;
//       _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
//       _selectedDay = widget.yahrtzeit!.day;
//       _selectedMonth = widget.yahrtzeit!.month;
//     }
//   }

//   Future<void> writeData(List<Map<String, dynamic>> data) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('yahrtzeit_data', json.encode(data));
//   }

//   Future<List<Map<String, dynamic>>> readData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? jsonString = prefs.getString('yahrtzeit_data');
//     if (jsonString != null) {
//       return List<Map<String, dynamic>>.from(json.decode(jsonString));
//     } else {
//       return [];
//     }
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       final localizations = AppLocalizations.of(context)!;

//       try {
//         List<Map<String, dynamic>> jsonData = await readData();

//         int currentYear = JewishDate().getJewishYear();
//         List<Yahrtzeit> newYahrtzeits = [];

//         JewishDate jewishDate = JewishDate.initDate(
//             jewishYear: currentYear,
//             jewishMonth: _selectedMonth!,
//             jewishDayOfMonth: _selectedDay!);
//         DateTime gregorianDate = DateTime(
//             jewishDate.getGregorianYear(),
//             jewishDate.getGregorianMonth(),
//             jewishDate.getGregorianDayOfMonth());

//         final newYahrtzeit = Yahrtzeit(
//           englishName: _englishNameController.text,
//           hebrewName: _hebrewNameController.text,
//           day: _selectedDay!,
//           month: _selectedMonth!,
//           group: _groupController.text,
//         );

//         newYahrtzeits.add(newYahrtzeit);

//         jsonData.addAll(newYahrtzeits.map((y) => y.toJson()).toList());

//         if (widget.syncSettings) {
//           for (var yahrtzeit in newYahrtzeits) {
//             await manager.addYahrtzeit(
//                 yahrtzeit, widget.yearsToSync, widget.syncSettings);
//           }
//         }

//         await writeData(jsonData);
//         print('JSON file content: ${json.encode(jsonData)}');

//         // Log the new data to ensure it's saved correctly
//         final savedData = await readData();
//         print('Saved Data: $savedData');

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Data saved!')),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomePage(
//               syncSettings: widget.syncSettings,
//               notifications: widget.notifications,
//               language: widget.language,
//               jewishLanguage: widget.jewishLanguage,
//               years: widget.years,
//               days: widget.days,
//               calendar: widget.calendar,
//               toggleSyncSettings: widget.toggleSyncSettings,
//               toggleNotifications: widget.toggleNotifications,
//               changeLanguage: widget.changeLanguage,
//               changeJewishLanguage: widget.changeJewishLanguage,
//               changeCalendar: widget.changeCalendar,
//               changeYears: widget.changeYears,
//               changeDays: widget.changeDays,
//             ),
//           ),
//         );
//       } catch (e) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(localizations.translate('error')),
//             content: Text('${localizations.translate('error')}: $e'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text(localizations.translate('ok')),
//               ),
//             ],
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.isEditing
//             ? (AppLocalizations.of(context)!.translate('Edit Yahrtzeit'))
//             : (AppLocalizations.of(context)!.translate('Add Yahrtzeit'))),
      
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: <Widget>[
//               TextFormField(
//                 controller: _englishNameController,
//                 decoration: InputDecoration(
//                     labelText:
//                         AppLocalizations.of(context)!.translate('English Name')),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return AppLocalizations.of(context)!.translate('Please enter English name') ;
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _hebrewNameController,
//                 decoration: InputDecoration(
//                     labelText:
//                         AppLocalizations.of(context)!.translate('Hebrew Name')),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return AppLocalizations.of(context)!.translate('Please enter Hebrew name') ;
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                     labelText: AppLocalizations.of(context)!.translate('day')),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   _selectedDay = int.tryParse(value);
//                 },
//                 validator: (value) {
//                   if (_selectedDay == null ||
//                       _selectedDay! < 1 ||
//                       _selectedDay! > 30) {
//                     return AppLocalizations.of(context)!.translate('Please enter a valid day');
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10), // Add spacing between fields
//               DropdownButtonFormField<int>(
//                 decoration: InputDecoration(
//                     labelText:
//                         AppLocalizations.of(context)!.translate('month')),
//                 value: _selectedMonth,
//                 items: hebrewMonths.entries.map((entry) {
//                   return DropdownMenuItem<int>(
//                     value: entry.key,
//                     child: Text(entry.value),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedMonth = value;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return AppLocalizations.of(context)!.translate('Please select a month');
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _groupController,
//                 decoration: InputDecoration(labelText:AppLocalizations.of(context)!.translate( 'Group Name')),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 labelText:AppLocalizations.of(context)!.translate( 'Group Name')),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_page.dart';
import '../localizations/app_localizations.dart';
import '../main.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'dart:convert';

class AddYahrtzeitPage extends StatefulWidget {
  final Yahrtzeit? yahrtzeit;
  final bool isEditing;
  final int yearsToSync;
  final bool syncSettings;
  final bool notifications;
  final String language;
  final String jewishLanguage;
  final String calendar;
  final int years;
  final int days;
  int months;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;
  final Function(int) changeMonths;

  AddYahrtzeitPage({
    this.yahrtzeit,
    this.isEditing = false,
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
  });

  @override
  _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
}

class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
  final _formKey = GlobalKey<FormState>();
  final _englishNameController = TextEditingController();
  final _hebrewNameController = TextEditingController();
  final _groupController = TextEditingController();
  int? _selectedDay;
  int? _selectedMonth;
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<String> groups = [];

  static const Map<int, String> englishMonths = {
    JewishDate.NISSAN: 'Nissan',
    JewishDate.IYAR: 'Iyar',
    JewishDate.SIVAN: 'Sivan',
    JewishDate.TAMMUZ: 'Tammuz',
    JewishDate.AV: 'Av',
    JewishDate.ELUL: 'Elul',
    JewishDate.TISHREI: 'Tishrei',
    JewishDate.CHESHVAN: 'Cheshvan',
    JewishDate.KISLEV: 'Kislev',
    JewishDate.TEVES: 'Teves',
    JewishDate.SHEVAT: 'Shevat',
    JewishDate.ADAR: 'Adar',
    JewishDate.ADAR_II: 'Adar II',
  };

  static const Map<int, String> hebrewMonths = {
    JewishDate.NISSAN: 'ניסן',
    JewishDate.IYAR: 'אייר',
    JewishDate.SIVAN: 'סיוון',
    JewishDate.TAMMUZ: 'תמוז',
    JewishDate.AV: 'אב',
    JewishDate.ELUL: 'אלול',
    JewishDate.TISHREI: 'תשרי',
    JewishDate.CHESHVAN: 'חשוון',
    JewishDate.KISLEV: 'כסלו',
    JewishDate.TEVES: 'טבת',
    JewishDate.SHEVAT: 'שבט',
    JewishDate.ADAR: 'אדר',
    JewishDate.ADAR_II: 'אדר ב׳',
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.yahrtzeit != null) {
      _englishNameController.text = widget.yahrtzeit!.englishName ?? '';
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
      _selectedDay = widget.yahrtzeit!.day;
      _selectedMonth = widget.yahrtzeit!.month;
      _groupController.text = widget.yahrtzeit!.group ?? '';
    }
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    try {
      final fetchedGroups = await manager.getAllGroups();
      setState(() {
        groups = fetchedGroups;
      });
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> writeData(List<Map<String, dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('yahrtzeit_data', json.encode(data));
  }

  Future<List<Map<String, dynamic>>> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    if (jsonString != null) {
      return List<Map<String, dynamic>>.from(json.decode(jsonString));
    } else {
      return [];
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final localizations = AppLocalizations.of(context)!;

      try {
        List<Map<String, dynamic>> jsonData = await readData();

        int currentYear = JewishDate().getJewishYear();
        List<Yahrtzeit> newYahrtzeits = [];

        JewishDate jewishDate = JewishDate.initDate(
            jewishYear: currentYear,
            jewishMonth: _selectedMonth!,
            jewishDayOfMonth: _selectedDay!);
        DateTime gregorianDate = DateTime(
            jewishDate.getGregorianYear(),
            jewishDate.getGregorianMonth(),
            jewishDate.getGregorianDayOfMonth());

        Yahrtzeit newYahrtzeit;

        // Create Yahrtzeit object based on language
        if (widget.language == 'en') {
          newYahrtzeit = Yahrtzeit(
            englishName: _englishNameController.text,
            hebrewName: _hebrewNameController.text.isNotEmpty
                ? _hebrewNameController.text
                : '',
            day: _selectedDay!,
            month: _selectedMonth!,
            group: _groupController.text,
          );
        } else {
          newYahrtzeit = Yahrtzeit(
            hebrewName: _hebrewNameController.text,
            englishName: _englishNameController.text.isNotEmpty
                ? _englishNameController.text
                : '',
            day: _selectedDay!,
            month: _selectedMonth!,
            group: _groupController.text,
          );
        }

        newYahrtzeits.add(newYahrtzeit);

        jsonData.addAll(newYahrtzeits.map((y) => y.toJson()).toList());

        if (widget.syncSettings) {
          for (var yahrtzeit in newYahrtzeits) {
            await manager.addYahrtzeit(
                yahrtzeit, widget.yearsToSync, widget.syncSettings);
          }
        }

        await writeData(jsonData);
        print('JSON file content: ${json.encode(jsonData)}');

        // Log the new data to ensure it's saved correctly
        final savedData = await readData();
        print('Saved Data: $savedData');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              syncSettings: widget.syncSettings,
              notifications: widget.notifications,
              language: widget.language,
              jewishLanguage: widget.jewishLanguage,
              years: widget.years,
              days: widget.days,
              months: widget.months,
              calendar: widget.calendar,
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
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.translate('error')),
            content: Text('${localizations.translate('error')}: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localizations.translate('ok')),
              ),
            ],
          ),
        );
      }
    }
  }

  String _getMonthName(int month) {
    return Localizations.localeOf(context).languageCode == 'he'
        ? hebrewMonths[month] ?? ''
        : englishMonths[month] ?? '';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text((widget.isEditing
             ? (AppLocalizations.of(context)!.translate('Edit Yahrtzeit'))
            : (AppLocalizations.of(context)!.translate('Add Yahrtzeit'))),
      

        style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
          iconTheme: IconThemeData(
    color: Colors.white, // צבע החץ אחורה
  ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _englishNameController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('English Name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return  AppLocalizations.of(context)!.translate('Please enter English name');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewNameController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('Hebrew Name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return  AppLocalizations.of(context)!.translate('Please enter Hebrew name');
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('day')),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _selectedDay = int.tryParse(value);
                },
                validator: (value) {
                  if (_selectedDay == null ||
                      _selectedDay! < 1 ||
                      _selectedDay! > 30) {
                    return  AppLocalizations.of(context)!.translate('Please enter a valid day');
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // Add spacing between fields
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('month')),
                value: _selectedMonth,
                items: hebrewMonths.keys.map((month) {
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(_getMonthName(month)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return  AppLocalizations.of(context)!.translate('Please select a month');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _groupController,
                decoration: InputDecoration(labelText:AppLocalizations.of(context)!.translate( 'Group Name')),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text((widget.isEditing ?  AppLocalizations.of(context)!.translate('Update') :  AppLocalizations.of(context)!.translate('Save'))),
              ),
            ],

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Yahrtzeit' : 'Add Yahrtzeit',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[600],
          elevation: 0,
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _englishNameController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!
                          .translate('English Name')),
                  validator: (value) {
                    if (widget.language == 'en' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter English name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _hebrewNameController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!
                          .translate('Hebrew Name')),
                  validator: (value) {
                    if (widget.language == 'he' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter Hebrew name';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.translate('day')),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _selectedDay = int.tryParse(value);
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final day = int.tryParse(value);
                            if (day == null || day < 1 || day > 31) {
                              return 'Please enter a valid day between 1 and 31';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16), // Add spacing between the fields
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!
                                .translate('month')),
                        value: _selectedMonth,
                        items: hebrewMonths.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMonth = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _groupController,
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.translate('Group')),
                ),
                SizedBox(height: 30), // Add spacing between the fields
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                      widget.isEditing ? 'Update Yahrtzeit' : 'Add Yahrtzeit',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }
}

