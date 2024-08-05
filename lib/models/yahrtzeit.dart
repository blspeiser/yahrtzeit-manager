
// class Yahrtzeit {
//   final String englishName;
//   final String hebrewName;
//   final int day;
//   final int month;
//   final int year;
//   final String? group;
//   final DateTime gregorianDate; // נוסיף את השדה הזה
//   bool selected = false; // Add this line


//   Yahrtzeit({
//     required this.englishName,
//     required this.hebrewName,
//     required this.day,
//     required this.month,
//     required this.year,
//     required this.gregorianDate,
//     this.group,
//   });

//   get id => null;

//   Map<String, dynamic> toMap() {
//     return {
//       'englishName': englishName,
//       'hebrewName': hebrewName,
//       'day': day,
//       'month': month,
//       'year': year,
//       'gregorianDate': gregorianDate.toIso8601String(),
//       'group': group,
//     };
//   }

//   factory Yahrtzeit.fromMap(Map<String, dynamic> map) {
//     return Yahrtzeit(
//       englishName: map['englishName'],
//       hebrewName: map['hebrewName'],
//       day: map['day'],
//       month: map['month'],
//       year: map['year'],
//       gregorianDate: DateTime.parse(map['gregorianDate']),
//       group: map['group'],
//     );
//   }

//   DateTime getGregorianDate() {
//     return gregorianDate;
//   }
// }



import 'package:kosher_dart/kosher_dart.dart';

class Yahrtzeit {
  final String englishName;
  final String hebrewName;
  final int day;
  final int month;
  // final int year;
  final String? group;
  // final DateTime gregorianDate; // נוסיף את השדה הזה
  bool selected = false; // Add this line


  Yahrtzeit({
    required this.englishName,
    required this.hebrewName,
    required this.day,
    required this.month,
    // required this.year,
    // required this.gregorianDate,
    this.group,
  });

  get id => null;

  Map<String, dynamic> toMap() {
    return {
      'englishName': englishName,
      'hebrewName': hebrewName,
      'day': day,
      'month': month,
      // 'year': year,
      // 'gregorianDate': gregorianDate.toIso8601String(),
      'group': group,
    };
  }

  factory Yahrtzeit.fromMap(Map<String, dynamic> map) {
    return Yahrtzeit(
      englishName: map['englishName'],
      hebrewName: map['hebrewName'],
      day: map['day'],
      month: map['month'],
      // year: map['year'],
      // gregorianDate: DateTime.parse(map['gregorianDate']),
      group: map['group'],
    );
  }

  DateTime getGregorianDate() {
    int year = JewishDate().getJewishYear();
    JewishDate jewishDate = JewishDate.initDate(jewishYear: year, jewishMonth: month, jewishDayOfMonth: day);
    final gregorianDate = DateTime(jewishDate.getGregorianYear(), jewishDate.getGregorianMonth(), jewishDate.getGregorianDayOfMonth());
    return gregorianDate;
  }
}
