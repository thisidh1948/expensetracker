class BackupMetadata {
  final String id;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;

  BackupMetadata({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
  });
}
