
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../localizations/app_localizations.dart';
// // import '../main.dart';

// // class SettingsPage extends StatefulWidget {
// //   final bool syncSettings;
// //   final bool notifications;
// //   final String language;
// //   final String jewishLanguage;
// //   final String calendar;
// //   final int years;
// //   final int days;
// //   final VoidCallback toggleSyncSettings;
// //   final VoidCallback toggleNotifications;
// //   final Function(String) changeLanguage;
// //   final Function(String) changeJewishLanguage;
// //   final Function(String) changeCalendar;
// //   final Function(int) changeYears;
// //   final Function(int) changeDays;

// //   SettingsPage({
// //     required this.syncSettings,
// //     required this.notifications,
// //     required this.language,
// //     required this.jewishLanguage,
// //     required this.calendar,
// //     required this.years,
// //     required this.days,
// //     required this.toggleSyncSettings,
// //     required this.toggleNotifications,
// //     required this.changeLanguage,
// //     required this.changeJewishLanguage,
// //     required this.changeCalendar,
// //     required this.changeYears,
// //     required this.changeDays,
// //   });

// //   @override
// //   _SettingsPageState createState() => _SettingsPageState();
// // }

// // class _SettingsPageState extends State<SettingsPage> {
// //   String? _language;
// //   String? _jewishLanguage;
// //   String? _calendar;
// //   int? _years;
// //   int? _days;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Initialize the local state with the values passed in
// //     _language = widget.language;
// //     _jewishLanguage = widget.jewishLanguage;
// //     _calendar = widget.calendar;
// //     _years = widget.years;
// //     _days = widget.days;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(AppLocalizations.of(context)!.translate('settings'), style: TextStyle(color: Colors.white)),
// //         backgroundColor: Color.fromARGB(255, 50, 4, 129),
// //         centerTitle: true,
// //       ),
// //       body: ListView(
// //         children: [
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('language')),
// //             trailing: DropdownButton<Locale>(
// //               value: Localizations.localeOf(context),
// //               items: [
// //                 DropdownMenuItem(
// //                   value: Locale('en', 'US'),
// //                   child: Text('English'),
// //                 ),
// //                 DropdownMenuItem(
// //                   value: Locale('he', 'IL'),
// //                   child: Text('עברית'),
// //                 ),
// //               ],
// //               onChanged: (Locale? newValue) {
// //                 if (newValue != null) {
// //                   Provider.of<LocaleProvider>(context, listen: false).setLocale(newValue);
// //                 }
// //               },
// //             ),
// //           ),
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('jewish_language')),
// //             trailing: DropdownButton<String>(
// //               value: _jewishLanguage,
// //               items: [
// //                 DropdownMenuItem(
// //                   value: 'en',
// //                   child: Text('English'),
// //                 ),
// //                 DropdownMenuItem(
// //                   value: 'he',
// //                   child: Text('Hebrew'),
// //                 ),
// //                 DropdownMenuItem(
// //                   value: 'es',
// //                   child: Text('Spanish'),
// //                 ),
// //               ],
// //               onChanged: (value) {
// //                 setState(() {
// //                   _jewishLanguage = value;
// //                 });
// //                 if (value != null) {
// //                   widget.changeJewishLanguage(value);
// //                 }
// //               },
// //             ),
// //           ),
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('sync_settings')),
// //             trailing: Switch(
// //               value: widget.syncSettings,
// //               onChanged: (value) {
// //                 widget.toggleSyncSettings();
// //               },
// //               activeColor: Colors.white,
// //               activeTrackColor: Colors.grey[600],
// //               inactiveThumbColor: Colors.grey[600],
// //               inactiveTrackColor: Colors.grey[300],
// //             ),
// //           ),
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('years')),
// //             trailing: DropdownButton<int>(
// //               value: _years,
// //               items: List.generate(10, (index) => index + 1).map((int value) {
// //                 return DropdownMenuItem<int>(
// //                   value: value,
// //                   child: Text(value.toString()),
// //                 );
// //               }).toList(),
// //               onChanged: (value) {
// //                 setState(() {
// //                   _years = value;
// //                 });
// //                 if (value != null) {
// //                   widget.changeYears(value);
// //                 }
// //               },
// //             ),
// //           ),
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('notifications')),
// //             trailing: Switch(
// //               value: widget.notifications,
// //               onChanged: (value) {
// //                 widget.toggleNotifications();
// //               },
// //               activeColor: Colors.white,
// //               activeTrackColor: Colors.grey[600],
// //               inactiveThumbColor: Colors.grey[600],
// //               inactiveTrackColor: Colors.grey[300],
// //             ),
// //           ),
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('days_before')),
// //             trailing: DropdownButton<int>(
// //               value: _days,
// //               items: List.generate(15, (index) => index + 1).map((int value) {
// //                 return DropdownMenuItem<int>(
// //                   value: value,
// //                   child: Text(value.toString()),
// //                 );
// //               }).toList(),
// //               onChanged: (value) {
// //                 setState(() {
// //                   _days = value;
// //                 });
// //                 if (value != null) {
// //                   widget.changeDays(value);
// //                 }
// //               },
// //             ),
// //           ),
// //           ListTile(
// //             title: Text(AppLocalizations.of(context)!.translate('calendar_settings')),
// //             trailing: DropdownButton<String>(
// //               value: _calendar,
// //               items: [
// //                 DropdownMenuItem(
// //                   value: 'google',
// //                   child: Text(AppLocalizations.of(context)!.translate('Google Calendar')),
// //                 ),
// //                 DropdownMenuItem(
// //                   value: 'device',
// //                   child: Text(AppLocalizations.of(context)!.translate('Device Calendar')),
// //                 ),
// //               ],
// //               onChanged: (value) {
// //                 setState(() {
// //                   _calendar = value;
// //                 });
// //                 if (value != null) {
// //                   widget.changeCalendar(value);
// //                 }
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../localizations/app_localizations.dart';
// import '../main.dart';  // הנח שהנתיב הזה מתאים עבורך

// class SettingsPage extends StatefulWidget {
//   final bool syncSettings;
//   final bool notifications;
//   final String language;
//   final String jewishLanguage;
//   final String calendar;
//   final int years;
//   final int days;
//   final VoidCallback toggleSyncSettings;
//   final VoidCallback toggleNotifications;
//   final Function(String) changeLanguage;
//   final Function(String) changeJewishLanguage;
//   final Function(String) changeCalendar;
//   final Function(int) changeYears;
//   final Function(int) changeDays;

//   SettingsPage({
//     required this.syncSettings,
//     required this.notifications,
//     required this.language,
//     required this.jewishLanguage,
//     required this.calendar,
//     required this.years,
//     required this.days,
//     required this.toggleSyncSettings,
//     required this.toggleNotifications,
//     required this.changeLanguage,
//     required this.changeJewishLanguage,
//     required this.changeCalendar,
//     required this.changeYears,
//     required this.changeDays,
//   });

//   @override
//   _SettingsPageState createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   String? _language;
//   String? _jewishLanguage;
//   String? _calendar;
//   int? _years;
//   int? _days;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the local state with the values passed in
//     _language = widget.language;
//     _jewishLanguage = widget.jewishLanguage;
//     _calendar = widget.calendar;
//     _years = widget.years;
//     _days = widget.days;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appLocalizations = AppLocalizations.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(appLocalizations?.translate('settings') ?? 'Settings'),
//         backgroundColor: Color.fromARGB(255, 50, 4, 129),
//         centerTitle: true,
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             title: Text(appLocalizations?.translate('language') ?? 'Language'),
//             trailing: DropdownButton<Locale>(
//               value: Localizations.localeOf(context),
//               items: [
//                 DropdownMenuItem(
//                   value: Locale('en', 'US'),
//                   child: Text('English'),
//                 ),
//                 DropdownMenuItem(
//                   value: Locale('he', 'IL'),
//                   child: Text('עברית'),
//                 ),
//               ],
//               onChanged: (Locale? newValue) {
//                 if (newValue != null) {
//                   Provider.of<LocaleProvider>(context, listen: false).setLocale(newValue);
//                 }
//               },
//             ),
//           ),
//           ListTile(
//             title: Text(AppLocalizations.translate('jewish_language') ?? 'Jewish Language'),
//             trailing: DropdownButton<String>(
//               value: _jewishLanguage,
//               items: [
//                 DropdownMenuItem(
//                   value: 'en',
//                   child: Text('English'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'he',
//                   child: Text('Hebrew'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'es',
//                   child: Text('Spanish'),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _jewishLanguage = value;
//                 });
//                 if (value != null) {
//                   widget.changeJewishLanguage(value);
//                 }
//               },
//             ),
//           ),
//           ListTile(
//             title: Text(appLocalizations?.translate('sync_settings') ?? 'Sync Settings'),
//             trailing: Switch(
//               value: widget.syncSettings,
//               onChanged: (value) {
//                 widget.toggleSyncSettings();
//               },
//               activeColor: Colors.white,
//               activeTrackColor: Colors.grey[600],
//               inactiveThumbColor: Colors.grey[600],
//               inactiveTrackColor: Colors.grey[300],
//             ),
//           ),
//           ListTile(
//             title: Text(appLocalizations?.translate('years') ?? 'Years'),
//             trailing: DropdownButton<int>(
//               value: _years,
//               items: List.generate(10, (index) => index + 1).map((int value) {
//                 return DropdownMenuItem<int>(
//                   value: value,
//                   child: Text(value.toString()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _years = value;
//                 });
//                 if (value != null) {
//                   widget.changeYears(value);
//                 }
//               },
//             ),
//           ),
//           ListTile(
//             title: Text(appLocalizations?.translate('notifications') ?? 'Notifications'),
//             trailing: Switch(
//               value: widget.notifications,
//               onChanged: (value) {
//                 widget.toggleNotifications();
//               },
//               activeColor: Colors.white,
//               activeTrackColor: Colors.grey[600],
//               inactiveThumbColor: Colors.grey[600],
//               inactiveTrackColor: Colors.grey[300],
//             ),
//           ),
//           ListTile(
//             title: Text(appLocalizations?.translate('days_before') ?? 'Days Before'),
//             trailing: DropdownButton<int>(
//               value: _days,
//               items: List.generate(15, (index) => index + 1).map((int value) {
//                 return DropdownMenuItem<int>(
//                   value: value,
//                   child: Text(value.toString()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _days = value;
//                 });
//                 if (value != null) {
//                   widget.changeDays(value);
//                 }
//               },
//             ),
//           ),
//           ListTile(
//             title: Text(appLocalizations?.translate('calendar_settings') ?? 'Calendar Settings'),
//             trailing: DropdownButton<String>(
//               value: _calendar,
//               items: [
//                 DropdownMenuItem(
//                   value: 'google',
//                   child: Text(appLocalizations?.translate('Google Calendar') ?? 'Google Calendar'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'device',
//                   child: Text(appLocalizations?.translate('Device Calendar') ?? 'Device Calendar'),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _calendar = value;
//                 });
//                 if (value != null) {
//                   widget.changeCalendar(value);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localizations/app_localizations.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  final bool syncSettings;
  final bool notifications;
  final String language;
  final String jewishLanguage;
  final String calendar;
  final int years;
  final int days;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;

  SettingsPage({
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
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _language;
  String? _jewishLanguage;
  String? _calendar;
  int? _years;
  int? _days;

  @override
  void initState() {
    super.initState();
    // Initialize the local state with the values passed in
    _language = widget.language;
    _jewishLanguage = widget.jewishLanguage;
    _calendar = widget.calendar;
    _years = widget.years;
    _days = widget.days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('settings'), style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('language')),
            trailing: DropdownButton<Locale>(
              value: Localizations.localeOf(context),
              items: [
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('he', 'IL'),
                  child: Text('עברית'),
                ),
              ],
              onChanged: (Locale? newValue) {
                if (newValue != null) {
                  Provider.of<LocaleProvider>(context, listen: false).setLocale(newValue);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('jewish_language')),
            trailing: DropdownButton<String>(
              value: _jewishLanguage,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'he',
                  child: Text('Hebrew'),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text('Spanish'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _jewishLanguage = value;
                });
                if (value != null) {
                  widget.changeJewishLanguage(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('sync_settings')),
            trailing: Switch(
              value: widget.syncSettings,
              onChanged: (value) {
                widget.toggleSyncSettings();
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.grey[600],
              inactiveThumbColor: Colors.grey[600],
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('years')),
            trailing: DropdownButton<int>(
              value: _years,
              items: List.generate(10, (index) => index + 1).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _years = value;
                });
                if (value != null) {
                  widget.changeYears(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('notifications')),
            trailing: Switch(
              value: widget.notifications,
              onChanged: (value) {
                widget.toggleNotifications();
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.grey[600],
              inactiveThumbColor: Colors.grey[600],
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('days_before')),
            trailing: DropdownButton<int>(
              value: _days,
              items: List.generate(15, (index) => index + 1).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _days = value;
                });
                if (value != null) {
                  widget.changeDays(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('calendar_settings')),
            trailing: DropdownButton<String>(
              value: _calendar,
              items: [
                DropdownMenuItem(
                  value: 'google',
                  child: Text(AppLocalizations.of(context)!.translate('Google Calendar')),
                ),
                DropdownMenuItem(
                  value: 'device',
                  child: Text(AppLocalizations.of(context)!.translate('Device Calendar')),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _calendar = value;
                });
                if (value != null) {
                  widget.changeCalendar(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}