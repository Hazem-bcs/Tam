import 'package:sqflite/sqflite.dart';
import 'package:tam_customer/core/cache/local_cache_store.dart';

/// Durable cache for non-sensitive read models. Not an offline booking queue.
final class SqliteCacheStore implements LocalCacheStore {
  Future<Database>? _database;

  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      '$directory/tam_cache.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache_entries (
            cache_key TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            fetched_at_ms INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<CachedPayload?> read(String key) async {
    final db = await database;
    final rows = await db.query(
      'cache_entries',
      columns: ['payload', 'fetched_at_ms'],
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CachedPayload(
      value: rows.first['payload']! as String,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(
        rows.first['fetched_at_ms']! as int,
        isUtc: true,
      ),
    );
  }

  @override
  Future<void> write(String key, String payload, DateTime fetchedAt) async {
    final db = await database;
    await db.insert('cache_entries', {
      'cache_key': key,
      'payload': payload,
      'fetched_at_ms': fetchedAt.toUtc().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> remove(String key) async {
    final db = await database;
    await db.delete('cache_entries', where: 'cache_key = ?', whereArgs: [key]);
  }

  @override
  Future<void> clear() async {
    final db = await database;
    await db.delete('cache_entries');
  }
}
