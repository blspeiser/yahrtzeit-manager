class Yahrtzeit {
  final String englishName;
  final String hebrewName;
  final int day;
  final int month;
  final int year;
  final DateTime gregorianDate; // נוסיף את השדה הזה
  bool selected = false; // Add this line
  final String? group; // Ensure this is nullable if necessary

  Yahrtzeit({
    required this.englishName,
    required this.hebrewName,
    required this.day,
    required this.month,
    required this.year,
    required this.gregorianDate,
    this.group,
  });

  // get id => null;

  // get group => null;

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
