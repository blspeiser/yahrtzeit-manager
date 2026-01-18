import 'package:flutter/material.dart';
import 'settings/settings.dart';
import 'views/about.dart';
import 'views/manage_yahrtzeits.dart';
import 'views/upcoming_yahrtzeits.dart';
import '../localizations/app_localizations.dart';
import '../theme/app_theme.dart';

class HomePage extends StatefulWidget {
  final int? initialTab;

  const HomePage({Key? key, this.initialTab}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  final GlobalKey<UpcomingYahrtzeitsState> _upcomingKey = GlobalKey<UpcomingYahrtzeitsState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab ?? 0;
  }

  void _refreshUpcomingYahrtzeits() {
    if (_upcomingKey.currentState != null) {
      _upcomingKey.currentState!.fetchYahrtzeits();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Refresh Upcoming tab when switching to it
    if (index == 0) {
      _refreshUpcomingYahrtzeits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          UpcomingYahrtzeits(key: _upcomingKey, onDataChanged: _refreshUpcomingYahrtzeits),
          ManageYahrtzeits(onDataChanged: _refreshUpcomingYahrtzeits),
          SettingsPage(),
          AboutPage(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: AppLocalizations.of(context)!.translate('about'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.selectedColor,
        unselectedItemColor: AppTheme.unselectedColor,
        selectedIconTheme: IconThemeData(color: AppTheme.selectedColor, size: 26),
        unselectedIconTheme: IconThemeData(color: AppTheme.unselectedColor, size: 24),
        selectedFontSize: 13,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
        onTap: _onTabTapped,
      ),
    );
  }
}