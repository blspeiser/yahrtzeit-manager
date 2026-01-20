import 'dart:io';
import 'package:yahrtzeit_manager/models/yahrtzeit.dart';
import 'package:yahrtzeit_manager/models/yahrtzeit_library.dart';
import 'package:yahrtzeit_manager/services/yahrtzeits_manager.dart';

class ImportResult {
  final int successCount;
  final int failureCount;
  final int duplicateCount;
  final List<String> errors;

  ImportResult({
    required this.successCount,
    required this.failureCount,
    required this.duplicateCount,
    this.errors = const [],
  });

  bool get hasErrors => errors.isNotEmpty;
  int get totalProcessed => successCount + failureCount + duplicateCount;
}

class ImportService {
  final YahrtzeitsManager _manager = YahrtzeitsManager();

  /// Imports yahrtzeits from a .YZL file
  /// 
  /// [filePath] - Path to the .YZL file
  /// [bulkGroupOverride] - Optional group name to apply to all imported yahrtzeits
  /// Returns ImportResult with success/failure counts
  Future<ImportResult> importYahrtzeitsFromFile(
    String filePath, {
    String? bulkGroupOverride,
  }) async {
    final errors = <String>[];
    int successCount = 0;
    int failureCount = 0;
    int duplicateCount = 0;

    try {
      // Read file
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('File not found: $filePath');
      }

      final jsonString = await file.readAsString();

      // Parse JSON
      final library = YahrtzeitLibrary.fromJsonString(jsonString);

      // Validate structure
      if (!YahrtzeitLibrary.isValidJson(library.toJson())) {
        throw FormatException('Invalid file format');
      }

      // Load existing yahrtzeits to check for duplicates
      final existingYahrtzeits = await _manager.getAllYahrtzeits();

      // Import each yahrtzeit
      for (var yahrtzeit in library.yahrtzeits) {
        try {
          // Apply bulk group override if provided
          final groupToUse = bulkGroupOverride ?? yahrtzeit.group;
          final yahrtzeitToImport = Yahrtzeit(
            id: yahrtzeit.id,
            englishName: yahrtzeit.englishName,
            hebrewName: yahrtzeit.hebrewName,
            day: yahrtzeit.day,
            month: yahrtzeit.month,
            group: groupToUse,
          );

          // Check for duplicates (by ID or by name+date combination)
          final isDuplicate = existingYahrtzeits.any((existing) =>
              existing.id == yahrtzeitToImport.id ||
              (existing.englishName == yahrtzeitToImport.englishName &&
                  existing.hebrewName == yahrtzeitToImport.hebrewName &&
                  existing.day == yahrtzeitToImport.day &&
                  existing.month == yahrtzeitToImport.month));

          if (isDuplicate) {
            duplicateCount++;
            continue;
          }

          // Add to database
          // Note: Using default values for sync settings - user can sync later if needed
          await _manager.addYahrtzeit(
            yahrtzeitToImport,
            0, // yearsToSync - don't sync by default
            false, // syncSettings - don't sync by default
            notificationsEnabled: false, // don't enable notifications by default
            daysBefore: 10,
          );

          successCount++;
        } catch (e) {
          failureCount++;
          errors.add(
              'Failed to import ${yahrtzeit.englishName ?? yahrtzeit.hebrewName}: $e');
        }
      }

      return ImportResult(
        successCount: successCount,
        failureCount: failureCount,
        duplicateCount: duplicateCount,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        successCount: successCount,
        failureCount: failureCount + 1,
        duplicateCount: duplicateCount,
        errors: ['Failed to read or parse file: $e'],
      );
    }
  }
}
