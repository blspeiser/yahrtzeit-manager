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

  void changeMonths(int month) {
    setState(() {
      months = month;
    });
  }

// class YahrtzeitManagerApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Yahrtzeit Manager',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme(
              bodyLarge:
                  TextStyle(color: const Color.fromARGB(221, 179, 108, 108)),
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
