import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactosDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contactos.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contactos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            telefono TEXT,
            imagenPath TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('contactos', data);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query('contactos');
  }

  static Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('contactos', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('contactos', where: 'id = ?', whereArgs: [id]);
  }
}
