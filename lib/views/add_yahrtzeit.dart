import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';
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
  final _gregorianDateController = TextEditingController();
  final _hebrewDateController = TextEditingController();
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
              TextFormField(
                controller: _gregorianDateController,
                decoration: InputDecoration(
                  labelText: 'Gregorian Date',
                  hintText: 'dd/MM/yyyy',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Gregorian Date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hebrewDateController,
                decoration: InputDecoration(
                  labelText: 'Hebrew Date',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Hebrew Date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveYahrtzeit,
                child: Text('Save Yahrtzeit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _saveYahrtzeit() async {
  //   if (_formKey.currentState!.validate()) {
  //     var permissionsGranted = await manager.deviceCalendarPlugin.hasPermissions();
  //     print('Permissions Granted: $permissionsGranted');
  //     if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
  //       permissionsGranted = await manager.deviceCalendarPlugin.requestPermissions();
  //       print('Requested Permissions: $permissionsGranted');
  //       if (permissionsGranted?.isSuccess == false || permissionsGranted?.data == false) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Calendar permissions not granted')),
  //         );
  //         return;
  //       }
  //     }

  //     final pattern = OffsetDateTimePattern.createWithInvariantCulture('dd/MM/yyyy');
  //     final parseResult = pattern.parse(_gregorianDateController.text);
  //     if (!parseResult.success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Invalid date format')),
  //       );
  //       return;
  //     }

  //     final offsetDateTime = parseResult.value;
  //     final localDateTime = offsetDateTime.localDateTime;
  //     final timeZone = await DateTimeZoneProviders.tzdb.getZoneOrNull("Asia/Jerusalem");
  //     if (timeZone == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Time zone not found')),
  //       );
  //       return;
  //     }
  //     final zonedDateTime = ZonedDateTime(localDateTime as Instant, timeZone, offsetDateTime.offset as CalendarSystem?);

  //     final newYahrtzeit = Yahrtzeit(
  //       englishName: _englishNameController.text,
  //       hebrewName: _hebrewNameController.text,
  //       day: localDateTime.dayOfMonth,
  //       month: localDateTime.monthOfYear,
  //       year: localDateTime.year,
  //       gregorianDate: zonedDateTime,
  //     );

  //     await manager.addYahrtzeit(newYahrtzeit);
  //     Navigator.pop(context);
  //   }
  // }
void _saveYahrtzeit() async {
  if (_formKey.currentState!.validate()) {
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

    final pattern = OffsetDateTimePattern.createWithInvariantCulture('dd/MM/yyyy');
    final parseResult = pattern.parse(_gregorianDateController.text);
    if (!parseResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date format')),
      );
      return;
    }

    final offsetDateTime = parseResult.value;
    final localDateTime = offsetDateTime.localDateTime;

    // Get the timezone provider
    final timeZoneProvider = await DateTimeZoneProviders.tzdb;
    final timeZone = timeZoneProvider['Asia/Jerusalem'];
    if (timeZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Time zone not found')),
      );
      return;
    }

    final zonedDateTime = ZonedDateTime(localDateTime as Instant, timeZone as DateTimeZone?, offsetDateTime.offset as CalendarSystem?);

    final newYahrtzeit = Yahrtzeit(
      englishName: _englishNameController.text,
      hebrewName: _hebrewNameController.text,
      day: localDateTime.dayOfMonth,
      month: localDateTime.monthOfYear,
      year: localDateTime.year,
      gregorianDate: zonedDateTime,
    );

    await manager.addYahrtzeit(newYahrtzeit);
    Navigator.pop(context);
  }
}

}


