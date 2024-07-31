import 'package:flutter/material.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';
import '../widgets/yahrtzeit_tile.dart';

class UpcomingYahrtzeits extends StatefulWidget {
  @override
  _UpcomingYahrtzeitsState createState() => _UpcomingYahrtzeitsState();
}

class _UpcomingYahrtzeitsState extends State<UpcomingYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<YahrtzeitDate> yahrtzeitDates = [];

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final yahrtzeits = await manager.getUpcomingYahrtzeits();
      final upcomingDates = manager.nextMultiple(yahrtzeits);
      setState(() {
        yahrtzeitDates = upcomingDates;
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Yahrtzeits', style: TextStyle(color: Colors.white, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: yahrtzeitDates.isEmpty
            ? Center(
                child: Text(
                  'No upcoming yahrtzeits found.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: yahrtzeitDates.length,
                itemBuilder: (context, index) {
                  final yahrtzeitDate = yahrtzeitDates[index];
                  return YahrtzeitTile(yahrtzeitDate: yahrtzeitDate);
                },
              ),
      ),
    );
  }
}