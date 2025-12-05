import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gestantes/models/animal.dart';
import 'package:gestantes/models/note.dart';
import 'package:gestantes/models/farm.dart';

class DatabaseHelper {
  static const _databaseName = 'gestantes.db';
  static const _databaseVersion = 4;
  
  static const tableAnimals = 'animals';
  static const tableNotes = 'notes';
  static const tableFarms = 'farms';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de fincas
    await db.execute('''
      CREATE TABLE $tableFarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        ubicacion TEXT,
        encargado TEXT,
        fecha_registro TEXT NOT NULL
      )
    ''');

    // Tabla de animales
    await db.execute('''
      CREATE TABLE $tableAnimals (
        id_interno INTEGER PRIMARY KEY AUTOINCREMENT,
        id_visible TEXT NOT NULL,
        nombre TEXT,
        raza TEXT NOT NULL,
        meses_embarazo INTEGER NOT NULL,
        fecha_ultimo_palpado TEXT,
        fecha_monta TEXT,
        estado TEXT NOT NULL DEFAULT 'preñada',
        id_finca INTEGER NOT NULL DEFAULT 1,
        fecha_registro TEXT NOT NULL,
        etiquetas TEXT DEFAULT '',
        UNIQUE(id_visible, id_finca),
        FOREIGN KEY(id_finca) REFERENCES $tableFarms(id)
      )
    ''');

    // Tabla de notas
    await db.execute('''
      CREATE TABLE $tableNotes (
        id TEXT PRIMARY KEY,
        id_animal INTEGER NOT NULL,
        contenido TEXT NOT NULL,
        fecha TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'observacion',
        FOREIGN KEY(id_animal) REFERENCES $tableAnimals(id_interno)
      )
    ''');

    // Crear finca por defecto
    await db.insert(tableFarms, {
      'nombre': 'Finca Principal',
      'ubicacion': null,
      'encargado': null,
      'fecha_registro': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableFarms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL UNIQUE,
          ubicacion TEXT,
          encargado TEXT,
          fecha_registro TEXT NOT NULL
        )
      ''');

      try {
        await db.insert(tableFarms, {
          'nombre': 'Finca Principal',
          'ubicacion': null,
          'encargado': null,
          'fecha_registro': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Finca ya existe
      }

      final tableInfo = await db.rawQuery('PRAGMA table_info($tableAnimals)');
      final columnNames = tableInfo.map((col) => col['name']).toList();

      if (!columnNames.contains('fecha_monta')) {
        await db.execute('ALTER TABLE $tableAnimals ADD COLUMN fecha_monta TEXT');
      }
      if (!columnNames.contains('estado')) {
        await db.execute(
          'ALTER TABLE $tableAnimals ADD COLUMN estado TEXT NOT NULL DEFAULT \'preñada\'',
        );
      }
      if (!columnNames.contains('id_finca')) {
        await db.execute(
          'ALTER TABLE $tableAnimals ADD COLUMN id_finca INTEGER NOT NULL DEFAULT 1',
        );
      }
      if (!columnNames.contains('fecha_registro')) {
        await db.execute(
          'ALTER TABLE $tableAnimals ADD COLUMN fecha_registro TEXT NOT NULL DEFAULT \'${DateTime.now().toIso8601String()}\'',
        );
      }
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableNotes (
          id TEXT PRIMARY KEY,
          id_animal INTEGER NOT NULL,
          contenido TEXT NOT NULL,
          fecha TEXT NOT NULL,
          tipo TEXT NOT NULL DEFAULT 'observacion',
          FOREIGN KEY(id_animal) REFERENCES $tableAnimals(id_interno)
        )
      ''');
    }

    if (oldVersion < 4) {
      final tableInfo = await db.rawQuery('PRAGMA table_info($tableAnimals)');
      final columnNames = tableInfo.map((col) => col['name']).toList();

      if (!columnNames.contains('etiquetas')) {
        await db.execute(
          'ALTER TABLE $tableAnimals ADD COLUMN etiquetas TEXT DEFAULT \'\'',
        );
      }
    }
  }

  // ===== FARMS =====
  Future<int> insertFarm(Farm farm) async {
    final db = await database;
    return await db.insert(tableFarms, farm.toMap());
  }

  Future<List<Farm>> getAllFarms() async {
    final db = await database;
    final result = await db.query(tableFarms, orderBy: 'fecha_registro DESC');
    return result.map((map) => Farm.fromMap(map)).toList();
  }

  Future<int> updateFarm(Farm farm) async {
    final db = await database;
    return await db.update(
      tableFarms,
      farm.toMap(),
      where: 'id = ?',
      whereArgs: [farm.id],
    );
  }

  Future<int> deleteFarm(int id) async {
    final db = await database;
    return await db.delete(tableFarms, where: 'id = ?', whereArgs: [id]);
  }

  // ===== NOTES =====
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(tableNotes, note.toMap());
  }

  Future<List<Note>> getNotesByAnimal(int idAnimal) async {
    final db = await database;
    final result = await db.query(
      tableNotes,
      where: 'id_animal = ?',
      whereArgs: [idAnimal],
      orderBy: 'fecha DESC',
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> deleteNote(String noteId) async {
    final db = await database;
    return await db.delete(tableNotes, where: 'id = ?', whereArgs: [noteId]);
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // CRUD Operations
  Future<int> insertAnimal(Animal animal) async {
    final db = await database;
    return await db.insert(tableAnimals, animal.toMap());
  }

  Future<List<Animal>> getAllAnimalsByFarm(int idFinca) async {
    final db = await database;
    final result = await db.query(
      tableAnimals,
      where: 'id_finca = ?',
      whereArgs: [idFinca],
      orderBy: 'id_visible ASC',
    );
    return result.map((map) => Animal.fromMap(map)).toList();
  }

  Future<Animal?> getAnimalById(int idInterno) async {
    final db = await database;
    final result = await db.query(
      tableAnimals,
      where: 'id_interno = ?',
      whereArgs: [idInterno],
    );
    if (result.isEmpty) return null;
    return Animal.fromMap(result.first);
  }

  Future<Animal?> getAnimalByVisibleId(String idVisible, int idFinca) async {
    final db = await database;
    final result = await db.query(
      tableAnimals,
      where: 'id_visible = ? AND id_finca = ?',
      whereArgs: [idVisible, idFinca],
    );
    if (result.isEmpty) return null;
    return Animal.fromMap(result.first);
  }

  Future<int> updateAnimal(Animal animal) async {
    final db = await database;
    return await db.update(
      tableAnimals,
      animal.toMap(),
      where: 'id_interno = ?',
      whereArgs: [animal.idInterno],
    );
  }

  Future<int> deleteAnimal(int idInterno) async {
    final db = await database;
    // Eliminar notas asociadas
    await db.delete(tableNotes, where: 'id_animal = ?', whereArgs: [idInterno]);
    return await db.delete(
      tableAnimals,
      where: 'id_interno = ?',
      whereArgs: [idInterno],
    );
  }

  Future<void> deleteAllAnimals() async {
    final db = await database;
    await db.delete(tableAnimals);
  }
}
