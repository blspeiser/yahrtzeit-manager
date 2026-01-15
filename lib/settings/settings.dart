import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localizations/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/yahrtzeits_manager.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, Widget trailing) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('settings'),
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 12),
              children: [
                // Language Settings Section
                _buildSectionHeader(context, 'Language'),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('language'),
                        DropdownButton<Locale>(
                          value: Localizations.localeOf(context),
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          iconEnabledColor: AppTheme.textPrimary,
                          style: TextStyle(color: AppTheme.textPrimary),
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
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('jewish_language'),
                        DropdownButton<String>(
                          value: settings.jewishLanguage,
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          iconEnabledColor: AppTheme.textPrimary,
                          style: TextStyle(color: AppTheme.textPrimary),
                          items: [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'he', child: Text('Hebrew')),
                            DropdownMenuItem(value: 'es', child: Text('Spanish')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              settings.setJewishLanguage(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Calendar & Sync Section
                _buildSectionHeader(context, 'Calendar & Sync'),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('sync_settings'),
                        Switch(
                          value: settings.syncSettings,
                          onChanged: (value) => settings.setSyncSettings(value),
                          activeColor: AppTheme.primaryColor,
                          activeTrackColor: AppTheme.primaryColorWithOpacity(0.5),
                        ),
                      ),
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('calendar_settings'),
                        DropdownButton<String>(
                          value: settings.calendar,
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          iconEnabledColor: AppTheme.textPrimary,
                          style: TextStyle(color: AppTheme.textPrimary),
                          items: [
                            DropdownMenuItem(
                              value: 'google',
                              child: Text(AppLocalizations.of(context)!.translate('google_calendar')),
                            ),
                            DropdownMenuItem(
                              value: 'device',
                              child: Text(AppLocalizations.of(context)!.translate('device_calendar')),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              settings.setCalendar(value);
                            }
                          },
                        ),
                      ),
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('years'),
                        DropdownButton<int>(
                          value: settings.years,
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          iconEnabledColor: AppTheme.textPrimary,
                          style: TextStyle(color: AppTheme.textPrimary),
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
                    ],
                  ),
                ),
                
                // Notifications Section
                _buildSectionHeader(context, 'Notifications'),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.cardBorderColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('notifications'),
                        Switch(
                          value: settings.notifications,
                          onChanged: (value) async {
                            settings.setNotifications(value);
                            final manager = YahrtzeitsManager();
                            await manager.rescheduleAllNotifications(value, settings.days);
                          },
                          activeColor: AppTheme.primaryColor,
                          activeTrackColor: AppTheme.primaryColorWithOpacity(0.5),
                        ),
                      ),
                      Divider(height: 1, indent: 20, endIndent: 20),
                      _buildSettingTile(
                        context,
                        AppLocalizations.of(context)!.translate('days_before'),
                        DropdownButton<int>(
                          value: settings.days,
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          iconEnabledColor: AppTheme.textPrimary,
                          style: TextStyle(color: AppTheme.textPrimary),
                          items: List.generate(15, (index) => index + 1).map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              settings.setDays(value);
                              if (settings.notifications) {
                                final manager = YahrtzeitsManager();
                                await manager.rescheduleAllNotifications(true, value);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
