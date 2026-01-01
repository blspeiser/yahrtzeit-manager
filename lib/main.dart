import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizations/app_localizations.dart';
import 'localizations/global_material_localizations.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/yahrtzeits_manager.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('languageCode') ?? 'en';
  
  // Initialize settings and schedule notifications
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  
  if (settingsProvider.notifications) {
    final manager = YahrtzeitsManager();
    await manager.loadYahrtzeitsFromPreferences();
    await manager.rescheduleAllNotifications(
      settingsProvider.notifications, 
      settingsProvider.days);
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()..loadLocale()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: YahrtzeitManagerApp(initialLocale: Locale(languageCode)),
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
              bodyLarge: TextStyle(color: const Color.fromARGB(221, 179, 108, 108)),
              bodyMedium: TextStyle(color: Colors.black54),
            ),
          ),
          home: HomePage(),
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
