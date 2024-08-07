import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final int months;
  final VoidCallback toggleSyncSettings;
  final VoidCallback toggleNotifications;
  final Function(String) changeLanguage;
  final Function(String) changeJewishLanguage;
  final Function(String) changeCalendar;
  final Function(int) changeYears;
  final Function(int) changeDays;
  final Function(int) changeMonths;

  SettingsPage({
    required this.syncSettings,
    required this.notifications,
    required this.language,
    required this.jewishLanguage,
    required this.calendar,
    required this.years,
    required this.days,
    required this.months,
    required this.toggleSyncSettings,
    required this.toggleNotifications,
    required this.changeLanguage,
    required this.changeJewishLanguage,
    required this.changeCalendar,
    required this.changeYears,
    required this.changeDays,
    required this.changeMonths,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _syncSettings;
  late bool _notifications;
  late String _language;
  late String _jewishLanguage;
  late String _calendar;
  late int _years;
  late int _days;
  late int _months;

  @override
  void initState() {
    super.initState();
    _syncSettings = widget.syncSettings;
    _notifications = widget.notifications;
    _language = widget.language;
    _jewishLanguage = widget.jewishLanguage;
    _calendar = widget.calendar;
    _years = widget.years;
    _days = widget.days;
    _months = widget.months;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncSettings = prefs.getBool('syncSettings') ?? widget.syncSettings;
      _notifications = prefs.getBool('notifications') ?? widget.notifications;
      _language = prefs.getString('language') ?? widget.language;
      _jewishLanguage =
          prefs.getString('jewishLanguage') ?? widget.jewishLanguage;
      _calendar = prefs.getString('calendar') ?? widget.calendar;
      _years = prefs.getInt('years') ?? widget.years;
      _days = prefs.getInt('days') ?? widget.days;
      _months = prefs.getInt('months') ?? widget.months;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncSettings', _syncSettings);
    await prefs.setBool('notifications', _notifications);
    await prefs.setString('language', _language);
    await prefs.setString('jewishLanguage', _jewishLanguage);
    await prefs.setString('calendar', _calendar);
    await prefs.setInt('years', _years);
    await prefs.setInt('days', _days);
    await prefs.setInt('months', _months);
  }

  void _toggleSyncSettings() {
    setState(() {
      _syncSettings = !_syncSettings;
    });
    _saveSettings();
    widget.toggleSyncSettings();
  }

  void _toggleNotifications() {
    setState(() {
      _notifications = !_notifications;
    });
    _saveSettings();
    widget.toggleNotifications();
  }

  void _changeLanguage(String lang) {
    setState(() {
      _language = lang;
    });
    _saveSettings();
    widget.changeLanguage(lang);
  }

  void _changeJewishLanguage(String lang) {
    setState(() {
      _jewishLanguage = lang;
    });
    _saveSettings();
    widget.changeJewishLanguage(lang);
  }

  void _changeCalendar(String cal) {
    setState(() {
      _calendar = cal;
    });
    _saveSettings();
    widget.changeCalendar(cal);
  }

  void _changeYears(int year) {
    setState(() {
      _years = year;
    });
    _saveSettings();
    widget.changeYears(year);
  }

  void _changeDays(int day) {
    setState(() {
      _days = day;
    });
    _saveSettings();
    widget.changeDays(day);
  }

  void _changeMonths(int month) {
    setState(() {
      _months = month;
    });
    _saveSettings();
    widget.changeMonths(month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('settings'),
            style: TextStyle(color: Colors.white)),
        // backgroundColor: Color.fromARGB(255, 50, 4, 129),
        backgroundColor: Colors.grey[600],
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
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(newValue);
                  _changeLanguage(newValue.languageCode);
                }
              },
            ),
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context)!.translate('jewish_language')),
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
                if (value != null) {
                  _changeJewishLanguage(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text('Sync: ${_syncSettings ? 'on' : 'off'}'),
            trailing: Switch(
              value: _syncSettings,
              onChanged: (value) {
                _toggleSyncSettings();
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
                if (value != null) {
                  _changeYears(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text('Notifications: ${_notifications ? 'on' : 'off'}'),
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                _toggleNotifications();
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
                if (value != null) {
                  _changeDays(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('months_filter')),
            trailing: DropdownButton<int>(
              value: _months,
              items: List.generate(12, (index) => index + 1).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _changeMonths(value);
                }
              },
            ),
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context)!.translate('calendar_settings')),
            trailing: DropdownButton<String>(
              value: _calendar,
              items: [
                DropdownMenuItem(
                  value: 'google',
                  child: Text(AppLocalizations.of(context)!
                      .translate('Google Calendar')),
                ),
                DropdownMenuItem(
                  value: 'device',
                  child: Text(AppLocalizations.of(context)!
                      .translate('Device Calendar')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _changeCalendar(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
