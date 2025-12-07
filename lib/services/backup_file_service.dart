import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'backup_service.dart';

class BackupFileService {
  static Future<File> saveBackupToFile(String backupJson) async {
    final fileName = BackupService.generateBackupFileName();

    // En Android/iOS guardamos en la carpeta de documentos de la app
    // y luego el usuario puede compartir el archivo (WhatsApp, Drive, etc.).
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      return file.writeAsString(backupJson);
    }

    // En escritorio se puede usar el diálogo de "Guardar como"
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar backup de Gestantes',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path == null) {
      throw Exception('Guardado cancelado por el usuario');
    }

    final file = File(path);
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
