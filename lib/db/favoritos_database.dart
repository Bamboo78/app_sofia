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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favoritos(
            posicion INTEGER PRIMARY KEY,
            nombre TEXT,
            url TEXT,
            imagenPath TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migración de v1 a v2: cambiar de 'id' a 'posicion'
          // Obtener todos los favoritos antiguos
          final favoritos = await db.query('favoritos');
          
          // Crear tabla temporal con la nueva estructura
          await db.execute('''
            CREATE TABLE favoritos_new(
              posicion INTEGER PRIMARY KEY,
              nombre TEXT,
              url TEXT,
              imagenPath TEXT
            )
          ''');
          
          // Copiar datos antiguos asignando posiciones secuenciales
          for (var i = 0; i < favoritos.length; i++) {
            final fav = favoritos[i];
            await db.execute('''
              INSERT INTO favoritos_new(posicion, nombre, url, imagenPath)
              VALUES(?, ?, ?, ?)
            ''', [
              i + 1,
              fav['nombre'],
              fav['url'],
              fav['imagenPath']
            ]);
          }
          
          // Eliminar tabla antigua y renombrar la nueva
          await db.execute('DROP TABLE favoritos');
          await db.execute('ALTER TABLE favoritos_new RENAME TO favoritos');
        }
      },
    );
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('favoritos', data);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    // Obtener todos los favoritos ordenados por posición
    return await db.query('favoritos', orderBy: 'posicion');
  }

  static Future<Map<String, dynamic>?> getByPosicion(int posicion) async {
    final db = await database;
    final result = await db.query('favoritos', where: 'posicion = ?', whereArgs: [posicion]);
    return result.isEmpty ? null : result.first;
  }

  static Future<int> update(int posicion, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('favoritos', data, where: 'posicion = ?', whereArgs: [posicion]);
  }

  static Future<int> delete(int posicion) async {
    final db = await database;
    return await db.delete('favoritos', where: 'posicion = ?', whereArgs: [posicion]);
  }

  static Future<int> getNextAvailablePosicion() async {
    final db = await database;
    // Buscar la primera posición disponible (1-6)
    for (int i = 1; i <= 6; i++) {
      final result = await db.query('favoritos', where: 'posicion = ?', whereArgs: [i]);
      if (result.isEmpty) {
        return i;
      }
    }
    return -1; // No hay posiciones disponibles
  }
}
