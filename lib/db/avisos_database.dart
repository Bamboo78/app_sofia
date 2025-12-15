import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class AvisosDatabase {
  static final AvisosDatabase _instance = AvisosDatabase._internal();
  static Database? _database;

  factory AvisosDatabase() {
    return _instance;
  }

  AvisosDatabase._internal();

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'avisos.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE avisos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombreContacto TEXT NOT NULL,
            telefonoContacto TEXT NOT NULL,
            mensaje TEXT NOT NULL,
            horaInicio TEXT NOT NULL,
            horaFinal TEXT NOT NULL,
            intervalo INTEGER NOT NULL,
            activado INTEGER NOT NULL DEFAULT 0,
            lastUsedTime TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Agregar la columna lastUsedTime si no existe
          try {
            await db.execute('ALTER TABLE avisos ADD COLUMN lastUsedTime TEXT');
          } catch (e) {
            // Columna ya existe
          }
        }
      },
    );
  }

  static Future<void> insert(Map<String, dynamic> aviso) async {
    final db = await database;
    await db.insert('avisos', aviso);
  }

  static Future<void> update(int id, Map<String, dynamic> aviso) async {
    final db = await database;
    await db.update('avisos', aviso, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('avisos', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateLastUsedTime(int id) async {
    final db = await database;
    await db.update(
      'avisos',
      {'lastUsedTime': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query('avisos');
  }

  static Future<Map<String, dynamic>?> getById(int id) async {
    final db = await database;
    final result = await db.query('avisos', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getActivados() async {
    final db = await database;
    return await db.query('avisos', where: 'activado = ?', whereArgs: [1]);
  }

  static Future<void> enviarMensajeWhatsApp(String telefono, String mensaje) async {
    try {
      // Remover caracteres especiales del teléfono
      String telefonoLimpio = telefono.replaceAll(RegExp(r'[^\d]'), '');
      
      // Asegurarse de que tenga código de país
      if (!telefonoLimpio.startsWith('+')) {
        // Si no tiene +, asumir código de país español (+34)
        if (telefonoLimpio.startsWith('0')) {
          telefonoLimpio = telefonoLimpio.substring(1);
        }
        if (!telefonoLimpio.startsWith('34') && !telefonoLimpio.startsWith('1')) {
          telefonoLimpio = '34$telefonoLimpio';
        }
      }
      
      // URL de WhatsApp
      final whatsappUrl = Uri.parse(
        'https://wa.me/$telefonoLimpio?text=${Uri.encodeComponent(mensaje)}',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Error en envío de WhatsApp
    }
  }
}
