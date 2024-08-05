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

  Map<String, dynamic> toJson() {
    return {
      'englishName': englishName,
      'hebrewName': hebrewName,
      'day': day,
      'month': month,
      'group': group,
      'selected': selected,
    };
  }

  factory Yahrtzeit.fromJson(Map<String, dynamic> json) {
    return Yahrtzeit(
      englishName: json['englishName'],
      hebrewName: json['hebrewName'],
      day: json['day'],
      month: json['month'],
      group: json['group'],
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
