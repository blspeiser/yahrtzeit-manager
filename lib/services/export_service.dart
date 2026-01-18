import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/yahrtzeit.dart';
import '../models/yahrtzeit_library.dart';

class ExportService {
  static const String _fileExtension = '.yzl';
  static const String _version = '1.0';
  static const String _iconReference = 'com.yahrtzeit.library';

  /// Converts a string to snake_case
  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '')
        .toLowerCase();
  }

  /// Exports a list of yahrtzeits to a .YZL file and shares it via native share dialog
  ///
  /// [yahrtzeits] - List of yahrtzeits to export
  /// [fileName] - Optional custom filename (without extension). If not provided, generates based on content
  /// Returns the file path if successful, null otherwise
  Future<String?> exportYahrtzeits(
    List<Yahrtzeit> yahrtzeits, {
    String? fileName,
  }) async {
    if (yahrtzeits.isEmpty) {
      throw ArgumentError('Cannot export empty list of yahrtzeits');
    }

    try {
      // Generate filename if not provided
      String finalFileName;
      if (fileName != null) {
        finalFileName = _toSnakeCase(fileName);
      } else {
        // Determine filename based on content
        if (yahrtzeits.length == 1) {
          // Single yahrtzeit - use english name in snake_case
          final name = yahrtzeits.first.englishName ?? 'yahrtzeit';
          finalFileName = _toSnakeCase(name);
        } else {
          // Multiple yahrtzeits - check if they're all from the same group
          final groups = yahrtzeits
              .map((y) => y.group)
              .where((g) => g != null && g.isNotEmpty)
              .toSet();
          if (groups.length == 1) {
            // All from same group - use group name
            finalFileName = _toSnakeCase(groups.first!);
          } else {
            // Mixed or no groups - use "all"
            finalFileName = 'all';
          }
        }
      }

      // Create YahrtzeitLibrary object
      final library = YahrtzeitLibrary(
        version: _version,
        exportDate: DateTime.now(),
        yahrtzeits: yahrtzeits,
        iconReference: _iconReference,
      );

      // Convert to JSON string
      final jsonString = library.toJsonString();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$finalFileName$_fileExtension');

      // Write JSON to file
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Yahrtzeit Library',
      );

      return file.path;
    } catch (e) {
      rethrow;
    }
  }
}
