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
  DateTime? _selectedDate;
  final YahrtzeitsManager manager = YahrtzeitsManager();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.yahrtzeit != null) {
      _englishNameController.text = widget.yahrtzeit!.englishName;
      _hebrewNameController.text = widget.yahrtzeit!.hebrewName;
      _selectedDate = widget.yahrtzeit!.gregorianDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.isEditing ? 'Edit Yahrtzeit' : 'Add Yahrtzeit'),
         title: Text(widget.isEditing ? AppLocalizations.of(context)!.translate('Edit Yahrtzeit') : AppLocalizations.of(context)!.translate('Add Yahrtzeit')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _englishNameController,
                // decoration: InputDecoration(labelText: 'English Name'),
                //  title: Text(AppLocalizations.of(context)!.translate('settings'), style: TextStyle(color: Colors.white)),
                decoration: InputDecoration( labelText: (AppLocalizations.of(context)!.translate('Jewish Name'))),
 

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return (AppLocalizations.of(context)!.translate('Please enter English name'));
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewNameController,
                decoration: InputDecoration( labelText: (AppLocalizations.of(context)!.translate('Full Name'))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return (AppLocalizations.of(context)!.translate('Please enter Hebrew name'));
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? (AppLocalizations.of(context)!.translate('Select Date'))
                      :(AppLocalizations.of(context)!.translate('Select Date:${_selectedDate!.toLocal()}')) 
                          .split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveYahrtzeit,
                child: Text(widget.isEditing ? (AppLocalizations.of(context)!.translate('Update')) :(AppLocalizations.of(context)!.translate('Save')) ),
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
      final newYahrtzeit = Yahrtzeit(
        englishName: _englishNameController.text,
        hebrewName: _hebrewNameController.text,
        day: _selectedDate!.day,
        month: _selectedDate!.month,
        year: _selectedDate!.year,
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
