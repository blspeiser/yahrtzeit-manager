import 'package:flutter/material.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';

class AddYahrtzeitPage extends StatefulWidget {
  @override
  _AddYahrtzeitPageState createState() => _AddYahrtzeitPageState();
}

class _AddYahrtzeitPageState extends State<AddYahrtzeitPage> {
  final _formKey = GlobalKey<FormState>();
  final _englishNameController = TextEditingController();
  final _hebrewNameController = TextEditingController();
  DateTime? _selectedDate;
  final YahrtzeitsManager manager = YahrtzeitsManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Yahrtzeit'),
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
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveYahrtzeit,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveYahrtzeit() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      // בקשת הרשאות
      var permissionsGranted = await manager.deviceCalendarPlugin.hasPermissions();
      print('Permissions Granted: $permissionsGranted');
      if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
        permissionsGranted = await manager.deviceCalendarPlugin.requestPermissions();
        print('Requested Permissions: $permissionsGranted');
        if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calendar permissions not granted')),
          );
          return;
        }
      }

      final newYahrtzeit = Yahrtzeit(
        englishName: _englishNameController.text,
        hebrewName: _hebrewNameController.text,
        day: _selectedDate!.day,
        month: _selectedDate!.month,
        year: _selectedDate!.year,
        gregorianDate: _selectedDate!,
      );
      await manager.addYahrtzeit(newYahrtzeit);
      Navigator.pop(context);
    }
  }
}
