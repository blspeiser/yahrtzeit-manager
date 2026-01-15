import 'package:flutter/material.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:share_plus/share_plus.dart';
import '../models/yahrtzeit_date.dart';
import '../localizations/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon_decorative.dart';
import 'package:intl/intl.dart';

class YahrtzeitDetailsPage extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  YahrtzeitDetailsPage({required this.yahrtzeitDate});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final gregorianFormatter = DateFormat('MMMM d, yyyy');
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;

    return Scaffold(
      appBar: AppBar(
        leading: AppIconDecorative(),
        title: Text(
            '${yahrtzeitDate.yahrtzeit.englishName} ${localizations.translate("details")}'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                '${localizations.translate("yahrtzeit_details")}:\n\n'
                '${localizations.translate("english_name")}: ${yahrtzeitDate.yahrtzeit.englishName}\n'
                '${localizations.translate("hebrew_name")}: ${yahrtzeitDate.yahrtzeit.hebrewName ?? ''}\n'
                '${localizations.translate("gregorian_date")}: ${gregorianFormatter.format(yahrtzeitDate.gregorianDate)}\n'
                '${localizations.translate("hebrew_date")}: ${hebrewFormatter.format(yahrtzeitDate.hebrewDate)}',
              );
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
                _buildDetailRow(localizations.translate('english_name'),
                    yahrtzeitDate.yahrtzeit.englishName ?? ''),
                _buildDetailRow(localizations.translate('hebrew_name'),
                    yahrtzeitDate.yahrtzeit.hebrewName ?? ''),
                _buildDetailRow(localizations.translate('gregorian_date'),
                    gregorianFormatter.format(yahrtzeitDate.gregorianDate)),
                _buildDetailRow(localizations.translate('hebrew_date'),
                    hebrewFormatter.format(yahrtzeitDate.hebrewDate)),
              ],
            ),
          ),
        ),
      ),
    );
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
              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
