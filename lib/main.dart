import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizations/app_localizations.dart';
import 'localizations/global_material_localizations.dart';
import 'services/notification_service.dart';
import 'settings/settings.dart';
import 'views/upcoming_yahrtzeits.dart';
import 'views/manage_yahrtzeits.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('languageCode') ?? 'en';
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider()..loadLocale(),
      child: NotificationProvider(
        child: YahrtzeitManagerApp(initialLocale: Locale(languageCode)),
        numOfdays:
            10, // Pass the number of days for notifications (example value)
      ),
    ),
  );
}

class YahrtzeitManagerApp extends StatefulWidget {
  final Locale initialLocale;

  YahrtzeitManagerApp({required this.initialLocale});

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
  int months = 6;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // קריאה לטעינת ההגדרות
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      syncSettings = prefs.getBool('syncSettings') ?? syncSettings;
      notifications = prefs.getBool('notifications') ?? notifications;
      language = prefs.getString('language') ?? language;
      jewishLanguage = prefs.getString('jewishLanguage') ?? jewishLanguage;
      calendar = prefs.getString('calendar') ?? calendar;
      years = prefs.getInt('years') ?? years;
      days = prefs.getInt('days') ?? days;
      months = prefs.getInt('months') ?? months;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncSettings', syncSettings);
    await prefs.setBool('notifications', notifications);
    await prefs.setString('language', language);
    await prefs.setString('jewishLanguage', jewishLanguage);
    await prefs.setString('calendar', calendar);
    await prefs.setInt('years', years);
    await prefs.setInt('days', days);
    await prefs.setInt('months', months);
  }

  void toggleSyncSettings() {
    setState(() {
      syncSettings = !syncSettings;
    });
    _saveSettings();
  }

  void toggleNotifications() {
    setState(() {
      notifications = !notifications;
    });
    _saveSettings();
  }

  void changeLanguage(String lang) {
    setState(() {
      language = lang;
    });
    _saveSettings();
  }

  void changeJewishLanguage(String lang) {
    setState(() {
      jewishLanguage = lang;
    });
    _saveSettings();
  }

  void changeYears(int year) {
    setState(() {
      years = year;
    });
    _saveSettings();
  }

  void changeDays(int day) {
    setState(() {
      days = day;
    });
    _saveSettings();
  }

  void changeCalendar(String cal) {
    setState(() {
      calendar = cal;
    });
    _saveSettings();
  }

  void changeMonths(int month) {
    setState(() {
      months = month;
    });
    _saveSettings();
  }

// class YahrtzeitManagerApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Yahrtzeit Manager',
          theme: ThemeData(
            primarySwatch: Colors.grey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme(
              bodyLarge:
                  TextStyle(color: Colors.black),
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
            months: months,
            calendar: calendar,
            toggleSyncSettings: toggleSyncSettings,
            toggleNotifications: toggleNotifications,
            changeLanguage: changeLanguage,
            changeJewishLanguage: changeJewishLanguage,
            changeCalendar: changeCalendar,
            changeYears: changeYears,
            changeDays: changeDays,
            changeMonths: changeMonths,
          ),
          locale: localeProvider.locale,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('he', 'IL'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            HebrewMaterialLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: localeProvider.locale.languageCode == 'he'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
