import 'package:sembast/sembast_memory.dart';
import '../models/translation_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await databaseFactoryMemory.openDatabase('translator.db');
    return _database!;
  }

  StoreRef<String, Map<String, dynamic>> get _store =>
      stringMapStoreFactory.store('translation_records');

  Future<void> insertTranslationRecord(TranslationRecord record) async {
    final db = await database;
    await _store.record(record.id).put(db, record.toJson());
  }

  Future<List<TranslationRecord>> getTranslationRecords({
    int limit = 50,
    int offset = 0,
    String? sourceType,
  }) async {
    final db = await database;
    final finder = Finder(
      limit: limit,
      offset: offset,
      filter: sourceType != null
          ? Filter.equals('sourceType', sourceType)
          : null,
    );
    final records = await _store.find(db, finder: finder);
    return records.map((r) => TranslationRecord.fromJson(r.value)).toList();
  }

  Future<void> updateFavorite(String id, bool isFavorite) async {
    final db = await database;
    await _store.record(id).update(db, {'isFavorite': isFavorite ? 1 : 0});
  }

  Future<void> deleteTranslationRecord(String id) async {
    final db = await database;
    await _store.record(id).delete(db);
  }
}
