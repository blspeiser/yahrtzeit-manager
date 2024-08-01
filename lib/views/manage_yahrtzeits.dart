import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
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

  void _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddYahrtzeitPage(
          yahrtzeit: yahrtzeit,
          isEditing: true,
        ),
      ),
    );
    if (result == true) {
      fetchYahrtzeits();
    }
  }

  void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    await manager.deleteYahrtzeit(yahrtzeit);
    fetchYahrtzeits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('manage_yahrzeits'), style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddYahrtzeitPage()),
              ).then((_) => fetchYahrtzeits());
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: yahrtzeits.isEmpty
            ? Center(
                child: Text('No yahrtzeits available'),
              )
            : ListView.builder(
                itemCount: yahrtzeits.length,
                itemBuilder: (context, index) {
                  if (index < yahrtzeits.length) {
                    final yahrtzeit = yahrtzeits[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  yahrtzeit.englishName,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  yahrtzeit.hebrewName,
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () => _editYahrtzeit(yahrtzeit),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteYahrtzeit(yahrtzeit),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink(); // Return an empty widget if index is out of bounds
                  }
                },
              ),
      ),
    );
  }
}