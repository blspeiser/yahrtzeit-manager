import 'package:flutter/material.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AddYahrtzeitPage extends StatefulWidget {
  final Yahrtzeit? yahrtzeit;
  final bool isEditing;
  int yearsToSync;
  bool syncSettings;

  AddYahrtzeitPage({
    this.yahrtzeit,
    this.isEditing = false,
    required this.yearsToSync,
    required this.syncSettings,
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
      _englishNameController.text = widget.yahrtzeit!.englishName!;
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
      _selectedDay = widget.yahrtzeit!.day;
      _selectedMonth = widget.yahrtzeit!.month;
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/yahrtzeit_data.json');
  }

  Future<File> writeData(List<Map<String, dynamic>> data) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(data));
  }

  Future<List<Map<String, dynamic>>> readData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return List<Map<String, dynamic>>.from(json.decode(contents));
      } else {
        return [];
      }
    } catch (e) {
      print('Error reading JSON file: $e');
      return [];
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final localizations = AppLocalizations.of(context)!;
      final navigator = Navigator.of(context);

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

          final newYahrtzeit = Yahrtzeit(
            englishName: _englishNameController.text,
            hebrewName: _hebrewNameController.text,
            day: _selectedDay!,
            month: _selectedMonth!,
            group: _groupController.text,
          );

          newYahrtzeits.add(newYahrtzeit);

        jsonData.addAll(newYahrtzeits.map((y) => y.toJson()).toList());

        if (widget.syncSettings) {
          for (var yahrtzeit in newYahrtzeits) {
            await manager.addYahrtzeit(yahrtzeit, widget.yearsToSync, widget.syncSettings);
          }
        }

        await writeData(jsonData);
        print('JSON file content: ${json.encode(jsonData)}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved!')),
        );

        navigator.pop(true);
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
  //  @override
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
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('day')),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _selectedDay = int.tryParse(value);
                },
                validator: (value) {
                  if (_selectedDay == null || _selectedDay! < 1 || _selectedDay! > 30) {
                    return 'Please enter a valid day';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // Add spacing between fields
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('month')),
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
                validator: (value) {
                  if (value == null) {
                    return 'Please select a month';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _groupController,
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(AppLocalizations.of(context)!
                    .translate(widget.isEditing ? 'update' : 'save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }