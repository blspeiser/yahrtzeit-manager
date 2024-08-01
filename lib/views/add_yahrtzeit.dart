import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
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
  String? _selectedMonth;
  DateTime? _selectedDate;
  final YahrtzeitsManager manager = YahrtzeitsManager();

  final List<String> hebrewMonths = [
    'Tishrey', 'Cheshvan', 'Kislev', 'Tevet', 'Shvat', 'Adar',
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
      _selectedDate = widget.yahrtzeit!.gregorianDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? AppLocalizations.of(context)!.translate('Edit Yahrtzeit')
            : AppLocalizations.of(context)!.translate('Add Yahrtzeit')),
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
                        .translate('Jewish Name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('Please enter Jewish name');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewNameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .translate('Full Name')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('Please enter Full name');
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .translate('Select Month')),
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
                    return AppLocalizations.of(context)!
                        .translate('Please select a month');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dayController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .translate('Select Day')),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('Please enter a day');
                  }
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) {
                    return AppLocalizations.of(context)!
                        .translate('Please enter a valid day');
                  }
                  return null;
                },
              ),
             
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveYahrtzeit,
                child: Text(widget.isEditing
                    ? AppLocalizations.of(context)!.translate('Update')
                    : AppLocalizations.of(context)!.translate('Save')),
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
      initialDate: _selectedDate ?? DateTime.now(),
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
        gregorianDate: _selectedDate!,
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
