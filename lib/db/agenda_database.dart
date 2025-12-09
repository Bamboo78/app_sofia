import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AgendaDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('agenda.db');
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
          CREATE TABLE agenda(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            desc TEXT,
            fecha TEXT,
            hora TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE agenda ADD COLUMN fecha TEXT');
          await db.execute('ALTER TABLE agenda ADD COLUMN hora TEXT');
        }
      },
    );
  }

  static Future<int> insert(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('agenda', data);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    final results = await db.query('agenda');
    
    // Ordenar por fecha y hora de forma cronológica
    results.sort((a, b) {
      final fechaA = a['fecha'] as String? ?? '';
      final horaA = a['hora'] as String? ?? '00:00';
      final fechaB = b['fecha'] as String? ?? '';
      final horaB = b['hora'] as String? ?? '00:00';
      
      // Convertir DD/MM/YYYY a comparable format
      final dateTimeA = _parseDateTime(fechaA, horaA);
      final dateTimeB = _parseDateTime(fechaB, horaB);
      
      return dateTimeA.compareTo(dateTimeB);
    });
    
    return results;
  }

  static DateTime _parseDateTime(String fecha, String hora) {
    try {
      if (fecha.isEmpty) return DateTime(2100); // Sin fecha al final
      
      final partesFecha = fecha.split('/');
      final partesHora = hora.split(':');
      
      final day = int.parse(partesFecha[0]);
      final month = int.parse(partesFecha[1]);
      final year = int.parse(partesFecha[2]);
      final hour = int.parse(partesHora[0]);
      final minute = int.parse(partesHora.length > 1 ? partesHora[1] : '0');
      
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime(2100); // En caso de error
    }
  }

  static Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('agenda', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('agenda', where: 'id = ?', whereArgs: [id]);
  }
}