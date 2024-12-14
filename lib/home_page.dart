import 'package:flutter/material.dart';
import 'services/event_checker.dart';
import 'settings/settings.dart';
import 'views/add_yahrtzeit.dart';
import 'views/manage_yahrtzeits.dart';
import 'views/upcoming_yahrtzeits.dart';
import '../localizations/app_localizations.dart';

class HomePage extends StatefulWidget {
  bool syncSettings;
  bool notifications;
  String language;
  String jewishLanguage;
  String calendar;
  int years;
  int days;
  int months;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;
  final Function(int) changeMonths;

  HomePage({
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
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final EventChecker eventChecker = EventChecker();

    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventChecker.checkForTodayEvents(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          // UpcomingYahrtzeits(months: widget.months,),
          UpcomingYahrtzeits(),
          ManageYahrtzeits(
            yearsToSync: widget.years,
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
          SettingsPage(
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppLocalizations.of(context)!.translate('upcoming'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: AppLocalizations.of(context)!.translate('manage'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.translate('settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}