
import 'package:flutter/material.dart';
import 'settings/settings.dart';
import 'views/groups_page.dart';
import 'views/manage_yahrtzeits.dart';
import 'views/upcoming_yahrtzeits.dart';

class HomePage extends StatefulWidget {
  bool syncSettings;
  bool notifications;
  String language;
  String jewishLanguage;
  String calendar;
  int years;
  int days;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;

  HomePage({
    required this.syncSettings,
    required this.notifications,
    required this.language,
    required this.jewishLanguage,
    required this.calendar,
    required this.years,
    required this.days,
    required this.toggleSyncSettings,
    required this.toggleNotifications,
    required this.changeLanguage,
    required this.changeJewishLanguage,
    required this.changeCalendar,
    required this.changeYears,
    required this.changeDays,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          UpcomingYahrtzeits(),
          ManageYahrtzeits(),
          GroupsPage(),
          SettingsPage(
            syncSettings: widget.syncSettings,
            notifications: widget.notifications,
            language: widget.language,
            jewishLanguage: widget.jewishLanguage,
            calendar: widget.calendar,
            years: widget.years,
            days: widget.days,
            toggleSyncSettings: widget.toggleSyncSettings,
            toggleNotifications: widget.toggleNotifications,
            changeLanguage: widget.changeLanguage,
            changeJewishLanguage: widget.changeJewishLanguage,
            changeCalendar: widget.changeCalendar,
            changeYears: widget.changeYears,
            changeDays: widget.changeDays,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
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
