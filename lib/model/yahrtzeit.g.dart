// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yahrtzeit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Yahrtzeit _$YahrtzeitFromJson(Map<String, dynamic> json) => Yahrtzeit(
      id: json['id'] as String?,
      hebrewName: json['hebrewName'] as String,
      foreignName: json['foreignName'] as String,
      gregorianDate: json['gregorianDate'] as String,
      hebrewDate: json['hebrewDate'] as String,
      tombPlace: json['tombPlace'] as String,
    );

Map<String, dynamic> _$YahrtzeitToJson(Yahrtzeit instance) => <String, dynamic>{
      'id': instance.id,
      'hebrewName': instance.hebrewName,
      'foreignName': instance.foreignName,
      'gregorianDate': instance.gregorianDate,
      'hebrewDate': instance.hebrewDate,
      'tombPlace': instance.tombPlace,
    };
