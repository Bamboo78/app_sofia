import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MedicacionDatabase {
  static final MedicacionDatabase _instance = MedicacionDatabase._internal();
  static Database? _database;

  factory MedicacionDatabase() {
    return _instance;
  }

  MedicacionDatabase._internal();

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicacion.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicacion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            hora TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insert(Map<String, dynamic> medicacion) async {
    final db = await database;
    await db.insert('medicacion', medicacion);
  }

  static Future<void> update(int id, Map<String, dynamic> medicacion) async {
    final db = await database;
    await db.update('medicacion', medicacion, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('medicacion', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query('medicacion', orderBy: 'hora ASC');
  }

  static Future<Map<String, dynamic>?> getById(int id) async {
    final db = await database;
    final result = await db.query('medicacion', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> deleteAll() async {
    final db = await database;
    await db.delete('medicacion');
  }
}
