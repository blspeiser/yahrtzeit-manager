import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit_date.dart';
import '../providers/settings_provider.dart';
import '../services/yahrtzeits_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/yahrtzeit_tile.dart';
import '../widgets/app_icon_decorative.dart';

class UpcomingYahrtzeits extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const UpcomingYahrtzeits({super.key, this.onDataChanged});

  @override
  UpcomingYahrtzeitsState createState() => UpcomingYahrtzeitsState();
}

class UpcomingYahrtzeitsState extends State<UpcomingYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<YahrtzeitDate> yahrtzeitDates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final yahrtzeits = await manager.getAllYahrtzeits();

      // Get all yahrtzeit dates
      final allDates = manager.nextMultiple(yahrtzeits);

      // Filter to only show upcoming dates within the selected range
      if (!mounted) return;
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final rangeMonths = settingsProvider.upcomingRangeMonths;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // Calculate end date properly handling month overflow
      final endYear = now.year + ((now.month + rangeMonths - 1) ~/ 12);
      final endMonth = ((now.month + rangeMonths - 1) % 12) + 1;
      final endDate = DateTime(endYear, endMonth, now.day);
      final upcomingDates = allDates.where((date) {
        final dateOnly = DateTime(date.gregorianDate.year,
            date.gregorianDate.month, date.gregorianDate.day);
        return (dateOnly.isAfter(today) || dateOnly.isAtSameMomentAs(today)) &&
            (dateOnly.isBefore(endDate) || dateOnly.isAtSameMomentAs(endDate));
      }).toList();

      setState(() {
        yahrtzeitDates = _filterDuplicateYahrtzeits(upcomingDates);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<YahrtzeitDate> _filterDuplicateYahrtzeits(
      List<YahrtzeitDate> yahrtzeits) {
    final uniqueKeys = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeitDate in yahrtzeits) {
      // Use English name as primary key, fallback to Hebrew name, then ID
      final englishName = yahrtzeitDate.yahrtzeit.englishName?.trim();
      final hebrewName = yahrtzeitDate.yahrtzeit.hebrewName?.trim();
      
      String uniqueKey;
      if (englishName != null && englishName.isNotEmpty) {
        uniqueKey = englishName;
      } else if (hebrewName != null && hebrewName.isNotEmpty) {
        uniqueKey = 'hebrew_$hebrewName';
      } else {
        // Fallback to ID for entries without any name
        uniqueKey = 'id_${yahrtzeitDate.yahrtzeit.id}';
      }
      
      if (uniqueKeys.add(uniqueKey)) {
        filteredList.add(yahrtzeitDate);
      }
    }

    return filteredList;
  }

  Widget _buildSegmentedControl(
      BuildContext context, SettingsProvider settings) {
    final localizations = AppLocalizations.of(context)!;
    final monthAbbr = localizations.translate('month_abbreviation');
    final options = [
      {'label': '1 $monthAbbr', 'value': 1},
      {'label': '3 $monthAbbr', 'value': 3},
      {'label': '6 $monthAbbr', 'value': 6},
      {'label': '12 $monthAbbr', 'value': 12},
    ];
    final selectedValue = settings.upcomingRangeMonths;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.cardBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = option['value'] == selectedValue;
          final isFirst = index == 0;
          final isLast = index == options.length - 1;

          return Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    settings.setUpcomingRangeMonths(option['value'] as int);
                    fetchYahrtzeits();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: isFirst ? Radius.circular(7) : Radius.zero,
                        bottomLeft: isFirst ? Radius.circular(7) : Radius.zero,
                        topRight: isLast ? Radius.circular(7) : Radius.zero,
                        bottomRight: isLast ? Radius.circular(7) : Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.inactiveTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Divider between segments (except for the last one)
                if (!isLast)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: AppTheme.cardBorderColor,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            leading: AppIconDecorative(),
            title: Text(
              AppLocalizations.of(context)!.translate('upcoming_yahrtzeits'),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            actionsIconTheme: IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              // Range selector segmented control
              Container(
                color: AppTheme.backgroundColor,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: _buildSegmentedControl(context, settings),
              ),
              // Content area
              Expanded(
                child: Container(
                  color: AppTheme.backgroundColor,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        )
                      : yahrtzeitDates.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('no_upcoming_yahrtzeits_found'),
                                style: TextStyle(
                                    fontSize: 18, color: AppTheme.textTertiary),
                              ),
                            )
                          : ListView.builder(
                              itemCount: yahrtzeitDates.length,
                              itemBuilder: (context, index) {
                                final yahrtzeitDate = yahrtzeitDates[index];
                                return YahrtzeitTile(
                                    yahrtzeitDate: yahrtzeitDate);
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
