class SyncResult {
  final bool success;
  final String message;
  final int count;

  SyncResult({
    required this.success,
    required this.message,
    required this.count,
  });

  SyncResult.failure(String message)
      : success = false,
        message = message,
        count = 0;

  SyncResult.success(int count, String message)
      : success = true,
        message = message,
        count = count;
}






