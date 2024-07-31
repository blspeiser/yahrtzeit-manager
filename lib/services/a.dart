import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter();
  final HebrewDateFormatter translatedDateFormatter = HebrewDateFormatter()..hebrewFormat = false;

  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();

  String _gregorianDate = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kosher Dart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _dayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Day'),
            ),
            TextField(
              controller: _monthController,
              decoration: InputDecoration(labelText: 'Enter Month (e.g., Tishrey)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertDate,
              child: Text('Convert to Gregorian Date'),
            ),
            SizedBox(height: 20),
            Text(
              'Gregorian Date: $_gregorianDate',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _convertDate() {
    final int? day = int.tryParse(_dayController.text);
    final String? month = _monthController.text;

    if (day == null || month == null || !HebrewMonths.months.contains(month)) {
      setState(() {
        _gregorianDate = 'Invalid input';
      });
      return;
    }

    final int monthIndex = HebrewMonths.months.indexOf(month) + 1;

    try {
      final jewishDate = CustomJewishDate(day: day, month: monthIndex);
      final gregorianDate = jewishDate.toGregorian();

      setState(() {
        _gregorianDate = DateFormat('yyyy-MM-dd').format(gregorianDate);
      });
    } catch (e) {
      setState(() {
        _gregorianDate = 'Error: ${e.toString()}';
      });
    }
  }
}

class CustomJewishDate {
  final int day;
  final int month;
  final int year;

  CustomJewishDate({
    required this.day,
    this.month = 1,
    this.year = 5784, // Default to current Jewish year
  });

  DateTime toGregorian() {
    final jewishCalendar = JewishCalendar();
    final jewishDate = JewishDate();

    // Set the date
    jewishDate.setDate(DateTime(year, month, day));

    // Get Gregorian date
    final gregorianDate = jewishCalendar.getGregorianCalendar(jewishDate);

    return gregorianDate;
  }
}