import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';
import '../widgets/format.dart';
import 'add_yahrtzeit.dart';
import 'dart:convert';

class ManageYahrtzeits extends StatefulWidget {
  final int yearsToSync;
  final bool syncSettings;
  final bool notifications;
  final String language;
  final String jewishLanguage;
  final String calendar;
  final int years;
  final int days;
  final int months;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;
  final Function(int) changeMonths;

  const ManageYahrtzeits({
    required this.yearsToSync,
    required this.syncSettings,
    required this.notifications,
    required this.language,
    required this.jewishLanguage,
    required this.calendar,
    required this.years,
    required this.days,
    required this.months,
    required this.toggleSyncSettings,
    required this.toggleNotifications,
    required this.changeLanguage,
    required this.changeJewishLanguage,
    required this.changeCalendar,
    required this.changeYears,
    required this.changeDays,
    required this.changeMonths,
    Key? key,
  }) : super(key: key);

  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  List<YahrtzeitDate> yahrtzeitDates = [];
  List<Yahrtzeit> _yahrtzeits = [];
  List<DateTime> _upcomingDates = [];
  bool isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<YahrtzeitDate> filteredYahrtzeitDates = [];
  String searchQuery = '';

  static const Map<int, String> hebrewMonths = {
    JewishDate.TISHREI: 'Tishrei',
    JewishDate.CHESHVAN: 'Cheshvan',
    JewishDate.KISLEV: 'Kislev',
    JewishDate.TEVES: 'Teves',
    JewishDate.SHEVAT: 'Shevat',
    JewishDate.ADAR: 'Adar',
    JewishDate.ADAR_II: 'Adar II',
    JewishDate.NISSAN: 'Nissan',
    JewishDate.IYAR: 'Iyar',
    JewishDate.SIVAN: 'Sivan',
    JewishDate.TAMMUZ: 'Tammuz',
    JewishDate.AV: 'Av',
    JewishDate.ELUL: 'Elul',
  };

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> writeData(List<Map<String, dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('yahrtzeit_data', json.encode(data));
    print('Written Data: ${json.encode(data)}');
  }

  Future<List<Yahrtzeit>> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    print('Read JSON String: $jsonString');
    if (jsonString != null) {
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      print('Parsed JSON Data: $jsonData');
      return jsonData.map((data) => Yahrtzeit.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  void fetchYahrtzeits() async {
    try {
      final fetchedYahrtzeits = await readData();
      print("Fetched Yahrtzeits: $fetchedYahrtzeits");
      setState(() {
        _yahrtzeits = fetchedYahrtzeits;
        // _upcomingDates = upcomingDates;
        // yahrtzeitDates = validYahrtzeits.map((y) => YahrtzeitDate.fromYahrtzeit(y)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching yahrtzeits: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List<YahrtzeitDate> _filterDuplicateYahrtzeits(List<Yahrtzeit> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeit in yahrtzeits) {
      if (yahrtzeit.englishName != null &&
          uniqueNames.add(yahrtzeit.englishName!)) {
        filteredList.add(YahrtzeitDate.fromYahrtzeit(yahrtzeit));
      }
    }

    return filteredList;
  }

  String _getHebrewDateString(JewishDate date) {
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;
    String fullDate = hebrewFormatter.format(date);
    List<String> dateParts = fullDate.split(' ');
    return '${dateParts[0]} ${dateParts[1]}';
  }

  String _getEnglishDateString(JewishDate date) {
    final englishFormatter = DateFormat('MMMM d');
    return '${date.getJewishDayOfMonth()} ${_getEnglishMonthName(date.getJewishMonth())}';
  }

  String _getEnglishMonthName(int month) {
    return hebrewMonths[month] ?? '';
  }

  Future<void> _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      await _deleteYahrtzeitFromFile(yahrtzeit);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddYahrtzeitPage(
            yearsToSync: widget.yearsToSync,
            yahrtzeit: yahrtzeit,
            isEditing: true,
            syncSettings: widget.syncSettings,
            notifications: widget.notifications,
            language: widget.language,
            jewishLanguage: widget.jewishLanguage,
            calendar: widget.calendar,
            years: widget.years,
            days: widget.days,
            months: widget.months,
            toggleSyncSettings: widget.toggleSyncSettings,
            toggleNotifications: widget.toggleNotifications,
            changeLanguage: widget.changeLanguage,
            changeJewishLanguage: widget.changeJewishLanguage,
            changeCalendar: widget.changeCalendar,
            changeYears: widget.changeYears,
            changeDays: widget.changeDays,
            changeMonths: widget.changeMonths,
          ),
        ),
      );

      if (result != null && result is Yahrtzeit) {
        await _addYahrtzeitToFile(result);
        setState(() {
          fetchYahrtzeits();
        });
      }
    } catch (e) {
      print('Error editing Yahrtzeit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('edit_failed')),
        ),
      );
    }
  }

  Future<void> _addYahrtzeitToFile(Yahrtzeit yahrtzeit) async {
    try {
      List<Yahrtzeit> yahrtzeits = await readData();
      yahrtzeits.add(yahrtzeit);
      List<Map<String, dynamic>> jsonData =
          yahrtzeits.map((y) => y.toJson()).toList();
      await writeData(jsonData);
    } catch (e) {
      print('Error adding yahrtzeit: $e');
    }
  }

  Future<void> _deleteYahrtzeitFromFile(Yahrtzeit yahrtzeit) async {
    try {
      List<Yahrtzeit> yahrtzeits = await readData();
      yahrtzeits.removeWhere((element) => element.id == yahrtzeit.id);
      List<Map<String, dynamic>> jsonData =
          yahrtzeits.map((y) => y.toJson()).toList();
      await writeData(jsonData);
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
    }
  }

  void _showDeleteConfirmationDialog(Yahrtzeit yahrtzeit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context)!.translate('confirm_delete')),
          content: Text(
              AppLocalizations.of(context)!.translate('are_you_sure_delete')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // סגור את הדיאלוג אם לא מאשרים
              },
              child: Text(AppLocalizations.of(context)!.translate('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // סגור את הדיאלוג אחרי אישור
                await _deleteYahrtzeitFromFile(yahrtzeit);
                setState(() {
                  fetchYahrtzeits();
                });
              },
              child: Text(AppLocalizations.of(context)!.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('manage_yahrtzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
        elevation: 0,
        actionsIconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddYahrtzeitPage(
                    yearsToSync: widget.yearsToSync,
                    isEditing: false,
                    syncSettings: widget.syncSettings,
                    notifications: widget.notifications,
                    language: widget.language,
                    jewishLanguage: widget.jewishLanguage,
                    calendar: widget.calendar,
                    years: widget.years,
                    days: widget.days,
                    months: widget.months,
                    toggleSyncSettings: widget.toggleSyncSettings,
                    toggleNotifications: widget.toggleNotifications,
                    changeLanguage: widget.changeLanguage,
                    changeJewishLanguage: widget.changeJewishLanguage,
                    changeCalendar: widget.changeCalendar,
                    changeYears: widget.changeYears,
                    changeDays: widget.changeDays,
                    changeMonths: widget.changeMonths,
                  ),
                ),
              );

              if (result != null && result is Yahrtzeit) {
                await _addYahrtzeitToFile(result);
                setState(() {
                  fetchYahrtzeits();
                });
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _yahrtzeits.length,
              itemBuilder: (context, index) {
                final yahrtzeit = _yahrtzeits[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // color: Colors.wh,
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          yahrtzeit.englishName ?? 'Unknown',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          yahrtzeit.hebrewName ?? 'Unknown',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (yahrtzeit.day != null && yahrtzeit.month != null)
                          Text(
                            '${yahrtzeit.day} ${hebrewMonths[yahrtzeit.month!]}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        if (yahrtzeit.day != null && yahrtzeit.month != null)
                          Text(
                            formatHebrewDate(yahrtzeit.month, yahrtzeit.day),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => _editYahrtzeit(yahrtzeit),
                    ),
                    onLongPress: () {
                      _showDeleteConfirmationDialog(yahrtzeit);
                    },
                  ),
                );
              },
            ),
    );
  }
}
