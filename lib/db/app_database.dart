import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/app_notification.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'geoquest.db');
    return openDatabase(
      path,
      version: 7,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE notifications(id TEXT PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL, receivedAt TEXT NOT NULL, type TEXT NOT NULL, read INTEGER NOT NULL DEFAULT 0)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE challenge_progress ADD COLUMN startedAt TEXT");
          await db.execute("ALTER TABLE challenge_progress ADD COLUMN lastRouteShownAt TEXT");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE users ADD COLUMN avatarPath TEXT");
        }
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE users ADD COLUMN lastCompletedDate TEXT");
        }
        if (oldVersion < 5) {
          await db.execute(
            'CREATE TABLE user_achievements(userId TEXT NOT NULL, achievementId TEXT NOT NULL, unlockedAt TEXT NOT NULL, PRIMARY KEY(userId, achievementId))',
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            'CREATE TABLE notifications(id TEXT PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL, receivedAt TEXT NOT NULL, type TEXT NOT NULL, read INTEGER NOT NULL DEFAULT 0)',
          );
        }
        if (oldVersion < 7) {
          // All user/challenge data now lives in Firestore exclusively.
          for (final table in ['users', 'challenges', 'achievements', 'leaderboard', 'challenge_progress', 'user_achievements']) {
            await db.execute('DROP TABLE IF EXISTS $table');
          }
        }
      },
    );
  }

  Future<void> resetForTest() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
    final path = p.join(await getDatabasesPath(), 'geoquest.db');
    await deleteDatabase(path);
  }

  Future<List<AppNotification>> loadNotifications() async {
    final db = await database;
    final rows = await db.query('notifications', orderBy: 'receivedAt DESC', limit: 50);
    return rows.map((r) => AppNotification(
      id: r['id'] as String,
      title: r['title'] as String,
      body: r['body'] as String,
      receivedAt: DateTime.parse(r['receivedAt'] as String),
      type: r['type'] as String,
      read: (r['read'] as int) == 1,
    )).toList();
  }

  Future<void> insertNotification(AppNotification n) async {
    final db = await database;
    await db.insert(
      'notifications',
      {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'receivedAt': n.receivedAt.toIso8601String(),
        'type': n.type,
        'read': n.read ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.execute(
      'DELETE FROM notifications WHERE id NOT IN (SELECT id FROM notifications ORDER BY receivedAt DESC LIMIT 50)',
    );
  }

  Future<void> markAllNotificationsRead() async {
    final db = await database;
    await db.update('notifications', {'read': 1});
  }
}
