// class Yahrtzeit {
//   final String englishName;
//   final String hebrewName;
//   final int day;
//   final int month;
//   final int year;
//   final DateTime gregorianDate; // נוסיף את השדה הזה

//   Yahrtzeit({
//     required this.englishName,
//     required this.hebrewName,
//     required this.day,
//     required this.month,
//     required this.year,
//     required this.gregorianDate,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'englishName': englishName,
//       'hebrewName': hebrewName,
//       'day': day,
//       'month': month,
//       'year': year,
//       'gregorianDate': gregorianDate.toIso8601String(),
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
//     );
//   }

//   DateTime getGregorianDate() {
//     return gregorianDate;
//   }
// }


class Yahrtzeit {
  final String englishName;
  final String hebrewName;
  final int day;
  final int month;
  final int year;
  final DateTime gregorianDate; // נוסיף את השדה הזה
  bool selected = false; // Add this line


  Yahrtzeit({
    required this.englishName,
    required this.hebrewName,
    required this.day,
    required this.month,
    required this.year,
    required this.gregorianDate,
  });

  get id => null;

  Map<String, dynamic> toMap() {
    return {
      'englishName': englishName,
      'hebrewName': hebrewName,
      'day': day,
      'month': month,
      'year': year,
      'gregorianDate': gregorianDate.toIso8601String(),
    };
  }

  factory Yahrtzeit.fromMap(Map<String, dynamic> map) {
    return Yahrtzeit(
      englishName: map['englishName'],
      hebrewName: map['hebrewName'],
      day: map['day'],
      month: map['month'],
      year: map['year'],
      gregorianDate: DateTime.parse(map['gregorianDate']),
    );
  }

  DateTime getGregorianDate() {
    return gregorianDate;
  }
}
