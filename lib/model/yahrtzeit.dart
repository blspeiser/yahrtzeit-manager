class Yahrtzeit {
  String? id;
  final String hebrewName;
  final String foreignName;
  final String gregorianDate;
  final String hebrewDate;
  final String tombPlace;
  final String imagePath;

  Yahrtzeit(
      {this.id,
      required this.hebrewName,
      required this.foreignName,
      required this.gregorianDate,
      required this.hebrewDate,
      required this.tombPlace,
      required this.imagePath});
}
