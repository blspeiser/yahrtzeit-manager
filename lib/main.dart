import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahrtzeit_manager/model/shown_yahrtzeits.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShownYahrtzeits(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}