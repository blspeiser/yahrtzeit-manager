import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizations/app_localizations.dart';
import 'localizations/global_material_localizations.dart';
import 'settings/settings.dart';
import 'views/upcoming_yahrtzeits.dart';
import 'views/manage_yahrtzeits.dart';
import 'views/groups_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('languageCode') ?? 'en';
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider()..loadLocale(),
      child: YahrtzeitManagerApp(initialLocale: Locale(languageCode)),
    ),
  );
}

class YahrtzeitManagerApp extends StatelessWidget {
  final Locale initialLocale;

  YahrtzeitManagerApp({required this.initialLocale});

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
              bodyLarge: TextStyle(color: Colors.black87),
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    UpcomingYahrtzeits(),
    ManageYahrtzeits(),
    GroupsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
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
            icon: Icon(Icons.group),
            label: AppLocalizations.of(context)!.translate('groups'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.translate('settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
