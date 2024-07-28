// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:yahrtzeit_manager/components/yahrtzeit_tile.dart';
// import 'package:yahrtzeit_manager/const.dart';
// import 'package:yahrtzeit_manager/model/shown_yahrtzeits.dart';
// import 'package:yahrtzeit_manager/model/yahrtzeit.dart';

// class HomePage extends StatefulWidget {
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {

//   Widget build(BuildContext context) {
//     return Consumer<ShownYahrtzeits>(
//       builder: (context, value, child) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding:  EdgeInsets.only(left: 25, top: 25),
//             child: Text(
//               "Yahrtzeits",
//               style: TextStyle(fontSize: 20),
//             ),
//           ),
//           SizedBox(height: 25),
//           Expanded(
//             child: ListView.builder(
//               itemCount: value.showmYahrtzeits.length,
//               itemBuilder: (context, index) {
//                 Yahrtzeit eachYahrtzeit = value.showmYahrtzeits[index];
//                 return YahrtzeitTile(
//                   yahrtzeit: eachYahrtzeit,
//                   onPressed: (){},
//                   // onPressed: () => goToCoffeePage(eachYahrtzeit),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/yahrtzeit_tile.dart';
import '../model/shown_yahrtzeits.dart';
import '../model/yahrtzeit.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShownYahrtzeits>(
        builder: (context, value, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25, top: 25),
              child: Text(
                "Yahrtzeits",
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 25),
            Expanded(
              child: ListView.builder(
                itemCount: value.showmYahrtzeits.length,
                itemBuilder: (context, index) {
                  Yahrtzeit eachYahrtzeit = value.showmYahrtzeits[index];
                  return YahrtzeitTile(
                    yahrtzeit: eachYahrtzeit,
                    onPressed: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
