import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'mahasiswa';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'mahasiswa.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        if (await _isTableExist(db, tableName)) {
          print('$tableName sudah ada, tidak perlu membuat ulang.');
        } else {
          await db.execute('''
            CREATE TABLE $tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama TEXT,
              nim TEXT,
              prodi TEXT,
              nilaiTugas REAL,
              nilaiUTS REAL,
              nilaiUAS REAL,
              nilaiAkhir REAL
            )
          ''');
          print('$tableName berhasil dibuat.');
        }
      },
    );
  }

  Future<bool> _isTableExist(Database db, String tableName) async {
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }

  Future<void> insertMahasiswa(Map<String, dynamic> mahasiswaData) async {
    final db = await database;
    await db.insert(tableName, mahasiswaData);
  }

  Future<List<Map<String, dynamic>>> getMahasiswaList() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<void> updateMahasiswa(
      Map<String, dynamic> mahasiswaData, int id) async {
    final db = await database;
    await db.update(tableName, mahasiswaData, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMahasiswa(int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
