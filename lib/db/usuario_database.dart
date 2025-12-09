import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UsuarioDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('usuario.db');
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
          CREATE TABLE usuario(
            id INTEGER PRIMARY KEY,
            nombre TEXT,
            telefono TEXT,
            direccion TEXT,
            nombreContacto TEXT,
            telefonoContacto TEXT,
            imagenPath TEXT
          )
        ''');
      },
    );
  }

  // Obtener datos del usuario (siempre un único registro con id=1)
  static Future<Map<String, dynamic>?> getUsuario() async {
    final db = await database;
    final result = await db.query('usuario', where: 'id = ?', whereArgs: [1]);
    return result.isNotEmpty ? result.first : null;
  }

  // Guardar o actualizar datos del usuario
  static Future<void> saveUsuario(Map<String, dynamic> data) async {
    final db = await database;
    final usuario = await getUsuario();
    
    if (usuario == null) {
      // Insertar nuevo usuario con id=1
      await db.insert('usuario', {...data, 'id': 1});
    } else {
      // Actualizar usuario existente
      await db.update('usuario', data, where: 'id = ?', whereArgs: [1]);
    }
  }
}
