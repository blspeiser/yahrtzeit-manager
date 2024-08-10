import 'dart:io';
import 'package:cambium_project/models/yahrtzeit.dart';
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


String _formatDateTime(DateTime dateTime) {
  return DateFormat('yyyyMMddTHHmmss').format(dateTime.toUtc()) + 'Z';
}


}
