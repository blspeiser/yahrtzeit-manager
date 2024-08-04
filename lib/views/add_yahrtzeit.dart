// import 'package:flutter/material.dart';
// import '../models/yahrtzeit.dart';
// import '../services/yahrtzeits_manager.dart';
// import '../services/groups_manager.dart'; // Import GroupsManager

// class AddYahrtzeitPage extends StatefulWidget {
//   final Yahrtzeit? yahrtzeit;
//   final bool isEditing;

//   AddYahrtzeitPage({this.yahrtzeit, this.isEditing = false});

//   @override
//   _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
// }

// class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _englishNameController = TextEditingController();
//   final _hebrewNameController = TextEditingController();
//   final _dayController = TextEditingController();
//   final _groupController = TextEditingController(); // Controller for Group Name

//   String? _selectedMonth;
//   final YahrtzeitsManager manager = YahrtzeitsManager();
//   final GroupsManager groupsManager =
//       GroupsManager(); // Instance of GroupsManager

//   final List<String> hebrewMonths = [
//     'Tishrey',
//     'Cheshvan',
//     'Kislev',
//     'Tevet',
//     'Shvat',
//     'Adar',
//     'AdarAleph',
//     'AdarBeit',
//     'Nissan',
//     'Iyar',
//     'Sivan',
//     'Tamuz',
//     'Av',
//     'Elul'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.isEditing && widget.yahrtzeit != null) {
//       _englishNameController.text = widget.yahrtzeit!.englishName ?? "";
//       _hebrewNameController.text = widget.yahrtzeit!.hebrewName ?? "";
//       _dayController.text = widget.yahrtzeit!.day.toString();
//       _selectedMonth = hebrewMonths[widget.yahrtzeit!.month - 1];
//       _groupController.text = widget.yahrtzeit!.group ??
//           ""; // Assuming 'group' is a field in Yahrtzeit
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.isEditing ? 'Edit Yahrtzeit' : 'Add Yahrtzeit'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: <Widget>[
//               TextFormField(
//                 controller: _englishNameController,
//                 decoration: InputDecoration(labelText: 'English Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter English name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _hebrewNameController,
//                 decoration: InputDecoration(labelText: 'Hebrew Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter Hebrew name';
//                   }
//                   return null;
//                 },
//               ),
//               DropdownButtonFormField<String>(
//                 value: _selectedMonth,
//                 decoration: InputDecoration(labelText: 'Select Month'),
//                 items: hebrewMonths.map((month) {
//                   return DropdownMenuItem<String>(
//                     value: month,
//                     child: Text(month),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedMonth = value;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select a month';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _dayController,
//                 decoration: InputDecoration(labelText: 'Select Day'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a day';
//                   }
//                   final day = int.tryParse(value);
//                   if (day == null || day < 1 || day > 31) {
//                     return 'Please enter a valid day';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _groupController,
//                 decoration: InputDecoration(labelText: 'Group Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter Group name';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _saveYahrtzeit,
//                 child: Text(widget.isEditing ? 'Update' : 'Save'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _saveYahrtzeit() async {
//     if (_formKey.currentState!.validate()) {
//       final now = DateTime.now();
//       final selectedDay = int.parse(_dayController.text);
//       final selectedMonth = hebrewMonths.indexOf(_selectedMonth ?? "") + 1;
//       final selectedDate = DateTime(now.year, selectedMonth, selectedDay);
//       final newYahrtzeit = Yahrtzeit(
//         englishName: _englishNameController.text,
//         hebrewName: _hebrewNameController.text,
//         day: selectedDay,
//         month: selectedMonth,
//         year: now.year,
//         gregorianDate: selectedDate,
//         // group: _groupController.text, // Add group information
//       );
//       if (widget.isEditing && widget.yahrtzeit != null) {
//         await manager.updateYahrtzeit(widget.yahrtzeit!, newYahrtzeit);
//       } else {
//         await manager.addYahrtzeit(newYahrtzeit);
//         print('newYahrtzeit: ${newYahrtzeit.hebrewName}');
//         await groupsManager.addYahrtzeitToGroup(
//             _groupController.text, newYahrtzeit); // Create new group
//       }
//       Navigator.pop(context, true);
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';

class AddYahrtzeitPage extends StatefulWidget {
  final Yahrtzeit? yahrtzeit;
  final bool isEditing;

  AddYahrtzeitPage({this.yahrtzeit, this.isEditing = false});

  @override
  _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
}

class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
  final _formKey = GlobalKey<FormState>();
  final _englishNameController = TextEditingController();
  final _hebrewNameController = TextEditingController();
  int? _selectedDay;
  int? _selectedMonth;
  final YahrtzeitsManager manager = YahrtzeitsManager();

  static const Map<int, String> hebrewMonths = {
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
    JewishDate.ADAR_II: 'Adar II'
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.yahrtzeit != null) {
      _englishNameController.text = widget.yahrtzeit!.englishName;
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
      _selectedDay = widget.yahrtzeit!.day;
      _selectedMonth = widget.yahrtzeit!.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Yahrtzeit' : 'Add Yahrtzeit',
        style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _englishNameController,
                decoration: InputDecoration(labelText: 'English Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter English name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewNameController,
                decoration: InputDecoration(labelText: 'Hebrew Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Hebrew name';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Select Hebrew Date'),
                // subtitle: Text(_selectedDay != null && _selectedMonth != null
                //     ? 'Day: $_selectedDay, Month: ${hebrewMonths[_selectedMonth]}'
                //     : 'No Date Selected'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickHebrewDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveYahrtzeit,
                child: Text(widget.isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickHebrewDate() async {
    showDialog(
      context: context,
      builder: (context) {
        int? day;
        int? month;
        return AlertDialog(
          title: Text('Select Hebrew Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Day'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  day = int.tryParse(value);
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Month'),
                items: hebrewMonths.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  month = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (day != null && month != null) {
                  setState(() {
                    _selectedDay = day! + 1;  // Always add one to the day
                    _selectedMonth = month;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _saveYahrtzeit() async {
    if (_formKey.currentState!.validate() && _selectedDay != null && _selectedMonth != null) {
      try {
        print('Saving Yahrtzeit...');
        final gregorianDate = _getNextGregorianDate(_selectedDay!, _selectedMonth!);
        print('Gregorian Date: $gregorianDate');
        final newYahrtzeit = Yahrtzeit(
          englishName: _englishNameController.text,
          hebrewName: _hebrewNameController.text,
          day: _selectedDay!,
          month: _selectedMonth!,
          year: JewishDate().getJewishYear() + 1, // Use the next Hebrew year
          gregorianDate: gregorianDate,
        );
        print('New Yahrtzeit: $newYahrtzeit');
        if (widget.isEditing && widget.yahrtzeit != null) {
          await manager.updateYahrtzeit(widget.yahrtzeit!, newYahrtzeit);
        } else {
          await manager.addYahrtzeit(newYahrtzeit);
        }
        print('Yahrtzeit saved successfully');
        Navigator.pop(context, true);
      } catch (e) {
        print('Error: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while saving the Yahrtzeit: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  DateTime _getNextGregorianDate(int day, int month) {
    try {
      final now = DateTime.now();
      final jewishDate = JewishDate();
      final hebrewYear = JewishDate.fromDateTime(now).getJewishYear();
      jewishDate.setJewishDate(hebrewYear + 1, month, day); // Use the next Hebrew year
      final gregorianDate = jewishDate.getGregorianCalendar();
      
      print('Next Year Gregorian Date: $gregorianDate');
      return gregorianDate;
    } catch (e) {
      print('Error converting date: $e');
      throw ArgumentError('Invalid Hebrew date provided.');
    }
  }
}


