import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  //щоб не створювати нові об'єкти
  factory DatabaseHelper() => _instance;
  //приватний констр
  DatabaseHelper._internal();
  // Cтворення БД
  static Database? _database;

  //Ініціалізація або звернення до БД
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //Створення бд
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'notes.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertNote(String text) async {
    //отримання бд
    final db = await database;
    //додаваня запису
    return await db.insert(
      'notes',
      {'text': text, 'created_at': DateTime.now().toIso8601String()},
      //якщо id уже то заміна
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //список нотаток + orderBy сортує за LIFO
  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }
}
