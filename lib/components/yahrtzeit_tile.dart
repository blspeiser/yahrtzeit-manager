import 'package:flutter/material.dart';
import 'package:yahrtzeit_manager/model/yahrtzeit.dart';
import 'package:provider/provider.dart';

class YahrtzeitTile extends StatelessWidget {
  final Yahrtzeit yahrtzeit;
  final void Function()? onPressed;

  const YahrtzeitTile({required this.yahrtzeit, required this.onPressed});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ListTile(
        leading: Image.asset(yahrtzeit.imagePath),
        title: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(yahrtzeit.hebrewName, style: TextStyle(fontWeight: FontWeight.bold),),
              Text(yahrtzeit.foreignName,),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(yahrtzeit.hebrewDate),
            Text(yahrtzeit.gregorianDate)
          ],
        ), 
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward, color: Colors.brown[300]),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
