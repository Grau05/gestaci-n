import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'backup_service.dart';

class BackupFileService {
  static Future<File> saveBackupToFile(String backupJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = BackupService.generateBackupFileName();
    final file = File('${directory.path}/$fileName');
    return file.writeAsString(backupJson);
  }

  static Future<String?> pickBackupFileAndRead() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    return file.readAsString();
  }

  static Future<void> shareBackupFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Backup de Gestantes');
  }
}
