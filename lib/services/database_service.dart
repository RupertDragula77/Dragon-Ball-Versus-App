import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/character.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'dragonball.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE characters(
            id INTEGER PRIMARY KEY,
            name TEXT,
            ki TEXT,
            maxKi TEXT,
            race TEXT,
            gender TEXT,
            description TEXT,
            image TEXT,
            affiliation TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE highscore(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            score INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveCharacters(List<Character> characters) async {
    final db = await database;
    final batch = db.batch();
    for (var c in characters) {
      batch.insert(
        'characters',
        c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Character>> getCachedCharacters() async {
    final db = await database;
    final maps = await db.query('characters');
    return maps.map((m) => Character.fromMap(m)).toList();
  }

  Future<void> saveHighscore(int score) async {
    final db = await database;
    await db.insert('highscore', {
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getBestHighscore() async {
    final db = await database;
    final result = await db.query(
      'highscore',
      orderBy: 'score DESC',
      limit: 1,
    );
    if (result.isEmpty) return 0;
    return result.first['score'] as int;
  }
}