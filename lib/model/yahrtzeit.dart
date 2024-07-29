// class Yahrtzeit {
//   String? id;
//   final String hebrewName;
//   final String foreignName;
//   final String gregorianDate;
//   final String hebrewDate;
//   final String tombPlace;
//   // final String imagePath;

//   Yahrtzeit(
//       {this.id,
//       required this.hebrewName,
//       required this.foreignName,
//       required this.gregorianDate,
//       required this.hebrewDate,
//       required this.tombPlace,
//       // required this.imagePath
//       });
// }


import 'package:json_annotation/json_annotation.dart';

part 'yahrtzeit.g.dart';

@JsonSerializable()
class Yahrtzeit {
  String? id;
  final String hebrewName;
  final String foreignName;
  final String gregorianDate;
  final String hebrewDate;
  final String tombPlace;

  Yahrtzeit({
    this.id,
    required this.hebrewName,
    required this.foreignName,
    required this.gregorianDate,
    required this.hebrewDate,
    required this.tombPlace,
  });

  factory Yahrtzeit.fromJson(Map<String, dynamic> json) => _$YahrtzeitFromJson(json);
  Map<String, dynamic> toJson() => _$YahrtzeitToJson(this);
}
