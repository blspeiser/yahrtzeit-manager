import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Language'),
            trailing: DropdownButton<String>(
              value: 'en',
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'he',
                  child: Text('Hebrew'),
                ),
              ],
              onChanged: (value) {
                // עדכן את שפת הממשק
              },
            ),
          ),
          ListTile(
            title: Text('Sync Settings'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // עדכן את הגדרות הסנכרון
              },
            ),
          ),
          ListTile(
            title: Text('Notifications'),
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
