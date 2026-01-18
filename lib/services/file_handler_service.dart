import 'package:flutter/services.dart';

class FileHandlerService {
  static const MethodChannel _channel =
      MethodChannel('com.yahrtzeit.manager/file_handler');

  /// Checks if the app was opened with a file
  /// Returns the file path if available, null otherwise
  Future<String?> getInitialFile() async {
    try {
      final result = await _channel.invokeMethod<String>('getInitialFile');
      return result;
    } on PlatformException catch (e) {
      return null;
    }
  }

  /// Gets file path from platform intent (for when app is already running)
  /// Returns the file path if available, null otherwise
  Future<String?> getFileFromIntent() async {
    try {
      final result = await _channel.invokeMethod<String>('getFileFromIntent');
      return result;
    } on PlatformException catch (e) {
      return null;
    }
  }
}
