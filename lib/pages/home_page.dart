// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:yahrtzeit_manager/components/yahrtzeit_tile.dart';
// // import 'package:yahrtzeit_manager/const.dart';
// // import 'package:yahrtzeit_manager/model/shown_yahrtzeits.dart';
// // import 'package:yahrtzeit_manager/model/yahrtzeit.dart';

// // class HomePage extends StatefulWidget {
// //   _HomePageState createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {

// //   Widget build(BuildContext context) {
// //     return Consumer<ShownYahrtzeits>(
// //       builder: (context, value, child) => Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding:  EdgeInsets.only(left: 25, top: 25),
// //             child: Text(
// //               "Yahrtzeits",
// //               style: TextStyle(fontSize: 20),
// //             ),
// //           ),
// //           SizedBox(height: 25),
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: value.showmYahrtzeits.length,
// //               itemBuilder: (context, index) {
// //                 Yahrtzeit eachYahrtzeit = value.showmYahrtzeits[index];
// //                 return YahrtzeitTile(
// //                   yahrtzeit: eachYahrtzeit,
// //                   onPressed: (){},
// //                   // onPressed: () => goToCoffeePage(eachYahrtzeit),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../components/yahrtzeit_tile.dart';
// import '../model/shown_yahrtzeits.dart';
// import '../model/yahrtzeit.dart';
// import 'add_yahrtzeit_page.dart';
// import 'yahrtzeit_list_page.dart';

// class HomePage extends StatefulWidget {
//   final bool isDarkMode;
//   final Function toggleDarkMode;

//   const HomePage({
//     required this.isDarkMode,
//     required this.toggleDarkMode,
//   });

//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''),
//         actions: [
//           IconButton(
//             icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
//             onPressed: widget.toggleDarkMode as void Function(),
//           ),
//         ],
//       ),
//       body: Consumer<ShownYahrtzeits>(
//         builder: (context, value, child) => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left: 25, top: 25),
//               child: Text(
//                 "Yahrtzeits",
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//             SizedBox(height: 25),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: value.showmYahrtzeits.length,
//                 itemBuilder: (context, index) {
//                   Yahrtzeit eachYahrtzeit = value.showmYahrtzeits[index];
//                   return YahrtzeitTile(
//                     yahrtzeit: eachYahrtzeit,
//                     onPressed: () {},
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 300, bottom: 20),
//               child: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => AddYahrtzeitPage()));
//               },
//               style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey.shade100, // Background color
//               elevation: 10, // Elevation
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12), // Rounded corners
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),   // Padding
//             ),
//             child: Icon(
//               Icons.add,
//               size: 30, 
//               color: Colors.grey.shade700,
//             ),
//             ),
        
//             ),
//             ElevatedButton(onPressed: (){
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => YahrtzeitListPage(

//                     )));
              
//             }, child: Text('show yartzeit list'))
            
//           ],

//         ),
//       ),
//     );
//   }
// }
