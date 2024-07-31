import 'package:flutter/material.dart';
import '../models/yahrtzeit.dart';
import '../services/yahrtzeits_manager.dart';
import 'add_yahrtzeit.dart';

class ManageYahrtzeits extends StatefulWidget {
  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<Yahrtzeit> yahrtzeits = [];

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> fetchYahrtzeits() async {
    final fetchedYahrtzeits = await manager.getAllYahrtzeits();
    setState(() {
      yahrtzeits = fetchedYahrtzeits;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Yahrtzeits'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddYahrtzeitPage()),
              ).then((_) => fetchYahrtzeits());
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: yahrtzeits.length,
        itemBuilder: (context, index) {
          final yahrtzeit = yahrtzeits[index];
          return ListTile(
            title: Text(yahrtzeit.englishName),
            subtitle: Text(yahrtzeit.hebrewName),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // ניווט לדף עריכת Yahrtzeit קיים
              },
            ),
          );
        },
      ),
    );
  }
}