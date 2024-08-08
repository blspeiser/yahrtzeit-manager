import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import '../models/yahrtzeit_date.dart';
import '../views/yahrtzeit_details.dart';
import 'package:intl/intl.dart';

class YahrtzeitTile extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  const YahrtzeitTile({Key? key, required this.yahrtzeitDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gregorianFormatter = DateFormat('MMMM d, yyyy');
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yahrtzeitDate.yahrtzeit.englishName!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  gregorianFormatter.format(yahrtzeitDate.gregorianDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  yahrtzeitDate.yahrtzeit.hebrewName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  hebrewFormatter.format(yahrtzeitDate.hebrewDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  YahrtzeitDetailsPage(yahrtzeitDate: yahrtzeitDate),
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareYahrtzeit(YahrtzeitDate yahrtzeitDate) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${yahrtzeitDate.yahrtzeit.englishName}.ics';
    final file = File(path);

    final icsContent = _createICSContent(yahrtzeitDate);
    await file.writeAsString(icsContent);

    await Share.shareFiles([file.path], text: 'Yahrtzeit Details');
  }

  String _createICSContent(YahrtzeitDate yahrtzeitDate) {
    final start = _formatDateTime(yahrtzeitDate.gregorianDate);
    final end =
        _formatDateTime(yahrtzeitDate.gregorianDate.add(Duration(hours: 1)));
    final now = _formatDateTime(DateTime.now());
    final uid =
        '${yahrtzeitDate.gregorianDate.microsecondsSinceEpoch}@yourdomain.com';

    return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Your Organization//Your Product//EN
CALSCALE:GREGORIAN
BEGIN:VEVENT
UID:$uid
DTSTAMP:$now
DTSTART:$start
DTEND:$end
SUMMARY:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName} (${yahrtzeitDate.yahrtzeit.hebrewName})
DESCRIPTION:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName} (${yahrtzeitDate.yahrtzeit.hebrewName})
STATUS:CONFIRMED
TRANSP:OPAQUE
END:VEVENT
END:VCALENDAR
    ''';
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime
            .toUtc()
            .toIso8601String()
            .replaceAll('-', '')
            .replaceAll(':', '')
            .split('.')[0] +
        'Z';
  }
}
