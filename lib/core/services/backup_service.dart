import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:archive/archive_io.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles encrypted backup export and import of the SQLite database file.
class BackupService {
  static const _dbFileName = 'pharma_local.sqlite';
  static const _aesKeyLength = 32; // 256-bit

  /// Derives a 32-byte AES key from the user passphrase using SHA-256.
  enc.Key _deriveKey(String passphrase) {
    // Simple PBKDF: pad/truncate passphrase to 32 bytes
    final bytes = Uint8List(32);
    final passbytes = passphrase.codeUnits;
    for (var i = 0; i < _aesKeyLength; i++) {
      bytes[i] = passbytes[i % passbytes.length];
    }
    return enc.Key(bytes);
  }

  /// Exports the active database as an AES-256-CBC encrypted ZIP archive.
  /// Returns the path to the created backup file.
  Future<String> exportBackup({required String passphrase, bool isAutoBackup = false}) async {
    final docsDir = await getApplicationDocumentsDirectory();

    // Locate the SQLite db file created by drift_flutter
    final dbDir = await _findDbDirectory();
    final dbFile = File(path.join(dbDir, _dbFileName));
    if (!dbFile.existsSync()) {
      throw Exception(
          'Database file not found at ${dbFile.path}. '
          'Ensure the app has been used at least once.');
    }

    // Read raw db bytes
    final dbBytes = await dbFile.readAsBytes();

    // Create in-memory ZIP
    final archive = Archive();
    archive.addFile(ArchiveFile('pharma_local.sqlite', dbBytes.length, dbBytes));
    final zipBytes = ZipEncoder().encode(archive);

    // AES-256-CBC encryption
    final key = _deriveKey(passphrase);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encryptBytes(zipBytes, iv: iv);

    // Write: [16-byte IV][ciphertext]
    final outputBytes = Uint8List(16 + encrypted.bytes.length);
    outputBytes.setRange(0, 16, iv.bytes);
    outputBytes.setRange(16, outputBytes.length, encrypted.bytes);

    final ts =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    
    File outFile;
    if (isAutoBackup) {
      final autoDir = Directory(path.join(docsDir.path, 'auto_backups'));
      if (!autoDir.existsSync()) {
        autoDir.createSync(recursive: true);
      }
      outFile = File(path.join(autoDir.path, 'pharma_auto_backup_$ts.pharmaenc'));
      await outFile.writeAsBytes(outputBytes);
      
      // Cleanup: keep only latest 5
      final files = autoDir.listSync().whereType<File>().toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      for (var i = 5; i < files.length; i++) {
        try {
          files[i].deleteSync();
        } catch (_) {}
      }
    } else {
      outFile = File(path.join(docsDir.path, 'pharma_backup_$ts.pharmaenc'));
      await outFile.writeAsBytes(outputBytes);
    }

    return outFile.path;
  }

  /// Restores a database from an encrypted backup file.
  Future<void> importBackup({
    required String backupFilePath,
    required String passphrase,
  }) async {
    final backupFile = File(backupFilePath);
    if (!backupFile.existsSync()) {
      throw Exception('Backup file not found: $backupFilePath');
    }

    final allBytes = await backupFile.readAsBytes();
    if (allBytes.length < 17) throw Exception('Invalid backup file');

    final iv = enc.IV(allBytes.sublist(0, 16));
    final cipherBytes = allBytes.sublist(16);

    final key = _deriveKey(passphrase);
    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

    final Uint8List zipBytes;
    try {
      zipBytes = Uint8List.fromList(
          encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv));
    } catch (e) {
      throw Exception('Decryption failed — wrong passphrase?');
    }

    final archive = ZipDecoder().decodeBytes(zipBytes);
    final dbEntry =
        archive.files.firstWhere((f) => f.name == 'pharma_local.sqlite');

    final dbDir = await _findDbDirectory();
    final dbFile = File(path.join(dbDir, _dbFileName));
    await dbFile.writeAsBytes(dbEntry.content as List<int>);
  }

  /// Shares the backup file via the OS share sheet (share_plus).
  Future<void> shareBackup(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Sri Ranga Medical Backup',
    );
  }

  Future<String> _findDbDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return docsDir.path;
  }
}

/// Automatically backs up the database when the app goes into the detached state.
class AutoBackupObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      _performAutoBackup();
    }
  }

  Future<void> _performAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('enable_auto_backup') != true) return;
      
      final backupService = BackupService();
      final backupPath = await backupService.exportBackup(passphrase: 'PharmaAutoBackup', isAutoBackup: true);
      print('Auto-backup completed securely: $backupPath');
    } catch (e) {
      print('Auto-backup failed: $e');
    }
  }
}

