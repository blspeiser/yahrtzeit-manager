class SyncResult {
  final bool success;
  final String message;
  final int count;

  SyncResult({
    required this.success,
    required this.message,
    required this.count,
  });

  SyncResult.failure(this.message)
      : success = false,
        count = 0;

  SyncResult.success(this.count, this.message)
      : success = true;
}






