// import 'package:flutter/material.dart';

// enum KeyboardLayoutType { English, Hebrew }

// class KeyboardLayout extends StatelessWidget {
//   final KeyboardLayoutType layoutType;
//   final Function(String) onKeyPressed;

//   KeyboardLayout({required this.layoutType, required this.onKeyPressed});

//   @override
//   Widget build(BuildContext context) {
//     List<List<String>> keys;

//     if (layoutType == KeyboardLayoutType.English) {
//       keys = [
//         ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
//         ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
//         ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
//         ['Lang', ' ', ',', 'DEL']
//       ];
//     } else {
//       keys = [
//         ['ק', 'ר', 'א', 'ט', 'ו', 'ו', 'ן', 'ם', 'פ'],
//         ['ש', 'ד', 'ג', 'כ', 'ע', 'י', 'ח', 'ל', 'ך'],
//         ['ז', 'ס', 'ב', 'ה', 'נ', 'מ', 'צ', 'ת', 'ץ'],
//         ['Lang', ' ', ',', 'DEL']
//       ];
//     }

//     return Container(
//       color: Colors.grey[300],
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: keys.map((row) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: row.map((key) {
//               return Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       onKeyPressed(key);
//                     },
//                     child: Text(key == 'Lang'
//                         ? (layoutType == KeyboardLayoutType.English
//                             ? 'EN'
//                             : 'HE')
//                         : key),
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

enum KeyboardLayoutType { English, Hebrew }

class KeyboardLayout extends StatelessWidget {
  final KeyboardLayoutType layoutType;
  final Function(String) onKeyPressed;

  KeyboardLayout({required this.layoutType, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    List<List<String>> keys;

    if (layoutType == KeyboardLayoutType.English) {
      keys = [
        ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
        ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
        ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
        ['Lang', ' ', ',', 'DEL']
      ];
    } else {
      keys = [
        ['ק', 'ר', 'א', 'ט', 'ו', 'ו', 'ן', 'ם', 'פ'],
        ['ש', 'ד', 'ג', 'כ', 'ע', 'י', 'ח', 'ל', 'ך'],
        ['ז', 'ס', 'ב', 'ה', 'נ', 'מ', 'צ', 'ת', 'ץ'],
        ['Lang', ' ', ',', 'DEL']
      ];
    }

    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // primary: Colors.white, // Background color
                      // onPrimary: Colors.black, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: Size(40, 40), // Minimum button size
                      padding: EdgeInsets.all(0), // Remove default padding
                    ),
                    onPressed: () {
                      onKeyPressed(key);
                    },
                    child: Center(
                      child: Text(
                        key == 'Lang'
                            ? (layoutType == KeyboardLayoutType.English
                                ? 'EN'
                                : 'HE')
                            : key,
                        style: TextStyle(
                          fontSize: 18, // Adjust text size if needed
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
