import 'package:flutter/material.dart';
import '../models/yahrtzeit.dart';
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
  final _dayController = TextEditingController();
  final _groupController = TextEditingController();

  String? _selectedMonth;
  final YahrtzeitsManager manager = YahrtzeitsManager();

  final List<String> hebrewMonths = [
    'Tishrey', 'Cheshvan', 'Kislev', 'Tevet', 'Shvat', 'Adar', 'AdarAleph','AdarBeit',
    'Nissan', 'Iyar', 'Sivan', 'Tamuz', 'Av', 'Elul'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.yahrtzeit != null) {
      _englishNameController.text = widget.yahrtzeit!.englishName;
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
      _dayController.text = widget.yahrtzeit!.day.toString();
      _selectedMonth = hebrewMonths[widget.yahrtzeit!.month - 1];
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
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: InputDecoration(labelText: 'Select Month'),
                items: hebrewMonths.map((month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a month';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dayController,
                decoration: InputDecoration(labelText: 'Select Day'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a day';
                  }
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) {
                    return 'Please enter a valid day';
                  }
                  return null;
                },
              ),
               TextFormField(
                controller: _groupController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Group name';
                  }
                  return null;
                },
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

  void _saveYahrtzeit() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final selectedDay = int.parse(_dayController.text);
      final selectedMonth = hebrewMonths.indexOf(_selectedMonth!) + 1;
      final selectedDate = DateTime(now.year, selectedMonth, selectedDay);
      final newYahrtzeit = Yahrtzeit(
        englishName: _englishNameController.text,
        hebrewName: _hebrewNameController.text,
        day: selectedDay,
        month: selectedMonth,
        year: now.year,
        gregorianDate: selectedDate,
      );
      if (widget.isEditing && widget.yahrtzeit != null) {
        await manager.updateYahrtzeit(widget.yahrtzeit!, newYahrtzeit);
      } else {
        await manager.addYahrtzeit(newYahrtzeit);
      }
      Navigator.pop(context, true);
    }
  }
}



