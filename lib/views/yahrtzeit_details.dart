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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppIconDecorative(),
        title: Text(
          localizations.translate("details"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yahrtzeitDate.yahrtzeit.englishName ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textCardTitle,
                      ),
                    ),
                    if (yahrtzeitDate.yahrtzeit.hebrewName != null &&
                        yahrtzeitDate.yahrtzeit.hebrewName!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        yahrtzeitDate.yahrtzeit.hebrewName!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textCardTitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Date Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('gregorian_date'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      gregorianFormatter.format(yahrtzeitDate.gregorianDate),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textCardTitle,
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(color: AppTheme.cardBorderColor),
                    SizedBox(height: 20),
                    Text(
                      localizations.translate('hebrew_date'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      hebrewFormatter.format(yahrtzeitDate.hebrewDate),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textCardTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
