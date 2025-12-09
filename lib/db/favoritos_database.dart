import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavoritosDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favoritos.db');
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
          CREATE TABLE favoritos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            url TEXT,
            imagenPath TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('favoritos', data);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query('favoritos');
  }

  static Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('favoritos', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('favoritos', where: 'id = ?', whereArgs: [id]);
  }
}
