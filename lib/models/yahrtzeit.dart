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

import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

class Yahrtzeit {
  final String englishName;
  final String hebrewName;
  final int day;
  final int month;
  final int year;
  final ZonedDateTime gregorianDate;

  Yahrtzeit({
    required this.englishName,
    required this.hebrewName,
    required this.day,
    required this.month,
    required this.year,
    required this.gregorianDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'englishName': englishName,
      'hebrewName': hebrewName,
      'day': day,
      'month': month,
      'year': year,
      'gregorianDate': gregorianDate.toString(),
    };
  }

  factory Yahrtzeit.fromMap(Map<String, dynamic> map) {
    final pattern = ZonedDateTimePattern.createWithInvariantCulture('yyyy-MM-ddTHH:mm:ss');
    final parseResult = pattern.parse(map['gregorianDate']);
    if (!parseResult.success) {
      throw FormatException('Invalid date format');
    }
    return Yahrtzeit(
      englishName: map['englishName'],
      hebrewName: map['hebrewName'],
      day: map['day'],
      month: map['month'],
      year: map['year'],
      gregorianDate: parseResult.value,
    );
  }

  ZonedDateTime getGregorianDate() {
    return gregorianDate;
  }

  Instant getGregorianInstant() {
    return gregorianDate.toInstant();
  }
}
