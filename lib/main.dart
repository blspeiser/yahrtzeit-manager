import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahrtzeit_manager/model/shown_yahrtzeits.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }


  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShownYahrtzeits(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        home: HomePage(
        isDarkMode: _isDarkMode,
        toggleDarkMode: _toggleDarkMode,
        ),
      ),
    );
  }
}