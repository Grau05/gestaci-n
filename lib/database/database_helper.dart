import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gestantes/models/animal.dart';

class DatabaseHelper {
  static const _databaseName = 'gestantes.db';
  static const _databaseVersion = 1;
  static const tableAnimals = 'animals';

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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAnimals (
        id_interno INTEGER PRIMARY KEY AUTOINCREMENT,
        id_visible TEXT NOT NULL UNIQUE,
        nombre TEXT,
        raza TEXT NOT NULL,
        meses_embarazo INTEGER NOT NULL,
        fecha_ultimo_palpado TEXT
      )
    ''');
  }

  // CRUD Operations
  Future<int> insertAnimal(Animal animal) async {
    final db = await database;
    return await db.insert(tableAnimals, animal.toMap());
  }

  Future<List<Animal>> getAllAnimals() async {
    final db = await database;
    final result = await db.query(tableAnimals);
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

  Future<Animal?> getAnimalByVisibleId(String idVisible) async {
    final db = await database;
    final result = await db.query(
      tableAnimals,
      where: 'id_visible = ?',
      whereArgs: [idVisible],
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
