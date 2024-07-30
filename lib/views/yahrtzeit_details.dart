import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../models/yahrtzeit_date.dart';

class YahrtzeitDetailsPage extends StatelessWidget {
  final YahrtzeitDate yahrtzeitDate;

  YahrtzeitDetailsPage({required this.yahrtzeitDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${yahrtzeitDate.yahrtzeit.englishName} Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Yahrtzeit Details:\n\n'
                'English Name: ${yahrtzeitDate.yahrtzeit.englishName}\n'
                'Hebrew Name: ${yahrtzeitDate.yahrtzeit.hebrewName}\n'
                'Gregorian Date: ${yahrtzeitDate.gregorianDate.toLocal().toString().split(' ')[0]}\n'
                'Hebrew Date: ${yahrtzeitDate.hebrewDate}',
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('English Name: ${yahrtzeitDate.yahrtzeit.englishName}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Hebrew Name: ${yahrtzeitDate.yahrtzeit.hebrewName}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Gregorian Date: ${yahrtzeitDate.gregorianDate.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Hebrew Date: ${yahrtzeitDate.hebrewDate}', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
