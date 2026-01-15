import 'package:kosher_dart/kosher_dart.dart';
import 'package:uuid/uuid.dart';

class Yahrtzeit {
  final String id;
  final String? englishName;
  final String? hebrewName;
  final int? day;
  final int? month;
  final String? group;
  bool selected = false;

  Yahrtzeit({
    this.englishName,
    this.hebrewName,
    this.day,
    this.month,
    this.group,
    String? id,
  }) : id = id ?? Uuid().v4(); // תן אפשרות להעביר id, אם לא, ייווצר חדש

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id'], // דאג ש־id יקרא גם מה־JSON
      englishName: json['englishName'],
      hebrewName: json['hebrewName'],
      day: json['day'],
      month: json['month'],
      group: json['group'],
    )..selected = json['selected'] ?? false;
  }
  
    DateTime getGregorianDate() {
    if (day == null || month == null) {
      throw StateError('Cannot convert to Gregorian date: day and month must be provided');
    }
    try {
      int year = JewishDate().getJewishYear();
      
      // Handle Adar II (month 13) in non-leap years: convert to Adar (month 12)
      int monthToUse = month!;
      if (monthToUse == JewishDate.ADAR_II) {
        print('DEBUG: Processing Adar II (month 13) for year $year');
        // Check if this is a leap year by testing if ADAR becomes ADAR_II
        final testDate = JewishDate.initDate(
            jewishYear: year,
            jewishMonth: JewishDate.ADAR,
            jewishDayOfMonth: 1);
        final actualMonth = testDate.getJewishMonth();
        print('DEBUG: Test date month: $actualMonth (ADAR=${JewishDate.ADAR}, ADAR_II=${JewishDate.ADAR_II})');
        if (actualMonth != JewishDate.ADAR_II) {
          // Not a leap year, so ADAR_II should be treated as ADAR
          print('DEBUG: Not a leap year, converting ADAR_II to ADAR');
          monthToUse = JewishDate.ADAR;
        } else {
          print('DEBUG: Leap year confirmed, keeping ADAR_II');
        }
      }
      
      print('DEBUG: Creating JewishDate with year=$year, month=$monthToUse, day=$day');
      JewishDate jewishDate = JewishDate.initDate(
          jewishYear: year, jewishMonth: monthToUse, jewishDayOfMonth: day!);
      final gregorianDate = DateTime(jewishDate.getGregorianYear(),
          jewishDate.getGregorianMonth(), jewishDate.getGregorianDayOfMonth());
      print('DEBUG: Successfully converted to Gregorian: $gregorianDate');
      return gregorianDate;
    } catch (e, stackTrace) {
      print('ERROR: Exception in getGregorianDate() for month=$month, day=$day: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}