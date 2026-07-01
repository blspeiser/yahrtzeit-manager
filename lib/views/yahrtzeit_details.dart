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

  const YahrtzeitDetailsPage({super.key, required this.yahrtzeitDate});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final gregorianFormatter = DateFormat('MMMM d, yyyy', locale.toString());
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
              final parts = <String>[
                '${localizations.translate("yahrtzeit_details")}:\n',
              ];
              // Include English name (civil name) if available
              if (yahrtzeitDate.yahrtzeit.englishName != null && 
                  yahrtzeitDate.yahrtzeit.englishName!.isNotEmpty) {
                parts.add('${localizations.translate("english_name")}: ${yahrtzeitDate.yahrtzeit.englishName}');
              }
              // Include Hebrew name (jewish name) if available
              if (yahrtzeitDate.yahrtzeit.hebrewName != null && 
                  yahrtzeitDate.yahrtzeit.hebrewName!.isNotEmpty) {
                parts.add('${localizations.translate("hebrew_name")}: ${yahrtzeitDate.yahrtzeit.hebrewName}');
              }
              parts.add('${localizations.translate("gregorian_date")}: ${gregorianFormatter.format(yahrtzeitDate.gregorianDate)}');
              parts.add('${localizations.translate("hebrew_date")}: ${hebrewFormatter.format(yahrtzeitDate.hebrewDate)}');
              SharePlus.instance.share(ShareParams(text: parts.join('\n')));
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
                    // Primary name: English (civil name) if available
                    if (yahrtzeitDate.yahrtzeit.englishName != null &&
                        yahrtzeitDate.yahrtzeit.englishName!.isNotEmpty) ...[
                      Text(
                        yahrtzeitDate.yahrtzeit.englishName!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textCardTitle,
                        ),
                      ),
                      // Show Hebrew name as secondary if English is present
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
                    ] else if (yahrtzeitDate.yahrtzeit.hebrewName != null &&
                        yahrtzeitDate.yahrtzeit.hebrewName!.isNotEmpty) ...[
                      // No English name - show Hebrew name as primary
                      Text(
                        yahrtzeitDate.yahrtzeit.hebrewName!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
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
