import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gestantes/database/database_helper.dart';

class BackupService {
  static Future<Map<String, dynamic>> createBackup() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final animals = await db.query('animals');
      final notes = await db.query('notes');
      final farms = await db.query('farms');

      return {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'animals': animals,
        'notes': notes,
        'farms': farms,
      };
    } catch (e) {
      throw Exception('Error creando backup: $e');
    }
  }

  static Future<String> exportBackupAsJson() async {
    try {
      final backup = await createBackup();
      return jsonEncode(backup);
    } catch (e) {
      throw Exception('Error exportando backup: $e');
    }
  }

  static Future<bool> restoreFromJson(String jsonString) async {
    try {
      // Validar JSON
      if (jsonString.isEmpty) {
        throw Exception('JSON vacio');
      }

      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validar estructura
      if (!backup.containsKey('animals') ||
          !backup.containsKey('notes') ||
          !backup.containsKey('farms')) {
        throw Exception('Estructura JSON invalida');
      }

      final db = await DatabaseHelper.instance.database;

      // Usar transacción para atomicidad
      await db.transaction((txn) async {
        // Limpiar tablas
        await txn.delete('notes');
        await txn.delete('animals');
        await txn.delete('farms');

        // Insertar farms primero (foreign key)
        for (var farm in backup['farms'] as List) {
          try {
            await txn.insert('farms', farm as Map<String, dynamic>);
          } catch (e) {
            // Ignorar si ya existe
            debugPrint('Farm ya existe: $e');
          }
        }

        // Insertar animals
        for (var animal in backup['animals'] as List) {
          await txn.insert('animals', animal as Map<String, dynamic>);
        }

        // Insertar notes
        for (var note in backup['notes'] as List) {
          await txn.insert('notes', note as Map<String, dynamic>);
        }
      });

      return true;
    } catch (e) {
      throw Exception('Error restaurando backup: $e');
    }
  }

  static String generateBackupFileName() {
    final now = DateTime.now();
    return 'gestantes_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
  }

  static bool validateBackupJson(String jsonString) {
    try {
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;
      return backup.containsKey('animals') &&
          backup.containsKey('notes') &&
          backup.containsKey('farms') &&
          backup.containsKey('version');
    } catch (e) {
      return false;
    }
  }
}
