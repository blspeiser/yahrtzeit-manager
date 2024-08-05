import 'package:cambium_project/views/manage_yahrtzeits.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';

class AddYahrtzeitPage extends StatefulWidget {
  final Yahrtzeit? yahrtzeit;
  final bool isEditing;
  int yearsToSync;

  AddYahrtzeitPage(
      {this.yahrtzeit, this.isEditing = false, required this.yearsToSync});

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
    if (widget.isEditing && widget.yahrtzeit != null) {
      _englishNameController.text = widget.yahrtzeit!.englishName;
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
      _selectedDay = widget.yahrtzeit!.day;
      _selectedMonth = widget.yahrtzeit!.month;
    }
  }
  // JewishDate jewishDate = JewishDate.initDate(jewishYear: 5784, jewishMonth: 5, jewishDayOfMonth: 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Yahrtzeit' : 'Add Yahrtzeit'),
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
                        .translate('english_name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter English name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewNameController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('hebrew_name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Hebrew name';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!
                    .translate('select_hebrew_date')),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickHebrewDate,
              ),
              TextFormField(
                controller: _groupController,
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveYahrtzeit,
                child: Text(AppLocalizations.of(context)!
                    .translate(widget.isEditing ? 'update' : 'save')),
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
          title: Text(
              AppLocalizations.of(context)!.translate('select_hebrew_date')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('day')),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  day = int.tryParse(value);
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('month')),
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
              child: Text(AppLocalizations.of(context)!.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                if (day != null && month != null) {
                  setState(() {
                    _selectedDay = day!;
                    _selectedMonth = month;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  // void _saveYahrtzeit() async {
  //   if (_formKey.currentState!.validate() &&
  //       _selectedDay != null &&
  //       _selectedMonth != null) {
  //     try {
  //       for (int i = 0; i < widget.yearsToSync; i++) {
  //         print(AppLocalizations.of(context)!.translate('saving_yahrtzeit...'));
  //         // final gregorianDate = _getNextGregorianDate(_selectedDay!, _selectedMonth!);
  //         // print(AppLocalizations.of(context)!.translate('gregorian_date') + ': $gregorianDate');
  //         int year = JewishDate().getJewishYear() + i;
  //         JewishDate jewishDate = JewishDate.initDate(
  //             jewishYear: year,
  //             jewishMonth: _selectedMonth!,
  //             jewishDayOfMonth: _selectedDay!);
  //         DateTime gregorianDate = DateTime(
  //             jewishDate.getGregorianYear(),
  //             jewishDate.getGregorianMonth(),
  //             jewishDate.getGregorianDayOfMonth());
  //         print(AppLocalizations.of(context)!.translate('gregorian_date') +
  //             ': $gregorianDate');
  //         final newYahrtzeit = Yahrtzeit(
  //           englishName: _englishNameController.text,
  //           hebrewName: _hebrewNameController.text,
  //           day: _selectedDay!,
  //           month: _selectedMonth!,
  //           group: _groupController.text,
  //           // year: JewishDate().getJewishYear() + 1, // Use the next Hebrew year
  //           year: year,
  //           gregorianDate: gregorianDate,
  //         );
  //         print(AppLocalizations.of(context)!.translate('new_yahrtzeit') +
  //             ': $newYahrtzeit');
  //         if (widget.isEditing && widget.yahrtzeit != null) {
  //           await manager.updateYahrtzeit(widget.yahrtzeit!, newYahrtzeit);
  //         } else {
  //           await manager.addYahrtzeit(newYahrtzeit);
  //         }
  //         print(AppLocalizations.of(context)!
  //             .translate('yahrtzeit_saved_successfully'));
  //         Navigator.pop(
  //           context,
  //         );
  //       }
  //     } catch (e) {
  //       print(AppLocalizations.of(context)!.translate('error') + ': $e');
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text(AppLocalizations.of(context)!.translate('error')),
  //           content:
  //               Text(AppLocalizations.of(context)!.translate('error') + ': $e'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text(AppLocalizations.of(context)!.translate('ok')),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  // }

  void _saveYahrtzeit() async {
  if (_formKey.currentState!.validate() &&
      _selectedDay != null &&
      _selectedMonth != null) {
    // Save the necessary values from the context before starting the async operations
    final localizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    try {
      for (int i = 0; i < widget.yearsToSync; i++) {
        print(localizations.translate('saving_yahrtzeit...'));

        int year = JewishDate().getJewishYear() + i;
        JewishDate jewishDate = JewishDate.initDate(
            jewishYear: year,
            jewishMonth: _selectedMonth!,
            jewishDayOfMonth: _selectedDay!);
        DateTime gregorianDate = DateTime(
            jewishDate.getGregorianYear(),
            jewishDate.getGregorianMonth(),
            jewishDate.getGregorianDayOfMonth());

        print(localizations.translate('gregorian_date') + ': $gregorianDate');

        final newYahrtzeit = Yahrtzeit(
          englishName: _englishNameController.text,
          hebrewName: _hebrewNameController.text,
          day: _selectedDay!,
          month: _selectedMonth!,
          group: _groupController.text,
          // year: year,
          // gregorianDate: gregorianDate,
        );

        print(localizations.translate('new_yahrtzeit') + ': $newYahrtzeit');

        if (widget.isEditing && widget.yahrtzeit != null) {
          await manager.updateYahrtzeit(widget.yahrtzeit!, newYahrtzeit, widget.yearsToSync);
        } else {
          await manager.addYahrtzeit(newYahrtzeit, widget.yearsToSync);
        }

        print(localizations.translate('yahrtzeit_saved_successfully'));
      }

      navigator.pop();
    } catch (e) {
      print(localizations.translate('error') + ': $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.translate('error')),
          content: Text(localizations.translate('error') + ': $e'),
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


  // DateTime _getNextGregorianDate(int day, int month) {
  //   try {
  //     final now = DateTime.now();
  //     final jewishDate = JewishDate();
  //     final hebrewYear = JewishDate.fromDateTime(now).getJewishYear();
  //     jewishDate.setJewishDate(hebrewYear + 1, month, day); // Use the next Hebrew year
  //     final gregorianDate = jewishDate.getGregorianCalendar();

  //     print('Next Year Gregorian Date: $gregorianDate');
  //     return gregorianDate;
  //   } catch (e) {
  //     print('Error converting date: $e');
  //     throw ArgumentError('Invalid Hebrew date provided.');
  //   }
  // }
}
