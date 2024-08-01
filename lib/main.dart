import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings/settings.dart';
import 'views/upcoming_yahrtzeits.dart';
import 'views/manage_yahrtzeits.dart';

void main() {
  runApp(YahrtzeitManagerApp());
}

class YahrtzeitManagerApp extends StatefulWidget {

  YahrtzeitManagerApp();

  @override
  _YahrtzeitManagerAppState createState() => _YahrtzeitManagerAppState();
}

class _YahrtzeitManagerAppState extends State<YahrtzeitManagerApp> {

  bool syncSettings = true;
  bool notifications = true;
  String language = 'en';
  String jewishLanguage = 'he';
  String calendar = 'device';
  int years = 5;
  int days = 10;


  void toggleSyncSettings(){
    setState(() {
      syncSettings =!syncSettings;
    });
  }

  void toggleNotifications(){
    setState(() {
      notifications =!notifications;
    });
  }

  void changeLanguage(String lang){
    setState(() {
      language = lang;
    });
  }

  void changeJewishLanguage(String lang){
    setState(() {
      jewishLanguage = lang;
    });
  }

  void changeYears(int year){
    setState(() {
      years = year;
    });
  }

  void changeDays(int day){
    setState(() {
      days = day;
    });
  }

  void changeCalendar(String cal){
    setState(() {
      calendar = cal;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yahrtzeit Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: HomePage(
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
