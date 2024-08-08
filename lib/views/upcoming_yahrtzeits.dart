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

      // יצירת רשימה ייחודית בלי כפילויות של אותיות גדולות וקטנות
      final uniqueGroups = fetchedGroups
          .fold<Map<String, String>>({}, (map, group) {
            final lowerCaseGroup = group.toLowerCase();
            if (!map.containsKey(lowerCaseGroup)) {
              map[lowerCaseGroup] = group;
            }
            return map;
          })
          .values
          .toList();

      setState(() {
        groups = uniqueGroups;
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


  List<YahrtzeitDate> _filterDuplicateYahrtzeits(
      List<YahrtzeitDate> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeitDate in yahrtzeits) {
      if (uniqueNames.add(yahrtzeitDate.yahrtzeit.englishName!)) {
        filteredList.add(yahrtzeitDate);
      }
    }

    return filteredList;
  }

  void _filterYahrtzeits(String? query) {
    setState(() {
      if (query == null) {
        // במקרה של "ללא קבוצה" - סינון לפי קבוצה ריקה או null
        filteredYahrtzeitDates = yahrtzeitDates.where((yahrtzeitDate) {
          return yahrtzeitDate.yahrtzeit.group == null ||
              yahrtzeitDate.yahrtzeit.group!.isEmpty;
        }).toList();
      } else if (query.isEmpty) {
        // במקרה של "ללא סינון"
        filteredYahrtzeitDates = yahrtzeitDates;
      } else {
        // סינון לפי קבוצה נבחרת
        filteredYahrtzeitDates = yahrtzeitDates.where((yahrtzeitDate) {
          return yahrtzeitDate.yahrtzeit.group != null &&
              yahrtzeitDate.yahrtzeit.group!
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }

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
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Dropdown של כל הקבוצות
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('בחר קבוצה'),
                            value: searchQuery.isEmpty ? null : searchQuery,
                            onChanged: (String? newValue) {
                              setState(() {
                                searchQuery = newValue ?? '';
                                if (searchQuery.isEmpty) {
                                  fetchYahrtzeits(); // מבצע fetch מחדש
                                } else if (searchQuery == 'ללא קבוצה') {
                                  _filterYahrtzeits(
                                      null); // מסנן לפי חוסר קבוצה
                                } else {
                                  _filterYahrtzeits(
                                      searchQuery); // מסנן לפי קבוצה נבחרת
                                }
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text('ללא סינון'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'ללא קבוצה',
                                child: Text('ללא קבוצה'),
                              ),
                              ...groups.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        // כפתור לבחירת מספר חודשים
                        DropdownButton<int>(
                          hint: Text('בחר חודשים'),
                          value: _months,
                          onChanged: (int? newValue) {
                            setState(() {
                              _months = newValue!;
                              filteredYahrtzeitDates =
                                  manager.filterUpcomingByMonths(
                                      yahrtzeitDates, _months);
                            });
                          },
                          items: List.generate(12, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('חודשים $value'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

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
