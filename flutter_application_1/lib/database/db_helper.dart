import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper dbHelper =
      DBHelper._secretDBConstructor(); // Singleton instance
  static Database? _database;

  DBHelper._secretDBConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        alarmTime TEXT  // New field for alarm time
      )
    ''');
  }

  Future<int> insertDb(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('todo', row);
  }

  Future<List<Map<String, dynamic>>> readDb() async {
    Database db = await database;
    return await db.query('todo');
  }

  Future<int> updateDb(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('todo', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDb(int id) async {
    Database db = await database;
    return await db.delete('todo', where: 'id = ?', whereArgs: [id]);
  }
}
