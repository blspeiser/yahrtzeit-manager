import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'home_page.dart';
import 'services/event_checker.dart';
import './global.dart' as globals;

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized

  tz.initializeTimeZones(); // Initialize timezone data if required

  runApp(MaterialApp(
    title: 'Yahrtzeit Manager',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
    ),
    home: YahrtzeitManagerApp(), // Use the main app widget here
    debugShowCheckedModeBanner: false,
  ));
}

class YahrtzeitManagerApp extends StatefulWidget {
  @override
  _YahrtzeitManagerAppState createState() => _YahrtzeitManagerAppState();
}

class _YahrtzeitManagerAppState extends State<YahrtzeitManagerApp> {
  final EventChecker eventChecker = EventChecker();

  bool syncSettings = true;
  bool notifications = true;
  String language = 'en';
  String jewishLanguage = 'he';
  String calendar = 'device';
  int years = 5;
  int days = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventChecker.checkForTodayEvents(context);
    });
  }

  void toggleSyncSettings() {
    setState(() {
      syncSettings = !syncSettings;
    });
  }

  void toggleNotifications() {
    setState(() {
      notifications = !notifications;
    });
  }

  void changeLanguage(String lang) {
    setState(() {
      language = lang;
    });
  }

  void changeJewishLanguage(String lang) {
    setState(() {
      jewishLanguage = lang;
    });
  }

  void changeYears(int year) {
    setState(() {
      years = year;
    });
  }

  void changeDays(int day) {
    setState(() {
      days = day;
    });
  }

  void changeCalendar(String cal) {
    setState(() {
      calendar = cal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      syncSettings: syncSettings,
      notifications: notifications,
      language: language,
      jewishLanguage: jewishLanguage,
      years: years,
      days: days,
      calendar: calendar,
      toggleSyncSettings: toggleSyncSettings,
      toggleNotifications: toggleNotifications,
      changeLanguage: changeLanguage,
      changeJewishLanguage: changeJewishLanguage,
      changeCalendar: changeCalendar,
      changeYears: changeYears,
      changeDays: changeDays,
    );
  }
}
