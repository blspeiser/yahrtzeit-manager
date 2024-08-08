// import 'package:flutter/material.dart';
// import 'package:kosher_dart/kosher_dart.dart';
// import 'package:share/share.dart';
// import '../localizations/app_localizations.dart';
// import '../models/yahrtzeit_date.dart';
// import 'package:intl/intl.dart';

// class YahrtzeitDetailsPage extends StatelessWidget {
//   final YahrtzeitDate yahrtzeitDate;

//   YahrtzeitDetailsPage({required this.yahrtzeitDate});

//   @override
//   Widget build(BuildContext context) {
//     final gregorianFormatter = DateFormat('MMMM d, yyyy');
//     final hebrewFormatter = HebrewDateFormatter()
//       ..hebrewFormat = true
//       ..useGershGershayim = true;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             '${yahrtzeitDate.yahrtzeit.englishName} ${AppLocalizations.of(context)!.translate('Details')}',
//             style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 50, 4, 129),
//         elevation: 0,
//         actionsIconTheme: IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.share),
//             onPressed: () {
//               Share.share(
//                 'Yahrtzeit Details:\n\n'
//                 'English Name: ${yahrtzeitDate.yahrtzeit.englishName}\n'
//                 'Hebrew Name: ${yahrtzeitDate.yahrtzeit.hebrewName}\n'
//                 'Gregorian Date: ${gregorianFormatter.format(yahrtzeitDate.gregorianDate)}\n'
//                 'Hebrew Date: ${hebrewFormatter.format(yahrtzeitDate.hebrewDate)}',
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           elevation: 5,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDetailRow(
//                     AppLocalizations.of(context)!.translate('English Name'),
//                     yahrtzeitDate.yahrtzeit.englishName!),
//                 _buildDetailRow(
//                     AppLocalizations.of(context)!.translate('Hebrew Name'),
//                     yahrtzeitDate.yahrtzeit.hebrewName),
//                 _buildDetailRow(
//                     AppLocalizations.of(context)!.translate('gregorian_date'),
//                     gregorianFormatter.format(yahrtzeitDate.gregorianDate)),
//                 _buildDetailRow(
//                     AppLocalizations.of(context)!.translate('hebrew_gate'),
//                     hebrewFormatter.format(yahrtzeitDate.hebrewDate)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             '$label:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../localizations/app_localizations.dart';
import '../models/yahrtzeit_date.dart';

class YahrtzeitDetailsPage extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  YahrtzeitDetailsPage({required this.yahrtzeitDate});

  @override
  Widget build(BuildContext context) {
    final gregorianFormatter = DateFormat('MMMM d, yyyy');
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${yahrtzeitDate.yahrtzeit.englishName} ${AppLocalizations.of(context)!.translate('Details')}',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor:Colors.grey,
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
                    AppLocalizations.of(context)!.translate('Gregorian Date'),
                    gregorianFormatter.format(yahrtzeitDate.gregorianDate)),
                _buildDetailRow(
                    AppLocalizations.of(context)!.translate('Hebrew Date'),
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
      // Convert Jewish date to Gregorian
      final jewishDate = JewishDate.initDate(
        jewishYear: yahrtzeitDate.yahrtzeit.day!,
        jewishMonth: yahrtzeitDate.yahrtzeit.month!,
        jewishDayOfMonth: yahrtzeitDate.yahrtzeit.day!,
      );
      final gregorianDate = DateTime(
        jewishDate.getGregorianYear(),
        jewishDate.getGregorianMonth(),
        jewishDate.getGregorianDayOfMonth(),
      );

      final start = DateFormat("yyyyMMdd").format(gregorianDate);
      buffer.writeln("BEGIN:VEVENT");
      buffer.writeln("UID:${yahrtzeitDate.yahrtzeit.id}");
      buffer.writeln("SUMMARY:${yahrtzeitDate.yahrtzeit.englishName ?? yahrtzeitDate.yahrtzeit.hebrewName}");
      buffer.writeln("DTSTART:$start");
      buffer.writeln("DURATION:PT24H"); // Event duration 24 hours
      buffer.writeln("END:VEVENT");
    } catch (e) {
      print("Error with Yahrtzeit: ${yahrtzeitDate.yahrtzeit.englishName ?? yahrtzeitDate.yahrtzeit.hebrewName}, Error: $e");
      // Optionally handle the error here
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
