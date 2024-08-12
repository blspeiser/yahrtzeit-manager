import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../localizations/app_localizations.dart';
import '../models/yahrtzeit_date.dart';
import '../settings/settings.dart';

class YahrtzeitDetailsPage extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  YahrtzeitDetailsPage({required this.yahrtzeitDate});

  @override
  Widget build(BuildContext context) {
    final gregorianFormatter = DateFormat('MMMM d, yyyy');
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;
    // קבלת השפה הנוכחית
    final locale = Localizations.localeOf(context).languageCode;

    // בחירת השם להציג לפי השפה הנוכחית
    final String nameToDisplay = locale == 'he'
        ? (yahrtzeitDate.yahrtzeit.hebrewName ?? 'Unknown Name')
        : (yahrtzeitDate.yahrtzeit.englishName ?? 'Unknown Name');

    return Scaffold(
      appBar: AppBar(
        title: Text('${nameToDisplay}', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
        elevation: 0,
        actionsIconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              final icsContent = _createICSContent(yahrtzeitDate);
              print('ICS Content: $icsContent'); // Debug: Print ICS content

              final directory = await getTemporaryDirectory();
              final filePath = '${directory.path}/yahrtzeit.ics';
              final file = File(filePath);
              await file.writeAsString(icsContent);

              Share.shareFiles([filePath], text: 'Yahrtzeit Details');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    AppLocalizations.of(context)!.translate('English Name'),
                    yahrtzeitDate.yahrtzeit.englishName!),
                _buildDetailRow(
                    AppLocalizations.of(context)!.translate('Hebrew Name'),
                    yahrtzeitDate.yahrtzeit.hebrewName),
                _buildDetailRow(
                    AppLocalizations.of(context)!.translate('gregorian_date'),
                    gregorianFormatter.format(yahrtzeitDate.gregorianDate)),
                _buildDetailRow(
                    AppLocalizations.of(context)!.translate('hebrew_gate'),
                    hebrewFormatter.format(yahrtzeitDate.hebrewDate)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _createICSContent(YahrtzeitDate yahrtzeitDate) {
    final buffer = StringBuffer();

    buffer.writeln("BEGIN:VCALENDAR");
    buffer.writeln("VERSION:2.0");
    buffer.writeln("PRODID:-//YourApp//Yahrtzeit Manager//EN");

    try {
      final start = DateFormat("yyyyMMdd'T'HHmmss'Z'")
          .format(yahrtzeitDate.gregorianDate);
      final end = DateFormat("yyyyMMdd'T'HHmmss'Z'")
          .format(yahrtzeitDate.gregorianDate.add(Duration(hours: 2)));

      buffer.writeln("BEGIN:VEVENT");
      buffer.writeln(
          "SUMMARY:${yahrtzeitDate.yahrtzeit.englishName ?? yahrtzeitDate.yahrtzeit.hebrewName}");
      buffer.writeln("DTSTART:$start");
      buffer.writeln("DTEND:$end");
      buffer.writeln(
          "DESCRIPTION:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName ?? yahrtzeitDate.yahrtzeit.hebrewName}");
      buffer.writeln("END:VEVENT");
    } catch (e) {
      print(
          "Error with Yahrtzeit: ${yahrtzeitDate.yahrtzeit.englishName ?? yahrtzeitDate.yahrtzeit.hebrewName}, Error: $e");
    }

    buffer.writeln("END:VCALENDAR");

    return buffer.toString();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
