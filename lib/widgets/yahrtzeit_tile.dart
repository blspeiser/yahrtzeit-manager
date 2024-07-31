import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import '../models/yahrtzeit_date.dart';
import '../views/yahrtzeit_details.dart';

class YahrtzeitTile extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  const YahrtzeitTile({Key? key, required this.yahrtzeitDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  yahrtzeitDate.yahrtzeit.englishName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${yahrtzeitDate.gregorianDate.toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  yahrtzeitDate.yahrtzeit.hebrewName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${yahrtzeitDate.hebrewDate}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.share),
          onPressed: () async {
            await _shareYahrtzeit(yahrtzeitDate);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YahrtzeitDetailsPage(yahrtzeitDate: yahrtzeitDate),
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
    final start = yahrtzeitDate.gregorianDate.toString().replaceAll('-', '').replaceAll(':', '');
    final end = yahrtzeitDate.gregorianDate.toString().replaceAll('-', '').replaceAll(':', '');
    return '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Your Organization//Your Product//EN
BEGIN:VEVENT
UID:${yahrtzeitDate.gregorianDate}@yourdomain.com
DTSTAMP:${DateTime.now().toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '')}
DTSTART:$start
DTEND:$end
SUMMARY:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName} (${yahrtzeitDate.yahrtzeit.hebrewName})
DESCRIPTION:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName} (${yahrtzeitDate.yahrtzeit.hebrewName})
END:VEVENT
END:VCALENDAR
    ''';
  }
}
