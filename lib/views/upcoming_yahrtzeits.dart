import 'package:flutter/material.dart';
import '../localizations/app_localizations.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final yahrtzeits = await manager.getUpcomingYahrtzeits();
      print('Fetched upcoming yahrtzeits: ${yahrtzeits.length}');
      setState(() {
        yahrtzeitDates =
            _filterDuplicateYahrtzeits(manager.nextMultiple(yahrtzeits));
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<YahrtzeitDate> _filterDuplicateYahrtzeits(
      List<YahrtzeitDate> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeitDate in yahrtzeits) {
      if (uniqueNames.add(yahrtzeitDate.yahrtzeit.englishName!)) {
        filteredList.add(yahrtzeitDate);
      }
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('upcoming_yahrtzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              )
            : yahrtzeitDates.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('no_upcoming_yahrtzeits_found.'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
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
