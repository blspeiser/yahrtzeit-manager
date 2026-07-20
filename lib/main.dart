import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizations/app_localizations.dart';
import 'localizations/global_material_localizations.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/yahrtzeits_manager.dart';
import 'services/file_handler_service.dart';
import 'theme/app_theme.dart';
import 'home_page.dart';
import 'views/import_yahrtzeits.dart';
import 'widgets/permission_rationale_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String languageCode = 'en';
  SettingsProvider settingsProvider = SettingsProvider();
  
  try {
    // Initialize notification service
    await NotificationService().initialize();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    languageCode = prefs.getString('languageCode') ?? 'en';
    
    // Initialize settings and schedule notifications
    await settingsProvider.loadSettings();
    
    if (settingsProvider.notifications) {
      try {
        final manager = YahrtzeitsManager();
        await manager.loadYahrtzeitsFromPreferences();
        await manager.rescheduleAllNotifications(
          settingsProvider.notifications, 
          settingsProvider.days);
      } catch (e) {
        // Continue app startup even if notifications fail
      }
    }
  } catch (e) {
    // Continue app startup with default settings
  }
  
  // Initialize locale provider
  final localeProvider = LocaleProvider();
  try {
    await localeProvider.loadLocale();
  } catch (e) {
    // Continue with default locale
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: YahrtzeitManagerApp(initialLocale: Locale(languageCode)),
    ),
  );
}


class YahrtzeitManagerApp extends StatefulWidget {
  
  final Locale initialLocale;

  const YahrtzeitManagerApp({super.key, required this.initialLocale});




  @override
  State<YahrtzeitManagerApp> createState() => _YahrtzeitManagerAppState();
}

class _YahrtzeitManagerAppState extends State<YahrtzeitManagerApp> {
  final FileHandlerService _fileHandlerService = FileHandlerService();
  String? _initialFile;

  @override
  void initState() {
    super.initState();
    _checkForInitialFile();
  }

  Future<void> _checkForInitialFile() async {
    final filePath = await _fileHandlerService.getInitialFile();
    if (filePath != null && mounted) {
      setState(() {
        _initialFile = filePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'Yahrtzeit Manager',
          theme: ThemeData(
            primarySwatch: Colors.grey,
            primaryColor: AppTheme.primaryColor,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              secondary: AppTheme.selectedColor,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: const Color.fromARGB(221, 179, 108, 108)),
              bodyMedium: TextStyle(color: Colors.black54),
            ),
          ),
          home: _initialFile != null
              ? ImportYahrtzeitsPage(filePath: _initialFile!)
              : HomePage(),
          locale: localeProvider.locale,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('he', 'IL'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            HebrewMaterialLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
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
