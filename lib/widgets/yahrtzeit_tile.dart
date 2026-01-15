import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../models/yahrtzeit_date.dart';
import '../views/yahrtzeit_details.dart';
import '../localizations/app_localizations.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class YahrtzeitTile extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  const YahrtzeitTile({Key? key, required this.yahrtzeitDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gregorianFormatter = DateFormat('MMMM d, yyyy');
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YahrtzeitDetailsPage(yahrtzeitDate: yahrtzeitDate),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yahrtzeitDate.yahrtzeit.englishName ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textCardTitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 4),
                    Text(
                      yahrtzeitDate.yahrtzeit.hebrewName ?? '',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textCardTitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          gregorianFormatter.format(yahrtzeitDate.gregorianDate),
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(width: 12),
                        Text(
                          hebrewFormatter.format(yahrtzeitDate.hebrewDate),
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4),
              PopupMenuButton<String>(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.more_vert, size: 20),
                onSelected: (value) async {
                  if (value == 'share') {
                    await _shareYahrtzeit(yahrtzeitDate);
                  } else if (value == 'details') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => YahrtzeitDetailsPage(yahrtzeitDate: yahrtzeitDate),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.translate('details')),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 18),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.translate('share')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareYahrtzeit(YahrtzeitDate yahrtzeitDate) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${yahrtzeitDate.yahrtzeit.englishName}.ics';
    final file = File(path);

    final icsContent = _createICSContent(yahrtzeitDate);
    await file.writeAsString(icsContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Yahrtzeit Details',
    );
  }

  String _createICSContent(YahrtzeitDate yahrtzeitDate) {
    final start = _formatDateTime(yahrtzeitDate.gregorianDate);
    final end = _formatDateTime(yahrtzeitDate.gregorianDate.add(Duration(hours: 1)));
    final now = _formatDateTime(DateTime.now());
    final uid = '${yahrtzeitDate.gregorianDate.microsecondsSinceEpoch}@yourdomain.com';
    
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
SUMMARY:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName ?? ''} (${yahrtzeitDate.yahrtzeit.hebrewName ?? ''})
DESCRIPTION:Yahrtzeit for ${yahrtzeitDate.yahrtzeit.englishName ?? ''} (${yahrtzeitDate.yahrtzeit.hebrewName ?? ''})
STATUS:CONFIRMED
TRANSP:OPAQUE
END:VEVENT
END:VCALENDAR
    ''';
  }

  String _formatDateTime(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0] + 'Z';
  }
}
