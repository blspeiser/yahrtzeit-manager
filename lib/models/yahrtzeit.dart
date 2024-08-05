import 'package:kosher_dart/kosher_dart.dart';

class Yahrtzeit {
  final String englishName;
  final String hebrewName;
  final int day;
  final int month;
  final String? group;
  bool selected = false; // Add this line

  Yahrtzeit({
    required this.englishName,
    required this.hebrewName,
    required this.day,
    required this.month,
    this.group,
  });

  get id => null;

  Map<String, dynamic> toMap() {
    return {
      'englishName': englishName,
      'hebrewName': hebrewName,
      'day': day,
      'month': month,
      'group': group,
    };
  }

  factory Yahrtzeit.fromMap(Map<String, dynamic> map) {
    return Yahrtzeit(
      englishName: map['englishName'],
      hebrewName: map['hebrewName'],
      day: map['day'],
      month: map['month'],
      group: map['group'],
    );
  }

  DateTime getGregorianDate() {
    int year = JewishDate().getJewishYear();
    JewishDate jewishDate = JewishDate.initDate(
        jewishYear: year, jewishMonth: month, jewishDayOfMonth: day);
    final gregorianDate = DateTime(jewishDate.getGregorianYear(),
        jewishDate.getGregorianMonth(), jewishDate.getGregorianDayOfMonth());
    return gregorianDate;
  }
}
