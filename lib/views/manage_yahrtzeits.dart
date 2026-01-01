import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../providers/settings_provider.dart';
import '../services/yahrtzeits_manager.dart';
import 'add_yahrtzeit.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManageYahrtzeits extends StatefulWidget {
  const ManageYahrtzeits({Key? key}) : super(key: key);

  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  List<YahrtzeitDate> yahrtzeitDates = [];
  bool isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  static const Map<int, String> hebrewMonths = {
    JewishDate.NISSAN: 'Nissan',
    JewishDate.IYAR: 'Iyar',
    JewishDate.SIVAN: 'Sivan',
    JewishDate.TAMMUZ: 'Tammuz',
    JewishDate.AV: 'Av',
    JewishDate.ELUL: 'Elul',
    JewishDate.TISHREI: 'Tishrei',
    JewishDate.CHESHVAN: 'Cheshvan',
    JewishDate.KISLEV: 'Kislev',
    JewishDate.TEVES: 'Teves',
    JewishDate.SHEVAT: 'Shevat',
    JewishDate.ADAR: 'Adar',
    JewishDate.ADAR_II: 'Adar II',
  };

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> writeData(List<Map<String, dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('yahrtzeit_data', json.encode(data));
  }

  Future<List<Yahrtzeit>> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yahrtzeit_data');
    if (jsonString != null) {
      List<Map<String, dynamic>> jsonData =
          List<Map<String, dynamic>>.from(json.decode(jsonString));
      return jsonData.map((data) => Yahrtzeit.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final fetchedYahrtzeits = await readData();

      setState(() {
        yahrtzeitDates = _filterDuplicateYahrtzeits(fetchedYahrtzeits);
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listKey.currentState != null) {
          for (var i = 0; i < yahrtzeitDates.length; i++) {
            _listKey.currentState?.insertItem(i);
          }
        }
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
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
    return '${date.getJewishDayOfMonth()} ${_getEnglishMonthName(date.getJewishMonth())}';
  }

  String _getEnglishMonthName(int month) {
    return hebrewMonths[month] ?? '';
  }

  Future<void> _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddYahrtzeitPage(
            yahrtzeit: yahrtzeit,
            isEditing: true,
          ),
        ),
      );

      if (result == true) {
        // Reload data and refresh UI
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

  Future<void> _deleteYahrtzeitFromFile(Yahrtzeit yahrtzeit) async {
    try {
      List<Yahrtzeit> yahrtzeits = await readData();

      print('Current IDs in file: ${yahrtzeits.map((item) => item.id).toList()}');
      print('Attempting to delete Yahrtzeit with ID: ${yahrtzeit.id}');

      yahrtzeits.removeWhere((element) {
        bool match = element.id == yahrtzeit.id;
        if (match) {
          print('Removing Yahrtzeit with ID: ${element.id}');
        }
        return match;
      });

      List<Map<String, dynamic>> jsonData =
          yahrtzeits.map((yahrtzeit) => yahrtzeit.toJson()).toList();
      print('Data to be written: ${json.encode(jsonData)}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('yahrtzeit_data', json.encode(jsonData));

      print('Yahrtzeit deleted successfully');
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
    }
  }

  void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      final index =
          yahrtzeitDates.indexWhere((date) => date.yahrtzeit == yahrtzeit);
      if (index >= 0 && index < yahrtzeitDates.length) {
        setState(() {
          yahrtzeitDates.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: Offset(0, 0),
                    end: Offset(1, 0),
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: _buildYahrtzeitTile(yahrtzeitDates[index]),
              );
            },
            duration: Duration(milliseconds: 300),
          );
        });
        await _deleteYahrtzeitFromFile(yahrtzeit);
      }
    } catch (e) {
      print('Error while deleting yahrtzeit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate('deletion_failed')),
        ),
      );
    }
  }

  void _showStoredData() async {
    List<Yahrtzeit> data = await readData();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stored Yahrtzeits'),
          content: SingleChildScrollView(
            child: ListBody(
              children: data.map((yahrtzeit) {
                return ListTile(
                  title: Text(yahrtzeit.englishName ?? ''),
                  subtitle: Text(yahrtzeit.hebrewName),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final manager = YahrtzeitsManager();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('manage_yahrzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
        actions: [
          if (settingsProvider.syncSettings)
            IconButton(
              icon: Icon(Icons.sync, color: Colors.white),
              onPressed: () async {
                final result = await manager.syncWithCalendar();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  fetchYahrtzeits();
                }
              },
              tooltip: 'Sync with calendar',
            ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddYahrtzeitPage(),
                ),
              ).then((result) {
                if (result == true) {
                  fetchYahrtzeits();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.info, color: Colors.white),
            onPressed: _showStoredData,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              )
            : yahrtzeitDates.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('you_have_not_added_any_yahrtzeits_yet.'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: yahrtzeitDates.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= yahrtzeitDates.length) {
                        return SizedBox.shrink();
                      }
                      return FadeTransition(
                        opacity: animation,
                        child: _buildYahrtzeitTile(yahrtzeitDates[index]),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildYahrtzeitTile(YahrtzeitDate yahrtzeitDate) {
    String hebrewDate = _getHebrewDateString(yahrtzeitDate.hebrewDate);
    String englishDate = _getEnglishDateString(yahrtzeitDate.hebrewDate);

    return Dismissible(
      key: Key(yahrtzeitDate.yahrtzeit.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteYahrtzeit(yahrtzeitDate.yahrtzeit);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 20),
          ],
        ),
      ),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    englishDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    yahrtzeitDate.yahrtzeit.hebrewName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    hebrewDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteYahrtzeit(yahrtzeitDate.yahrtzeit),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.deepPurple),
                onPressed: () => _editYahrtzeit(yahrtzeitDate.yahrtzeit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
