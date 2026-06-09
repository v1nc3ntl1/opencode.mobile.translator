import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/translation_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'translator.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE translation_records (
        id TEXT PRIMARY KEY,
        sourceText TEXT NOT NULL,
        translatedText TEXT NOT NULL,
        sourceLanguage TEXT NOT NULL,
        targetLanguage TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        accessedAt TEXT NOT NULL,
        sourceType TEXT NOT NULL DEFAULT 'manual',
        isFavorite INTEGER NOT NULL DEFAULT 0,
        confidenceScore REAL NOT NULL DEFAULT 1.0
      )
    ''');

    await db.execute('''
      CREATE TABLE ocr_sessions (
        id TEXT PRIMARY KEY,
        imagePath TEXT NOT NULL,
        rawOcrText TEXT NOT NULL DEFAULT '',
        detectedLanguage TEXT NOT NULL DEFAULT '',
        confidence REAL NOT NULL DEFAULT 0.0,
        capturedAt TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE audio_cache (
        id TEXT PRIMARY KEY,
        textHash TEXT NOT NULL UNIQUE,
        textContent TEXT NOT NULL,
        audioFilePath TEXT NOT NULL,
        voiceId TEXT NOT NULL,
        durationMs REAL NOT NULL,
        generatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE offline_models (
        modelId TEXT PRIMARY KEY,
        modelType TEXT NOT NULL,
        languageCode TEXT NOT NULL,
        version TEXT NOT NULL,
        sizeMb REAL NOT NULL,
        isDownloaded INTEGER NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertTranslationRecord(TranslationRecord record) async {
    final db = await database;
    await db.insert(
      'translation_records',
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TranslationRecord>> getTranslationRecords({
    int limit = 50,
    int offset = 0,
    String? sourceType,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;
    if (sourceType != null) {
      where = 'sourceType = ?';
      whereArgs = [sourceType];
    }
    final maps = await db.query(
      'translation_records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => TranslationRecord.fromJson(m)).toList();
  }

  Future<void> updateFavorite(String id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'translation_records',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTranslationRecord(String id) async {
    final db = await database;
    await db.delete('translation_records', where: 'id = ?', whereArgs: [id]);
  }
}
