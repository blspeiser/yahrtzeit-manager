import 'yahrtzeit.dart';
import 'dart:convert';

class YahrtzeitLibrary {
  final String version;
  final DateTime exportDate;
  final List<Yahrtzeit> yahrtzeits;
  final String? iconReference;

  YahrtzeitLibrary({
    required this.version,
    required this.exportDate,
    required this.yahrtzeits,
    this.iconReference,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportDate': exportDate.toIso8601String(),
      'yahrtzeits': yahrtzeits.map((y) => y.toJson()).toList(),
      if (iconReference != null) 'iconReference': iconReference,
    };
  }

  factory YahrtzeitLibrary.fromJson(Map<String, dynamic> json) {
    return YahrtzeitLibrary(
      version: json['version'] ?? '1.0',
      exportDate: DateTime.parse(json['exportDate']),
      yahrtzeits: (json['yahrtzeits'] as List)
          .map((y) => Yahrtzeit.fromJson(y))
          .toList(),
      iconReference: json['iconReference'],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory YahrtzeitLibrary.fromJsonString(String jsonString) {
    return YahrtzeitLibrary.fromJson(jsonDecode(jsonString));
  }

  static bool isValidJson(Map<String, dynamic> json) {
    return json.containsKey('version') &&
        json.containsKey('exportDate') &&
        json.containsKey('yahrtzeits') &&
        json['yahrtzeits'] is List;
  }
}
