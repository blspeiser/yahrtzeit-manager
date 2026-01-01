import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localizations/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/yahrtzeits_manager.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('settings'),
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
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
                      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                      localeProvider.setLocale(newValue);
                      settings.setLanguage(newValue.languageCode);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(
                    AppLocalizations.of(context)!.translate('jewish_language')),
                trailing: DropdownButton<String>(
                  value: settings.jewishLanguage,
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
                      settings.setJewishLanguage(value);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Sync: ${settings.syncSettings ? 'on' : 'off'}'),
                trailing: Switch(
                  value: settings.syncSettings,
                  onChanged: (value) {
                    settings.setSyncSettings(value);
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
                  value: settings.years,
                  items: List.generate(10, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      settings.setYears(value);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text('Notifications: ${settings.notifications ? 'on' : 'off'}'),
                trailing: Switch(
                  value: settings.notifications,
                  onChanged: (value) async {
                    settings.setNotifications(value);
                    // Reschedule notifications when setting changes
                    final manager = YahrtzeitsManager();
                    await manager.rescheduleAllNotifications(value, settings.days);
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
                  value: settings.days,
                  items: List.generate(15, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      settings.setDays(value);
                      // Reschedule notifications with new days setting
                      if (settings.notifications) {
                        final manager = YahrtzeitsManager();
                        await manager.rescheduleAllNotifications(true, value);
                      }
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(
                    AppLocalizations.of(context)!.translate('calendar_settings')),
                trailing: DropdownButton<String>(
                  value: settings.calendar,
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
                      settings.setCalendar(value);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
