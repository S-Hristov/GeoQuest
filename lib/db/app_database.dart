import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../data/mock_geoquest_data.dart';
import '../models/geo_models.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'geoquest.db');
    return openDatabase(
      path,
      version: 5,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT NOT NULL, initials TEXT NOT NULL, email TEXT NOT NULL, level INTEGER NOT NULL, points INTEGER NOT NULL, nextLevelPoints INTEGER NOT NULL, completed INTEGER NOT NULL, badges INTEGER NOT NULL, bestStreak INTEGER NOT NULL, currentStreak INTEGER NOT NULL, googleId TEXT, avatarPath TEXT, lastCompletedDate TEXT)',
        );
        await db.execute(
          'CREATE TABLE challenges(id TEXT PRIMARY KEY, title TEXT NOT NULL, location TEXT NOT NULL, description TEXT NOT NULL, imageAsset TEXT NOT NULL, distanceKm REAL NOT NULL, points INTEGER NOT NULL, duration TEXT NOT NULL, difficulty TEXT NOT NULL, category TEXT NOT NULL, latitude REAL NOT NULL, longitude REAL NOT NULL, explorersCompleted INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE achievements(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, subtitle TEXT NOT NULL, icon TEXT NOT NULL, progress INTEGER NOT NULL, total INTEGER NOT NULL, unlocked TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE leaderboard(rank INTEGER PRIMARY KEY, name TEXT NOT NULL, initials TEXT NOT NULL, level INTEGER NOT NULL, completed INTEGER NOT NULL, points INTEGER NOT NULL, color INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE challenge_progress(userId TEXT NOT NULL, challengeId TEXT NOT NULL, status TEXT NOT NULL, startedAt TEXT, completedAt TEXT, lastRouteShownAt TEXT, proofPath TEXT, PRIMARY KEY(userId, challengeId))',
        );
        await db.execute(
          'CREATE TABLE user_achievements(userId TEXT NOT NULL, achievementId TEXT NOT NULL, unlockedAt TEXT NOT NULL, PRIMARY KEY(userId, achievementId))',
        );
        await seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE challenge_progress ADD COLUMN startedAt TEXT",
          );
          await db.execute(
            "ALTER TABLE challenge_progress ADD COLUMN lastRouteShownAt TEXT",
          );
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE users ADD COLUMN avatarPath TEXT");
        }
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE users ADD COLUMN lastCompletedDate TEXT",
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            'CREATE TABLE user_achievements(userId TEXT NOT NULL, achievementId TEXT NOT NULL, unlockedAt TEXT NOT NULL, PRIMARY KEY(userId, achievementId))',
          );
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

  Future<void> seed(Database db) async {
    await db.insert(
      'users',
      _userMap(currentUser),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final c in challenges) {
      await db.insert(
        'challenges',
        _challengeMap(c),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final e in leaderboard) {
      await db.insert(
        'leaderboard',
        _leaderboardMap(e),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Map<String, Object?> _userMap(UserProfile u) => {
    'id': 'local-user',
    'name': u.name,
    'initials': u.initials,
    'email': u.email,
    'level': u.level,
    'points': u.points,
    'nextLevelPoints': u.nextLevelPoints,
    'completed': u.completed,
    'badges': u.badges,
    'bestStreak': u.bestStreak,
    'currentStreak': u.currentStreak,
    'googleId': null,
    'avatarPath': u.avatarPath,
    'lastCompletedDate': u.lastCompletedDate?.toIso8601String(),
  };
  Map<String, Object?> _challengeMap(Challenge c) => {
    'id': c.id,
    'title': c.title,
    'location': c.location,
    'description': c.description,
    'imageAsset': c.imageAsset,
    'distanceKm': c.distanceKm,
    'points': c.points,
    'duration': c.duration,
    'difficulty': c.difficulty.name,
    'category': c.category,
    'latitude': c.latitude,
    'longitude': c.longitude,
    'explorersCompleted': c.explorersCompleted,
  };
  Map<String, Object?> _leaderboardMap(LeaderboardEntry e) => {
    'rank': e.rank,
    'name': e.name,
    'initials': e.initials,
    'level': e.level,
    'completed': e.completed,
    'points': e.points,
    'color': e.color.toARGB32(),
  };
}
