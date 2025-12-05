import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gestantes/database/database_helper.dart';

class BackupService {
  static Future<void> exportBackup() async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final animals = await db.query('animals');
      final notes = await db.query('notes');
      final farms = await db.query('farms');

      final backup = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'animals': animals,
        'notes': notes,
        'farms': farms,
      };

      final jsonString = jsonEncode(backup);
      
      await Share.share(
        jsonString,
        subject: 'Backup Gestantes ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return false;

      final file = result.files.first;
      final bytes = await file.readStream!.toList();
      final content = String.fromCharCodes(bytes.expand((chunk) => chunk));
      final backup = jsonDecode(content) as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;

      // Limpiar tablas
      await db.delete('notes');
      await db.delete('animals');
      await db.delete('farms');

      // Insertar datos
      for (var farm in backup['farms'] as List) {
        await db.insert('farms', farm as Map<String, dynamic>);
      }
      for (var animal in backup['animals'] as List) {
        await db.insert('animals', animal as Map<String, dynamic>);
      }
      for (var note in backup['notes'] as List) {
        await db.insert('notes', note as Map<String, dynamic>);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
