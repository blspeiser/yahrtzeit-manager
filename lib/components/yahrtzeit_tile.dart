import 'package:flutter/material.dart';
import 'package:yahrtzeit_manager/model/yahrtzeit.dart';

class YahrtzeitTile extends StatelessWidget {
  final Yahrtzeit yahrtzeit;
  final void Function()? onPressed;

  const YahrtzeitTile({required this.yahrtzeit, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  yahrtzeit.foreignName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  yahrtzeit.hebrewName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  yahrtzeit.hebrewDate,
                  style: TextStyle(fontSize: 18, ),
                ),
                Spacer(),
                Text(
                  yahrtzeit.gregorianDate,
                  style: TextStyle(fontSize: 18,),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
