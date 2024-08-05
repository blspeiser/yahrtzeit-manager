// import 'package:flutter/material.dart';
// import '../localizations/app_localizations.dart';
// import '../models/yahrtzeit.dart';
// import '../services/yahrtzeits_manager.dart';
// import 'add_yahrtzeit.dart';

// class ManageYahrtzeits extends StatefulWidget {
//   int yearsToSync;
//   ManageYahrtzeits({required this.yearsToSync});
//   @override
//   _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
// }

// class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
//   final YahrtzeitsManager manager = YahrtzeitsManager();
//   List<Yahrtzeit> yahrtzeits = [];
//   bool isLoading = true; // משתנה לבדוק אם הדאטה בטעינה
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

//   @override
//   void initState() {
//     super.initState();
//     fetchYahrtzeits();
//   }

//   Future<void> fetchYahrtzeits() async {
//     try {
//       final fetchedYahrtzeits = await manager.getAllYahrtzeits();
//       setState(() {
//         yahrtzeits = fetchedYahrtzeits;
//         isLoading = false; // הגדרת המשתנה ל-false לאחר שהדאטה התקבלה
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         for (var i = 0; i < yahrtzeits.length; i++) {
//           if (_listKey.currentState != null && i < yahrtzeits.length) {
//             _listKey.currentState?.insertItem(i);
//           }
//         }
//       });
//     } catch (e) {
//       print('Error fetching yahrtzeits: $e');
//       setState(() {
//         isLoading = false; // הגדרת המשתנה ל-false גם במקרה של שגיאה
//       });
//     }
//   }

//   void _editYahrtzeit(Yahrtzeit yahrtzeit) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddYahrtzeitPage(
//           yahrtzeit: yahrtzeit,
//           isEditing: true,
//           yearsToSync: widget.yearsToSync,
//         ),
//       ),
//     );
//     if (result != null && result is Yahrtzeit) {
//       await manager.deleteYahrtzeit(yahrtzeit); // מחיקת הישן
//       await manager.addYahrtzeit(result); // הוספת החדש
//       fetchYahrtzeits();
//     }
//   }

//   void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title:
//             Text(AppLocalizations.of(context)!.translate('confirm_deletion')),
//         content: Text(
//             AppLocalizations.of(context)!.translate('delete_confirmation')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(AppLocalizations.of(context)!.translate('cancel')),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text(AppLocalizations.of(context)!.translate('delete')),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         final index = yahrtzeits.indexOf(yahrtzeit);
//         if (index >= 0 && index < yahrtzeits.length) {
//           setState(() {
//             yahrtzeits.removeAt(index);
//             _listKey.currentState?.removeItem(index, (context, animation) {
//               return SizeTransition(
//                 sizeFactor: animation,
//                 child: _buildYahrtzeitTile(yahrtzeit),
//               );
//             }, duration: Duration(milliseconds: 300));
//           });
//           await manager.deleteYahrtzeit(yahrtzeit);
//         }
//       } catch (e) {
//         print('Error deleting yahrtzeit: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 AppLocalizations.of(context)!.translate('deletion_failed')),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildYahrtzeitTile(Yahrtzeit yahrtzeit) {
//     return Card(
//       elevation: 5,
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   yahrtzeit.englishName,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   yahrtzeit.hebrewName,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: Icon(Icons.edit, color: Colors.deepPurple),
//               onPressed: () => _editYahrtzeit(yahrtzeit),
//             ),
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _deleteYahrtzeit(yahrtzeit),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
//   //   await manager.deleteYahrtzeit(yahrtzeit);
//   //   fetchYahrtzeits();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.translate('manage_yahrzeits'),
//             style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 50, 4, 129),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddYahrtzeitPage(yearsToSync: widget.yearsToSync,)),
//               ).then((result) {
//                 if (result == true) {
//                   fetchYahrtzeits();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         color: Colors.white,
//         child: isLoading // בדיקה אם הדאטה עדיין בטעינה
//             ? Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                 ),
//               )
//             : yahrtzeits.isEmpty // בדיקה אם הרשימה ריקה
//                 ? Center(
//                     child: Text(
//                       AppLocalizations.of(context)!
//                           .translate('you_have_not_added_any_yahrtzeits_yet.'),
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   )
//                 : AnimatedList(
//                     key: _listKey,
//                     initialItemCount: yahrtzeits.length,
//                     itemBuilder: (context, index, animation) {
//                       if (index >= yahrtzeits.length) {
//                         return SizedBox.shrink();
//                       }
//                       return FadeTransition(
//                         opacity: animation,
//                         child: _buildYahrtzeitTile(yahrtzeits[index]),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }


















// import 'package:flutter/material.dart';
// import 'package:kosher_dart/kosher_dart.dart';
// import '../localizations/app_localizations.dart';
// import '../models/yahrtzeit.dart';
// import '../services/yahrtzeits_manager.dart';
// import 'add_yahrtzeit.dart';

// class ManageYahrtzeits extends StatefulWidget {
//   int yearsToSync;
//   ManageYahrtzeits({required this.yearsToSync});
  
//   @override
//   _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
// }

// class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
//   final YahrtzeitsManager manager = YahrtzeitsManager();
//   List<Yahrtzeit> yahrtzeits = [];
//   bool isLoading = true; // משתנה לבדוק אם הדאטה בטעינה
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

//   static const Map<int, String> hebrewMonths = {
//     JewishDate.NISSAN: 'Nissan',
//     JewishDate.IYAR: 'Iyar',
//     JewishDate.SIVAN: 'Sivan',
//     JewishDate.TAMMUZ: 'Tammuz',
//     JewishDate.AV: 'Av',
//     JewishDate.ELUL: 'Elul',
//     JewishDate.TISHREI: 'Tishrei',
//     JewishDate.CHESHVAN: 'Cheshvan',
//     JewishDate.KISLEV: 'Kislev',
//     JewishDate.TEVES: 'Teves',
//     JewishDate.SHEVAT: 'Shevat',
//     JewishDate.ADAR: 'Adar',
//     JewishDate.ADAR_II: 'Adar II',
//   };

//   @override
//   void initState() {
//     super.initState();
//     fetchYahrtzeits();
//   }

//   Future<void> fetchYahrtzeits() async {
//     try {
//       final fetchedYahrtzeits = await manager.getAllYahrtzeits();
//       setState(() {
//         yahrtzeits = fetchedYahrtzeits;
//         isLoading = false; // הגדרת המשתנה ל-false לאחר שהדאטה התקבלה
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         for (var i = 0; i < yahrtzeits.length; i++) {
//           if (_listKey.currentState != null && i < yahrtzeits.length) {
//             _listKey.currentState?.insertItem(i);
//           }
//         }
//       });
//     } catch (e) {
//       print('Error fetching yahrtzeits: $e');
//       setState(() {
//         isLoading = false; // הגדרת המשתנה ל-false גם במקרה של שגיאה
//       });
//     }
//   }

//   void _editYahrtzeit(Yahrtzeit yahrtzeit) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddYahrtzeitPage(
//           yahrtzeit: yahrtzeit,
//           isEditing: true,
//           yearsToSync: widget.yearsToSync,
//         ),
//       ),
//     );
//     if (result != null && result is Yahrtzeit) {
//       await manager.deleteYahrtzeit(yahrtzeit); // מחיקת הישן
//       await manager.addYahrtzeit(result); // הוספת החדש
//       fetchYahrtzeits();
//     }
//   }

//   void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title:
//             Text(AppLocalizations.of(context)!.translate('confirm_deletion')),
//         content: Text(
//             AppLocalizations.of(context)!.translate('delete_confirmation')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(AppLocalizations.of(context)!.translate('cancel')),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text(AppLocalizations.of(context)!.translate('delete')),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         final index = yahrtzeits.indexOf(yahrtzeit);
//         if (index >= 0 && index < yahrtzeits.length) {
//           setState(() {
//             yahrtzeits.removeAt(index);
//             _listKey.currentState?.removeItem(index, (context, animation) {
//               return SizeTransition(
//                 sizeFactor: animation,
//                 child: _buildYahrtzeitTile(yahrtzeit),
//               );
//             }, duration: Duration(milliseconds: 300));
//           });
//           await manager.deleteYahrtzeit(yahrtzeit);
//         }
//       } catch (e) {
//         print('Error deleting yahrtzeit: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 AppLocalizations.of(context)!.translate('deletion_failed')),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildYahrtzeitTile(Yahrtzeit yahrtzeit) {
//     return Card(
//       elevation: 5,
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   yahrtzeit.englishName,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   '${yahrtzeit.day} ${yahrtzeit.month}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//                   yahrtzeit.hebrewName,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 // SizedBox(height: 3),
//                 Text(
//                   '${yahrtzeit.day} ${hebrewMonths[yahrtzeit.month] ?? yahrtzeit.month}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 // SizedBox(height: 3),
//                 // Text(
//                 //   '${yahrtzeit.day} ${yahrtzeit.month}',
//                 //   style: TextStyle(
//                 //     fontSize: 16,
//                 //     color: Colors.grey[600],
//                 //   ),
//                 // ),
//                 Text(
//                   '${yahrtzeit.group}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }

//   // void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
//   //   await manager.deleteYahrtzeit(yahrtzeit);
//   //   fetchYahrtzeits();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.translate('manage_yahrzeits'),
//             style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 50, 4, 129),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddYahrtzeitPage(yearsToSync: widget.yearsToSync,)),
//               ).then((result) {
//                 if (result == true) {
//                   fetchYahrtzeits();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         color: Colors.white,
//         child: isLoading // בדיקה אם הדאטה עדיין בטעינה
//             ? Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                 ),
//               )
//             : yahrtzeits.isEmpty // בדיקה אם הרשימה ריקה
//                 ? Center(
//                     child: Text(
//                       AppLocalizations.of(context)!
//                           .translate('you_have_not_added_any_yahrtzeits_yet.'),
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   )
//                 : AnimatedList(
//                     key: _listKey,
//                     initialItemCount: yahrtzeits.length,
//                     itemBuilder: (context, index, animation) {
//                       if (index >= yahrtzeits.length) {
//                         return SizedBox.shrink();
//                       }
//                       return FadeTransition(
//                         opacity: animation,
//                         child: _buildYahrtzeitTile(yahrtzeits[index]),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }



















import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';
import '../localizations/app_localizations.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_date.dart';
import '../services/yahrtzeits_manager.dart';
import 'add_yahrtzeit.dart';

class ManageYahrtzeits extends StatefulWidget {
  int yearsToSync;

  ManageYahrtzeits({required this.yearsToSync});
  
  @override
  _ManageYahrtzeitsState createState() => _ManageYahrtzeitsState();
}

class _ManageYahrtzeitsState extends State<ManageYahrtzeits> {
  final YahrtzeitsManager manager = YahrtzeitsManager();
  List<YahrtzeitDate> yahrtzeitDates = [];
  bool isLoading = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  static const Map<int, String> hebrewMonths = {
    JewishDate.NISSAN: 'Nissan',
    JewishDate.IYAR: 'Iyar',
    JewishDate.SIVAN: 'Sivan',
    JewishDate.TAMMUZ: 'Tammuz',
    JewishDate.AV: 'Av',
    JewishDate.ELUL: 'Elul',
    JewishDate.TISHREI: 'Tishrei',
    JewishDate.CHESHVAN: 'Cheshvan',
    JewishDate.KISLEV: 'Kislev',
    JewishDate.TEVES: 'Teves',
    JewishDate.SHEVAT: 'Shevat',
    JewishDate.ADAR: 'Adar',
    JewishDate.ADAR_II: 'Adar II',
  };

  @override
  void initState() {
    super.initState();
    fetchYahrtzeits();
  }

  Future<void> fetchYahrtzeits() async {
    try {
      final fetchedYahrtzeits = await manager.getAllYahrtzeits();
      setState(() {
        yahrtzeitDates = _filterDuplicateYahrtzeits(fetchedYahrtzeits);
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var i = 0; i < yahrtzeitDates.length; i++) {
          if (_listKey.currentState != null && i < yahrtzeitDates.length) {
            _listKey.currentState?.insertItem(i);
          }
        }
      });
    } catch (e) {
      print('Error fetching yahrtzeits: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<YahrtzeitDate> _filterDuplicateYahrtzeits(List<Yahrtzeit> yahrtzeits) {
    final uniqueNames = <String>{};
    final filteredList = <YahrtzeitDate>[];

    for (var yahrtzeit in yahrtzeits) {
      if (uniqueNames.add(yahrtzeit.englishName)) {
        filteredList.add(YahrtzeitDate.fromYahrtzeit(yahrtzeit));
      }
    }

    return filteredList;
  }

  void _editYahrtzeit(Yahrtzeit yahrtzeit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddYahrtzeitPage(
          yearsToSync: widget.yearsToSync,
          yahrtzeit: yahrtzeit,
          isEditing: true,
        ),
      ),
    );
    if (result != null && result is Yahrtzeit) {
      await manager.deleteYahrtzeit(yahrtzeit);
      await manager.addYahrtzeit(result, widget.yearsToSync);
      fetchYahrtzeits();
    }
  }

  void _deleteYahrtzeit(Yahrtzeit yahrtzeit) async {
    try {
      final index =
          yahrtzeitDates.indexWhere((date) => date.yahrtzeit == yahrtzeit);
      if (index >= 0 && index < yahrtzeitDates.length) {
        setState(() {
          yahrtzeitDates.removeAt(index);
          _listKey.currentState?.removeItem(index, (context, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: SizedBox.shrink(),
            );
          }, duration: Duration(milliseconds: 300));
        });
        await manager.deleteYahrtzeit(yahrtzeit);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('confirm_deletion')),
        content: Text(AppLocalizations.of(context)!.translate('delete_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.translate('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final index = yahrtzeits.indexOf(yahrtzeit);
        if (index >= 0 && index < yahrtzeits.length) {
          setState(() {
            yahrtzeits.removeAt(index);
            _listKey.currentState?.removeItem(index, (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _buildYahrtzeitTile(yahrtzeit),
              );
            }, duration: Duration(milliseconds: 300));
          });
          await manager.deleteYahrtzeit(yahrtzeit);
        }
      } catch (e) {
        print('Error deleting yahrtzeit: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('deletion_failed')),
          ),
        );
      }
    } catch (e) {
      print('Error deleting yahrtzeit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.translate('deletion_failed')),
        ),
      );
    }
  }

  Widget _buildYahrtzeitTile(YahrtzeitDate yahrtzeitDate) {
    String hebrewDate = _getHebrewDateString(yahrtzeitDate.hebrewDate);
    String englishDate = _getEnglishDateString(yahrtzeitDate.hebrewDate);

    return Dismissible(
      key: Key(yahrtzeitDate.yahrtzeit.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteYahrtzeit(yahrtzeitDate.yahrtzeit);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yahrtzeitDate.yahrtzeit.englishName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    englishDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    yahrtzeitDate.yahrtzeit.hebrewName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    hebrewDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: Colors.deepPurple),
            onPressed: () => _editYahrtzeit(yahrtzeitDate.yahrtzeit),
          ),
        ),
  // Widget _buildYahrtzeitTile(Yahrtzeit yahrtzeit) {
  //   return Card(
  //     elevation: 5,
  //     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: ListTile(
  //       contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
  //       title: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 yahrtzeit.englishName,
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               SizedBox(height: 5),
  //               Text(
  //                 '${yahrtzeit.day} ${yahrtzeit.month}',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.grey[600],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       trailing: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             yahrtzeit.hebrewName,
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black,
  //             ),
  //           ),
  //           Text(
  //             '${yahrtzeit.day} ${hebrewMonths[yahrtzeit.month] ?? yahrtzeit.month}',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //           Text(
  //             '${yahrtzeit.group}',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  String _getHebrewDateString(JewishDate date) {
    final hebrewFormatter = HebrewDateFormatter()
      ..hebrewFormat = true
      ..useGershGershayim = true;
    String fullDate = hebrewFormatter.format(date);
    List<String> dateParts = fullDate.split(' ');
    return '${dateParts[0]} ${dateParts[1]}';
  }

  String _getEnglishDateString(JewishDate date) {
    final englishFormatter = DateFormat('MMMM d, yyyy');
    return '${date.getJewishDayOfMonth()} ${_getEnglishMonthName(date.getJewishMonth())}';
  }

  String _getEnglishMonthName(int month) {
    switch (month) {
      case JewishDate.NISSAN:
        return 'Nissan';
      case JewishDate.IYAR:
        return 'Iyar';
      case JewishDate.SIVAN:
        return 'Sivan';
      case JewishDate.TAMMUZ:
        return 'Tammuz';
      case JewishDate.AV:
        return 'Av';
      case JewishDate.ELUL:
        return 'Elul';
      case JewishDate.TISHREI:
        return 'Tishrei';
      case JewishDate.CHESHVAN:
        return 'Cheshvan';
      case JewishDate.KISLEV:
        return 'Kislev';
      case JewishDate.TEVES:
        return 'Teves';
      case JewishDate.SHEVAT:
        return 'Shevat';
      case JewishDate.ADAR:
        return 'Adar';
      case JewishDate.ADAR_II:
        return 'Adar II';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('manage_yahrzeits'),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 50, 4, 129),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddYahrtzeitPage(yearsToSync: widget.yearsToSync),
                ),
              ).then((result) {
                if (result == true) {
                  fetchYahrtzeits();
                }
              });
            },
          ),
        ],
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
                      AppLocalizations.of(context)!.translate('you_have_not_added_any_yahrtzeits_yet.'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: yahrtzeitDates.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= yahrtzeitDates.length) {
                        return SizedBox.shrink();
                      }
                      return FadeTransition(
                        opacity: animation,
                        child: _buildYahrtzeitTile(yahrtzeitDates[index]),
                      );
                    },
                  ),
      ),
    );
  }
}
