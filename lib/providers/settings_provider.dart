import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _syncSettings = true;
  bool _notifications = true;
  String _language = 'en';
  String _jewishLanguage = 'he';
  String _calendar = 'device';
  int _years = 5;
  int _days = 10;

  // Getters
  bool get syncSettings => _syncSettings;
  bool get notifications => _notifications;
  String get language => _language;
  String get jewishLanguage => _jewishLanguage;
  String get calendar => _calendar;
  int get years => _years;
  int get days => _days;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setSyncSettings(prefs.getBool('syncSettings') ?? true, notify: false);
    setNotifications(prefs.getBool('notifications') ?? true, notify: false);
    setLanguage(prefs.getString('language') ?? 'en', notify: false);
    setJewishLanguage(prefs.getString('jewishLanguage') ?? 'he', notify: false);
    setCalendar(prefs.getString('calendar') ?? 'device', notify: false);
    setYears(prefs.getInt('years') ?? 5, notify: false);
    setDays(prefs.getInt('days') ?? 10, notify: false);
    notifyListeners();
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
  }

  Future<void> setSyncSettings(bool value, {bool notify = true}) async {
    _syncSettings = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }

  Future<void> setNotifications(bool value, {bool notify = true}) async {
    _notifications = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }

  Future<void> setLanguage(String value, {bool notify = true}) async {
    _language = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }

  Future<void> setJewishLanguage(String value, {bool notify = true}) async {
    _jewishLanguage = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }

  Future<void> setCalendar(String value, {bool notify = true}) async {
    _calendar = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }

  Future<void> setYears(int value, {bool notify = true}) async {
    _years = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }

  Future<void> setDays(int value, {bool notify = true}) async {
    _days = value;
    await _saveSettings();
    if (notify) notifyListeners();
  }
}






