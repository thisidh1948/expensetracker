import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';
import '../database/database_helper.dart';
import '../database/models/backup_metadata.dart';


class BackupService {
  final GoogleSignIn _googleSignIn;
  final DatabaseHelper _databaseHelper;
  static const String backupFolderName = 'ExpenseTrackerBackups';

  BackupService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'https://www.googleapis.com/auth/drive.file',
                'https://www.googleapis.com/auth/drive.appdata',
              ],
            ),
        _databaseHelper = DatabaseHelper();

  Future<String> createBackup() async {
    Database? db;
    try {
      // Get database instance
      db = await _databaseHelper.database;

      // Create backup
      final backupFile = await _createBackupZip();
      final driveFile = await _uploadToDrive(backupFile);
      await backupFile.delete();

      return driveFile.id ?? 'Backup ID not found';
    } catch (e) {
      throw Exception('Backup failed: $e');
    }
  }

  Future<File> _createBackupZip() async {
    try {
      final archive = Archive();

      // Get database file path
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'expense_tracker.db'));

      print('Database path: ${dbFile.path}'); // Debug print

      if (!await dbFile.exists()) {
        throw Exception('Database file not found at: ${dbFile.path}');
      }

      // Add database to archive
      final dbBytes = await dbFile.readAsBytes();
      archive.addFile(ArchiveFile('database.db', dbBytes.length, dbBytes));

      // Create zip file
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) throw Exception('Failed to create zip archive');

      final tempDir = await getTemporaryDirectory();
      final backupFile = File(
        join(tempDir.path,
            'backup_${DateTime.now().millisecondsSinceEpoch}.zip'),
      );

      await backupFile.writeAsBytes(zipBytes);
      return backupFile;
    } catch (e) {
      throw Exception('Failed to create backup zip: $e');
    }
  }

  Future<drive.File> _uploadToDrive(File backupFile) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Sign in cancelled');

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null)
        throw Exception('Failed to get authenticated client');

      final driveApi = drive.DriveApi(httpClient);

      // Get or create backup folder
      final folderId = await _getOrCreateBackupFolder(driveApi);

      // Create drive file
      final driveFile = drive.File()
        ..name = 'backup_${DateTime.now().toIso8601String()}.zip'
        ..parents = [folderId];

      // Upload file
      return await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(
          backupFile.openRead(),
          await backupFile.length(),
        ),
      );
    } catch (e) {
      throw Exception('Upload to Drive failed: $e');
    }
  }

  Future<String> _getOrCreateBackupFolder(drive.DriveApi driveApi) async {
    try {
      final folderList = await driveApi.files.list(
        q: "name='$backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      if (folderList.files?.isNotEmpty ?? false) {
        return folderList.files!.first.id!;
      }

      final folder = drive.File()
        ..name = backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folder);
      return createdFolder.id!;
    } catch (e) {
      throw Exception('Failed to get/create backup folder: $e');
    }
  }

  Future<List<BackupMetadata>> listBackups() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Sign in cancelled');

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null)
        throw Exception('Failed to get authenticated client');

      final driveApi = drive.DriveApi(httpClient);

      final folderId = await _getOrCreateBackupFolder(driveApi);
      final fileList = await driveApi.files.list(
        q: "'$folderId' in parents and trashed=false",
        orderBy: 'createdTime desc',
      );

      return fileList.files
              ?.map((file) => BackupMetadata(
                    id: file.id ?? '',
                    name: file.name ?? '',
                    createdAt: file.createdTime ?? DateTime.now(),
                    sizeBytes: int.tryParse(file.size ?? '0') ?? 0,
                  ))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to list backups: $e');
    }
  }

  Future<void> restoreBackup(String backupId) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Sign in cancelled');

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null)
        throw Exception('Failed to get authenticated client');

      final driveApi = drive.DriveApi(httpClient);

      // Close database before restore
      final db = await _databaseHelper.database;
      if (db != null) {}

      // Download backup
      final media = await driveApi.files.get(
        backupId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(join(tempDir.path, 'temp_backup.zip'));

      // Convert stream to bytes
      final List<int> dataBytes = [];
      await for (final data in media.stream) {
        dataBytes.addAll(data);
      }

      await tempFile.writeAsBytes(dataBytes);

      // Restore from zip
      await _restoreFromZip(tempFile);
      await tempFile.delete();

      // Reopen database
      await _databaseHelper.database;
    } catch (e) {
      // Ensure database is reopened even if restore fails
      await _databaseHelper.database;
      throw Exception('Restore failed: $e');
    }
  }

  Future<void> _restoreFromZip(File zipFile) async {
    try {
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          if (file.name == 'database.db') {
            final dbPath = await getDatabasesPath();
            final dbFile = File(join(dbPath, 'expense_tracker.db'));
            await dbFile.writeAsBytes(data);
          } else if (file.name == 'prefs.json') {
            final prefsFile = await _getSharedPreferencesFile();
            if (prefsFile != null) {
              await prefsFile.writeAsBytes(data);
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to restore from zip: $e');
    }
  }

  Future<File?> _getSharedPreferencesFile() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final prefsFile = File(
          join(appDir.path, 'shared_prefs', 'FlutterSharedPreferences.json'));
      return prefsFile;
    } catch (e) {
      print('Failed to get shared preferences file: $e');
      return null;
    }
  }
}
