import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import '../providers/settings_provider.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddYahrtzeitPage extends StatefulWidget {
  final Yahrtzeit? yahrtzeit;
  final bool isEditing;

  AddYahrtzeitPage({
    this.yahrtzeit,
    this.isEditing = false,
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
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      try {
        List<Map<String, dynamic>> jsonData = await readData();

        List<Yahrtzeit> newYahrtzeits = [];

        final newYahrtzeit = Yahrtzeit(
          englishName: _englishNameController.text,
          hebrewName: _hebrewNameController.text,
          day: _selectedDay!,
          month: _selectedMonth!,
          group: _groupController.text,
          id: widget.isEditing && widget.yahrtzeit != null 
              ? widget.yahrtzeit!.id 
              : null, // Preserve ID when editing
        );

        if (widget.isEditing && widget.yahrtzeit != null) {
          // Update existing yahrtzeit - manager handles file updates
          await manager.updateYahrtzeit(
            widget.yahrtzeit!,
            newYahrtzeit,
            settingsProvider.years,
            settingsProvider.syncSettings);
          
          // Reschedule notifications if enabled
          if (settingsProvider.notifications) {
            await manager.rescheduleAllNotifications(
              true, 
              settingsProvider.days);
          }
        } else {
          // Add new yahrtzeit
          newYahrtzeits.add(newYahrtzeit);
          jsonData.addAll(newYahrtzeits.map((y) => y.toJson()).toList());
          await writeData(jsonData);

          if (settingsProvider.syncSettings) {
            for (var yahrtzeit in newYahrtzeits) {
              await manager.addYahrtzeit(
                  yahrtzeit, 
                  settingsProvider.years, 
                  settingsProvider.syncSettings,
                  notificationsEnabled: settingsProvider.notifications,
                  daysBefore: settingsProvider.days);
            }
          } else if (settingsProvider.notifications) {
            // If sync is off but notifications are on, still schedule notifications
            for (var yahrtzeit in newYahrtzeits) {
              await manager.addYahrtzeit(
                  yahrtzeit, 
                  settingsProvider.years, 
                  false,
                  notificationsEnabled: true,
                  daysBefore: settingsProvider.days);
            }
          }
        }
        print('JSON file content: ${json.encode(jsonData)}');

        // Log the new data to ensure it's saved correctly
        final savedData = await readData();
        print('Saved Data: $savedData');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved!')),
        );

        Navigator.pop(context, true);
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
                    labelText:
                        AppLocalizations.of(context)!.translate('English Name')),
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
                        AppLocalizations.of(context)!.translate('Hebrew Name')),
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
                  if (_selectedDay == null ||
                      _selectedDay! < 1 ||
                      _selectedDay! > 30) {
                    return 'Please enter a valid day';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // Add spacing between fields
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('month')),
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
