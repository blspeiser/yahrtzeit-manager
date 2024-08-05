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
//     // final gregorianDate = yahrtzeit.getGregorianDate();
//     int year = JewishDate().getJewishYear();
//     JewishDate jewishDate = JewishDate.initDate(jewishYear: year, jewishMonth: yahrtzeit.month, jewishDayOfMonth: yahrtzeit.day);
//     final gregorianDate = DateTime(jewishDate.getGregorianYear(), jewishDate.getGregorianMonth(), jewishDate.getGregorianDayOfMonth());
//     final hebrewDate = JewishDate.fromDateTime(gregorianDate);
//     return YahrtzeitDate(
//       yahrtzeit: yahrtzeit,
//       gregorianDate: gregorianDate,
//       hebrewDate: hebrewDate,
//     );
//   }
// }


import 'package:kosher_dart/kosher_dart.dart';
import 'yahrtzeit.dart';

class YahrtzeitDate {
  final Yahrtzeit yahrtzeit;
  final DateTime gregorianDate;
  final JewishDate hebrewDate;

  YahrtzeitDate({
    required this.yahrtzeit,
    required this.gregorianDate,
    required this.hebrewDate,
  });

  factory YahrtzeitDate.fromYahrtzeit(Yahrtzeit yahrtzeit) {
    final gregorianDate = yahrtzeit.getGregorianDate();
    final hebrewDate = JewishDate.fromDateTime(gregorianDate);
    return YahrtzeitDate(
      yahrtzeit: yahrtzeit,
      gregorianDate: gregorianDate,
      hebrewDate: hebrewDate,
    );
  }
}
