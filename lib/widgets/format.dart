import 'package:kosher_dart/kosher_dart.dart';

String getHebrewMonthName(int month) {
  const months = [
    'ניסן', 'אייר', 'סיון', 'תמוז', 'אב', 'אלול',
    'תשרי', 'חשוון', 'כסלו', 'טבת', 'שבט', 'אדר', ' אדר א', 'אדר ב'
  ];
  return months[month - 1];
}

String getHebrewDay(int day){
   const hebrewLetters = [
  'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י', 'יא', 'יב', 'יג', 'יד',
  'טו', 'טז', 'יז', 'יח', 'יט', 'כ', 'כא', 'כב', 'כג', 'כד', 'כה', 'כו',
  'כז', 'כח', 'כט', 'ל'
];
return hebrewLetters[day-1];
}

// פונקציה להמרת תאריך עברי למחרוזת עם יום וחודש בלבד
String formatHebrewDate(int? month, int? day) {
  if (month == null || day == null) {
    return 'תאריך חסר';
  }

  JewishDate jewishDate = JewishDate.initDate(
    jewishYear: JewishDate().getJewishYear(),
    jewishMonth: month,
    jewishDayOfMonth: day,
  );

 String monthName = getHebrewMonthName(month);
 String dayString = getHebrewDay(day);
  return "$dayString' $monthName";
}





