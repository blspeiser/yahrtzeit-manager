import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';
import '../widgets/yahrtzeit_tile.dart';
import 'add_yahrtzeit.dart';

class UpcomingYahrtzeits extends StatefulWidget {
  @override
  _UpcomingYahrtzeitsState createState() => _UpcomingYahrtzeitsState();
}

class _UpcomingYahrtzeitsState extends State<UpcomingYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<String> groups = [];
  bool isLoading = true;
  String searchQuery = '';

  // משתנים לאחסון ההגדרות
  late bool _syncSettings;
  late bool _notifications;
  late String _language;
  late String _jewishLanguage;
  late String _calendar;
  late int _years;
  late int _days;
  late int _months;

  @override
  void initState() {
    super.initState();
    _loadSettings().then((_) {
      fetchGroups();
    });
  }

  Future<List<YahrtzeitDate>> fetchYahrtzeits() async {
    try {
      final yahrtzeits = await manager.getAllYahrtzeits();
      print('All yahrtzeits fetched: ${yahrtzeits.length}');
      
      // Filter out yahrtzeits without day and month
      final validYahrtzeits = yahrtzeits.where((yahrtzeit) => yahrtzeit.day != null && yahrtzeit.month != null).toList();
      
      print('Valid yahrtzeits: ${validYahrtzeits.length}');
      for (var yahrtzeit in validYahrtzeits) {
        print('Yahrtzeit: ${yahrtzeit.englishName}, Day: ${yahrtzeit.day}, Month: ${yahrtzeit.month}');
      }

      final yahrtzeitDates = manager.nextMultiple(validYahrtzeits);
      final filteredYahrtzeitDates = manager.filterUpcomingByMonths(yahrtzeitDates, _months);
      
      return filteredYahrtzeitDates;
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
      return [];
    }
  }

  Future<void> fetchGroups() async {
    try {
      final fetchedGroups = await manager.getAllGroups();
      setState(() {
        groups = fetchedGroups;
      });
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncSettings = prefs.getBool('syncSettings') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'en';
      _jewishLanguage = prefs.getString('jewishLanguage') ?? 'he';
      _calendar = prefs.getString('calendar') ?? 'google';
      _years = prefs.getInt('years') ?? 1;
      _days = prefs.getInt('days') ?? 0;
      _months = prefs.getInt('months') ?? 6;
    });
  }

  void _filterYahrtzeits(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('upcoming_yahrtzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
        elevation: 0,
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<YahrtzeitDate>>(
        future: fetchYahrtzeits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.translate('no_upcoming_yahrtzeits_found'),
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            );
          } else {
            final filteredYahrtzeitDates = snapshot.data!.where((yahrtzeitDate) {
              final groupMatch = yahrtzeitDate.yahrtzeit.group != null &&
                  yahrtzeitDate.yahrtzeit.group!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
              return groupMatch;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return groups.where((String group) {
                        return group
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _filterYahrtzeits(selection);
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onChanged: _filterYahrtzeits,
                        decoration: InputDecoration(
                          labelText: 'חפש קבוצה',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredYahrtzeitDates.length,
                    itemBuilder: (context, index) {
                      final yahrtzeitDate = filteredYahrtzeitDates[index];
                      return YahrtzeitTile(yahrtzeitDate: yahrtzeitDate);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddYahrtzeitPage(
                yearsToSync: _years,
                syncSettings: _syncSettings,
                notifications: _notifications,
                language: _language,
                jewishLanguage: _jewishLanguage,
                calendar: _calendar,
                years: _years,
                days: _days,
                months: _months,
                toggleSyncSettings: () {
                  setState(() {
                    _syncSettings = !_syncSettings;
                  });
                },
                toggleNotifications: () {
                  setState(() {
                    _notifications = !_notifications;
                  });
                },
                changeLanguage: (String lang) {
                  setState(() {
                    _language = lang;
                  });
                },
                changeJewishLanguage: (String lang) {
                  setState(() {
                    _jewishLanguage = lang;
                  });
                },
                changeCalendar: (String cal) {
                  setState(() {
                    _calendar = cal;
                  });
                },
                changeYears: (int year) {
                  setState(() {
                    _years = year;
                  });
                },
                changeDays: (int day) {
                  setState(() {
                    _days = day;
                  });
                },
                changeMonths: (int months) {
                  setState(() {
                    _months = months;
                  });
                },
              ),
            ),
          ).then((result) {
            if (result == true) {
              setState(() {});
            }
          });
        },
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        shape: CircleBorder(),
      ),
    );
  }
}
