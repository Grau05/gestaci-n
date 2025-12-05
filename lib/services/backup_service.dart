import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:gestantes/database/database_helper.dart';

class BackupService {
  static Future<String> createBackup() async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Obtener todos los datos
      final animals = await db.query('animals');
      final notes = await db.query('notes');
      final farms = await db.query('farms');
      
      final backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'animals': animals,
        'notes': notes,
        'farms': farms,
      };
      
      // Guardar como JSON
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${backupDir.path}/$fileName');
      
      await file.writeAsString(jsonEncode(backup));
      return file.path;
    } catch (e) {
      throw Exception('Error en backup: $e');
    }
  }

  static Future<void> restoreBackup(File backupFile) async {
    try {
      final content = await backupFile.readAsString();
      final backup = jsonDecode(content);
      
      final db = await DatabaseHelper.instance.database;
      
      // Limpiar datos actuales
      await db.delete('notes');
      await db.delete('animals');
      await db.delete('farms');
      
      // Restaurar datos
      for (var farm in backup['farms']) {
        await db.insert('farms', farm);
      }
      for (var animal in backup['animals']) {
        await db.insert('animals', animal);
      }
      for (var note in backup['notes']) {
        await db.insert('notes', note);
      }
    } catch (e) {
      throw Exception('Error en restauracion: $e');
    }
  }

  static Future<List<File>> getBackups() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      return backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    } catch (e) {
      return [];
    }
  }
}
