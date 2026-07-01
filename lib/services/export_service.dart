import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yahrtzeit_manager/models/yahrtzeit.dart';
import 'package:yahrtzeit_manager/models/yahrtzeit_library.dart';

class ExportService {
  static const String _fileExtension = '.yzl';
  static const String _version = '1.0';
  static const String _iconReference = 'com.yahrtzeit.library';

  /// Converts a string to a safe filename format.
  /// Preserves Unicode characters (including Hebrew) while making ASCII text snake_case.
  /// Falls back to 'yahrtzeit' if the result would be empty.
  String _toSafeFileName(String input) {
    var result = input
        // Convert camelCase to snake_case for ASCII letters
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        // Replace spaces and non-word characters with underscores, keeping Unicode letters/digits
        .replaceAll(RegExp(r'[^\p{L}\p{N}_]', unicode: true), '_')
        // Collapse multiple underscores
        .replaceAll(RegExp(r'_+'), '_')
        // Remove leading/trailing underscores
        .replaceAll(RegExp(r'^_|_$'), '')
        .toLowerCase();
    
    // If result is empty (e.g., only had characters that got stripped), use fallback
    if (result.isEmpty) {
      result = 'yahrtzeit';
    }
    
    return result;
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
        finalFileName = _toSafeFileName(fileName);
      } else {
        // Determine filename based on content
        if (yahrtzeits.length == 1) {
          // Single yahrtzeit - use english name (civil name), fallback to hebrew name (jewish name)
          final name = yahrtzeits.first.englishName ?? 
              yahrtzeits.first.hebrewName ?? 
              'yahrtzeit';
          finalFileName = _toSafeFileName(name);
        } else {
          // Multiple yahrtzeits - check if they're all from the same group
          final groups = yahrtzeits
              .map((y) => y.group)
              .where((g) => g != null && g.isNotEmpty)
              .toSet();
          if (groups.length == 1) {
            // All from same group - use group name
            finalFileName = _toSafeFileName(groups.first!);
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
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Yahrtzeit Library',
        ),
      );

      return file.path;
    } catch (e) {
      rethrow;
    }
  }
}
