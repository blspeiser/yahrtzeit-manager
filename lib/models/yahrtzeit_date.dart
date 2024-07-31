// import 'package:kosher_dart/kosher_dart.dart';
// import 'yahrtzeit.dart';

// class YahrtzeitDate {
//   final Yahrtzeit yahrtzeit;
//   final DateTime gregorianDate;

//   final JewishDate hebrewDate;

//   YahrtzeitDate({
//     required this.yahrtzeit,
//     required this.gregorianDate,
//     required this.hebrewDate,
//   });

//   factory YahrtzeitDate.fromYahrtzeit(Yahrtzeit yahrtzeit) {
//     final gregorianDate = yahrtzeit.getGregorianDate();
//     final hebrewDate = JewishDate.fromDateTime(gregorianDate);
//     return YahrtzeitDate(
//       yahrtzeit: yahrtzeit,
//       gregorianDate: gregorianDate,
//       hebrewDate: hebrewDate,
//     );
//   }
//// }

import 'package:kosher_dart/kosher_dart.dart';
import 'package:time_machine/time_machine.dart';
import 'yahrtzeit.dart';

class YahrtzeitDate {
  final Yahrtzeit yahrtzeit;
  final ZonedDateTime gregorianDate;
  final JewishDate hebrewDate;

  YahrtzeitDate({
    required this.yahrtzeit,
    required this.gregorianDate,
    required this.hebrewDate,
  });

  factory YahrtzeitDate.fromYahrtzeit(Yahrtzeit yahrtzeit) {
    final gregorianDate = yahrtzeit.getGregorianDate();
    final dateTime = DateTime(
      gregorianDate.year,
      gregorianDate.monthOfYear,
      gregorianDate.dayOfMonth,
      gregorianDate.hourOfDay,
      gregorianDate.minuteOfHour,
      gregorianDate.secondOfMinute,
      gregorianDate.millisecondOfSecond,
      gregorianDate.microsecondOfSecond,
    );
    final hebrewDate = JewishDate.fromDateTime(dateTime);
    return YahrtzeitDate(
      yahrtzeit: yahrtzeit,
      gregorianDate: gregorianDate,
      hebrewDate: hebrewDate,
    );
  }
}
