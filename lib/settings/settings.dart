import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localizations/app_localizations.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
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
            title: Text(AppLocalizations.of(context)!.translate('sync_settings')),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // עדכן את הגדרות הסנכרון
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('notifications')),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // עדכן את הגדרות ההתראות
              },
            ),
          ),
        ],
      ),
    );
  }
}
