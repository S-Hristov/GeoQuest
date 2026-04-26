import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../domain/achievement_catalog.dart';
import '../domain/progression.dart';
import '../models/geo_models.dart';

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

int _dayDiff(DateTime previous, DateTime next) =>
    _startOfDay(next).difference(_startOfDay(previous)).inDays;

({int currentStreak, int bestStreak, String lastCompletedDate}) _nextStreak({
  required DateTime now,
  required int currentStreak,
  required int bestStreak,
  required String? lastCompletedDate,
}) {
  final previous = lastCompletedDate == null
      ? null
      : DateTime.tryParse(lastCompletedDate);
  final nextDate = _startOfDay(now);
  var nextCurrent = currentStreak;
  if (previous == null) {
    nextCurrent = currentStreak > 0 ? currentStreak : 1;
  } else {
    final diff = _dayDiff(previous, now);
    if (diff <= 0) {
      nextCurrent = currentStreak > 0 ? currentStreak : 1;
    } else if (diff == 1) {
      nextCurrent = currentStreak + 1;
    } else {
      nextCurrent = 1;
    }
  }
  final nextBest = nextCurrent > bestStreak ? nextCurrent : bestStreak;
  return (
    currentStreak: nextCurrent,
    bestStreak: nextBest,
    lastCompletedDate: nextDate.toIso8601String(),
  );
}

String _normalizedCategory(String value) {
  final lower = value.trim().toLowerCase();
  return switch (lower) {
    'culture' || 'cultural' => 'cultural',
    'nature' => 'nature',
    'historical' || 'history' => 'historical',
    'adventure' => 'adventure',
    _ => lower,
  };
}

String _formatUnlockedDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

class GeoRepository {
  GeoRepository(this.db);
  final AppDatabase db;

  Future<UserProfile> currentUser() async {
    final rows = await (await db.database).query('users', limit: 1);
    final r = rows.first;
    return UserProfile(
      name: r['name'] as String,
      initials: r['initials'] as String,
      level: r['level'] as int,
      points: r['points'] as int,
      nextLevelPoints: r['nextLevelPoints'] as int,
      completed: r['completed'] as int,
      badges: r['badges'] as int,
      bestStreak: r['bestStreak'] as int,
      currentStreak: r['currentStreak'] as int,
      email: r['email'] as String,
      avatarPath: r['avatarPath'] as String?,
      lastCompletedDate: r['lastCompletedDate'] == null
          ? null
          : DateTime.parse(r['lastCompletedDate'] as String),
    );
  }

  Future<List<Challenge>> challenges() async =>
      (await (await db.database).query('challenges')).map(_challenge).toList();
  Future<Challenge> challengeById(String id) async =>
      (await challenges()).firstWhere((c) => c.id == id);

  Color _leaderboardColorForRank(int rank) => switch (rank) {
    1 => const Color(0xFFFFF5A6),
    3 => const Color(0xFFFFDDB7),
    _ => const Color(0xFFEDEFF5),
  };

  Future<void> cacheChallenges(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    final database = await db.database;
    await database.transaction((txn) async {
      await txn.delete('challenges');
      for (final item in items) {
        await txn.insert('challenges', {
          'id': item['id'] as String,
          'title': item['title'] as String,
          'location': item['location'] as String,
          'description': item['description'] as String,
          'imageAsset': item['imageAsset'] as String,
          'distanceKm': (item['distanceKm'] as num).toDouble(),
          'points': item['points'] as int,
          'duration': item['duration'] as String,
          'difficulty': item['difficulty'] as String,
          'category': item['category'] as String,
          'latitude': (item['latitude'] as num).toDouble(),
          'longitude': (item['longitude'] as num).toDouble(),
          'explorersCompleted': item['explorersCompleted'] as int,
        });
      }
    });
  }

  Future<void> cacheLeaderboard(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    final database = await db.database;
    await database.transaction((txn) async {
      await txn.delete('leaderboard');
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final rank = item['rank'] as int? ?? (i + 1);
        await txn.insert('leaderboard', {
          'rank': rank,
          'name': item['name'] as String,
          'initials': item['initials'] as String,
          'level': item['level'] as int,
          'completed': item['completed'] as int,
          'points': item['points'] as int,
          'color': _leaderboardColorForRank(rank).toARGB32(),
        });
      }
    });
  }

  Future<ActiveChallengeState?> activeChallengeState() async {
    final rows = await (await db.database).query(
      'challenge_progress',
      where: 'userId = ? AND status = ?',
      whereArgs: ['local-user', ActiveChallengeStatus.active.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _activeChallenge(rows.first);
  }

  Future<void> startChallenge(String challengeId) async {
    final database = await db.database;
    await database.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      await txn.update(
        'challenge_progress',
        {'status': ActiveChallengeStatus.abandoned.name},
        where: 'userId = ? AND status = ?',
        whereArgs: ['local-user', ActiveChallengeStatus.active.name],
      );
      await txn.insert('challenge_progress', {
        'userId': 'local-user',
        'challengeId': challengeId,
        'status': ActiveChallengeStatus.active.name,
        'startedAt': now,
        'completedAt': null,
        'lastRouteShownAt': null,
        'proofPath': null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> markRouteShown(String challengeId) async {
    await (await db.database).update(
      'challenge_progress',
      {'lastRouteShownAt': DateTime.now().toIso8601String()},
      where: 'userId = ? AND challengeId = ? AND status = ?',
      whereArgs: ['local-user', challengeId, ActiveChallengeStatus.active.name],
    );
  }

  Future<Set<String>> completedChallengeIds() async {
    final rows = await (await db.database).query(
      'challenge_progress',
      columns: ['challengeId'],
      where: 'userId = ? AND status = ?',
      whereArgs: ['local-user', ActiveChallengeStatus.completed.name],
    );
    return rows.map((row) => row['challengeId'] as String).toSet();
  }

  Future<List<Achievement>> unlockedAchievements() async {
    final database = await db.database;
    final rows = await database.query(
      'user_achievements',
      where: 'userId = ?',
      whereArgs: ['local-user'],
      orderBy: 'unlockedAt DESC',
    );
    return rows.map((row) {
      final entry = achievementCatalog.firstWhere(
        (item) => item.id == row['achievementId'],
      );
      return achievementFromCatalog(
        entry,
        progress: entry.total,
        unlocked: _formatUnlockedDate(
          DateTime.parse(row['unlockedAt'] as String),
        ),
      );
    }).toList();
  }

  Future<List<Achievement>> progressAchievements() async {
    final database = await db.database;
    final user = await currentUser();
    final unlockedRows = await database.query(
      'user_achievements',
      columns: ['achievementId'],
      where: 'userId = ?',
      whereArgs: ['local-user'],
    );
    final unlockedIds = unlockedRows
        .map((row) => row['achievementId'] as String)
        .toSet();
    final completedRows = await database.rawQuery(
      '''
      SELECT c.category AS category, COUNT(*) AS total
      FROM challenge_progress cp
      JOIN challenges c ON c.id = cp.challengeId
      WHERE cp.userId = ? AND cp.status = ?
      GROUP BY c.category
      ''',
      ['local-user', ActiveChallengeStatus.completed.name],
    );
    final categoryCounts = <String, int>{};
    for (final row in completedRows) {
      categoryCounts[_normalizedCategory(row['category'] as String)] =
          row['total'] as int;
    }

    final progressById = <String, int>{
      'first_challenge': user.completed > 0 ? 1 : 0,
      'five_challenges': user.completed > 5 ? 5 : user.completed,
      'first_nature': categoryCounts['nature'] ?? 0,
      'first_cultural': categoryCounts['cultural'] ?? 0,
      'first_historical': categoryCounts['historical'] ?? 0,
      'first_adventure': categoryCounts['adventure'] ?? 0,
      'three_day_streak': user.currentStreak > 3 ? 3 : user.currentStreak,
    };

    return achievementCatalog
        .where((entry) => !unlockedIds.contains(entry.id))
        .map(
          (entry) => achievementFromCatalog(
            entry,
            progress: (progressById[entry.id] ?? 0).clamp(0, entry.total),
            unlocked: '',
          ),
        )
        .toList();
  }

  Future<void> _evaluateAchievements(Transaction txn) async {
    final userRows = await txn.query(
      'users',
      where: 'id = ?',
      whereArgs: ['local-user'],
      limit: 1,
    );
    if (userRows.isEmpty) return;
    final user = userRows.first;
    final completedRows = await txn.rawQuery(
      '''
      SELECT c.category AS category, COUNT(*) AS total
      FROM challenge_progress cp
      JOIN challenges c ON c.id = cp.challengeId
      WHERE cp.userId = ? AND cp.status = ?
      GROUP BY c.category
      ''',
      ['local-user', ActiveChallengeStatus.completed.name],
    );
    final categoryCounts = <String, int>{};
    for (final row in completedRows) {
      categoryCounts[_normalizedCategory(row['category'] as String)] =
          row['total'] as int;
    }
    final completed = user['completed'] as int;
    final streak = user['currentStreak'] as int;

    final unlockIds = <String>{};
    if (completed >= 1) unlockIds.add('first_challenge');
    if (completed >= 5) unlockIds.add('five_challenges');
    if ((categoryCounts['nature'] ?? 0) >= 1) unlockIds.add('first_nature');
    if ((categoryCounts['cultural'] ?? 0) >= 1) unlockIds.add('first_cultural');
    if ((categoryCounts['historical'] ?? 0) >= 1)
      unlockIds.add('first_historical');
    if ((categoryCounts['adventure'] ?? 0) >= 1)
      unlockIds.add('first_adventure');
    if (streak >= 3) unlockIds.add('three_day_streak');

    final now = DateTime.now().toIso8601String();
    for (final id in unlockIds) {
      await txn.insert('user_achievements', {
        'userId': 'local-user',
        'achievementId': id,
        'unlockedAt': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    final unlockCount =
        Sqflite.firstIntValue(
          await txn.rawQuery(
            'SELECT COUNT(*) FROM user_achievements WHERE userId = ?',
            ['local-user'],
          ),
        ) ??
        0;
    await txn.update(
      'users',
      {'badges': unlockCount},
      where: 'id = ?',
      whereArgs: ['local-user'],
    );
  }

  Future<void> debugUnlockAchievement(String achievementId) async {
    await (await db.database).insert('user_achievements', {
      'userId': 'local-user',
      'achievementId': achievementId,
      'unlockedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<LeaderboardEntry>> leaderboard() async =>
      (await (await db.database).query(
        'leaderboard',
        orderBy: 'rank',
      )).map(_leaderboard).toList();

  Future<void> saveGoogleUser({
    required String googleId,
    required String name,
    required String email,
  }) async {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    final database = await db.database;
    final existing = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: ['local-user'],
      limit: 1,
    );
    final previous = existing.first;
    final nextInitials = initials.isEmpty ? 'G' : initials;
    await database.update(
      'users',
      {
        'name': name,
        'email': email,
        'initials': nextInitials,
        'googleId': googleId,
      },
      where: 'id = ?',
      whereArgs: ['local-user'],
    );
    await database.update(
      'leaderboard',
      {'name': name, 'initials': nextInitials},
      where: 'name = ? AND initials = ?',
      whereArgs: [previous['name'], previous['initials']],
    );
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? avatarPath,
  }) async {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    final database = await db.database;
    final existing = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: ['local-user'],
      limit: 1,
    );
    final previous = existing.first;
    final nextInitials = initials.isEmpty ? 'U' : initials;
    await database.update(
      'users',
      {
        'name': name.trim(),
        'email': email.trim(),
        'initials': nextInitials,
        'avatarPath': avatarPath,
      },
      where: 'id = ?',
      whereArgs: ['local-user'],
    );
    await database.update(
      'leaderboard',
      {'name': name.trim(), 'initials': nextInitials},
      where: 'name = ? AND initials = ?',
      whereArgs: [previous['name'], previous['initials']],
    );
  }

  Future<void> debugSetLastCompletedDate(DateTime? value) async {
    await (await db.database).update(
      'users',
      {'lastCompletedDate': value?.toIso8601String()},
      where: 'id = ?',
      whereArgs: ['local-user'],
    );
  }

  Future<void> debugSetStreaks({
    required int currentStreak,
    required int bestStreak,
  }) async {
    await (await db.database).update(
      'users',
      {'currentStreak': currentStreak, 'bestStreak': bestStreak},
      where: 'id = ?',
      whereArgs: ['local-user'],
    );
  }

  Future<bool> completeChallengeAndAward(
    String challengeId,
    String? proofPath,
  ) async {
    final database = await db.database;
    return database.transaction((txn) async {
      final existingRows = await txn.query(
        'challenge_progress',
        where: 'userId = ? AND challengeId = ?',
        whereArgs: ['local-user', challengeId],
        limit: 1,
      );
      if (existingRows.isNotEmpty &&
          existingRows.first['status'] ==
              ActiveChallengeStatus.completed.name) {
        return false;
      }

      final userRows = await txn.query(
        'users',
        where: 'id = ?',
        whereArgs: ['local-user'],
        limit: 1,
      );
      final challengeRows = await txn.query(
        'challenges',
        where: 'id = ?',
        whereArgs: [challengeId],
        limit: 1,
      );
      if (userRows.isEmpty || challengeRows.isEmpty) return false;

      final user = userRows.first;
      final challenge = challengeRows.first;
      final startedAt =
          existingRows.firstOrNull?['startedAt'] as String? ??
          DateTime.now().toIso8601String();
      final completedAt = DateTime.now().toIso8601String();
      final earnedPoints = challenge['points'] as int;
      final newPoints = (user['points'] as int) + earnedPoints;
      final newCompleted = (user['completed'] as int) + 1;
      final newLevel = levelForPoints(newPoints);
      final newNextLevelPoints = nextLevelPointsForPoints(newPoints);
      final previousName = user['name'] as String;
      final previousInitials = user['initials'] as String;
      final streak = _nextStreak(
        now: DateTime.parse(completedAt),
        currentStreak: user['currentStreak'] as int,
        bestStreak: user['bestStreak'] as int,
        lastCompletedDate: user['lastCompletedDate'] as String?,
      );

      await txn.insert('challenge_progress', {
        'userId': 'local-user',
        'challengeId': challengeId,
        'status': ActiveChallengeStatus.completed.name,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'lastRouteShownAt': existingRows.firstOrNull?['lastRouteShownAt'],
        'proofPath': proofPath,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.update(
        'users',
        {
          'points': newPoints,
          'completed': newCompleted,
          'level': newLevel,
          'nextLevelPoints': newNextLevelPoints,
          'currentStreak': streak.currentStreak,
          'bestStreak': streak.bestStreak,
          'lastCompletedDate': streak.lastCompletedDate,
        },
        where: 'id = ?',
        whereArgs: ['local-user'],
      );

      await _evaluateAchievements(txn);

      await txn.update(
        'leaderboard',
        {
          'name': previousName,
          'initials': previousInitials,
          'points': newPoints,
          'completed': newCompleted,
          'level': newLevel,
        },
        where: 'name = ? AND initials = ?',
        whereArgs: [previousName, previousInitials],
      );

      final leaderboardRows = await txn.query(
        'leaderboard',
        orderBy: 'points DESC, completed DESC, name ASC',
      );
      await txn.delete('leaderboard');
      for (var i = 0; i < leaderboardRows.length; i++) {
        await txn.insert('leaderboard', {
          'rank': i + 1,
          'name': leaderboardRows[i]['name'],
          'initials': leaderboardRows[i]['initials'],
          'level': leaderboardRows[i]['level'],
          'completed': leaderboardRows[i]['completed'],
          'points': leaderboardRows[i]['points'],
          'color': leaderboardRows[i]['color'],
        });
      }
      return true;
    });
  }

  Challenge _challenge(Map<String, Object?> r) => Challenge(
    id: r['id'] as String,
    title: r['title'] as String,
    location: r['location'] as String,
    description: r['description'] as String,
    imageAsset: r['imageAsset'] as String,
    distanceKm: (r['distanceKm'] as num).toDouble(),
    points: r['points'] as int,
    duration: r['duration'] as String,
    difficulty: Difficulty.values.byName(r['difficulty'] as String),
    category: r['category'] as String,
    latitude: (r['latitude'] as num).toDouble(),
    longitude: (r['longitude'] as num).toDouble(),
    explorersCompleted: r['explorersCompleted'] as int,
  );

  ActiveChallengeState _activeChallenge(Map<String, Object?> r) =>
      ActiveChallengeState(
        challengeId: r['challengeId'] as String,
        startedAt: DateTime.parse(
          r['startedAt'] as String? ?? DateTime.now().toIso8601String(),
        ),
        status: ActiveChallengeStatus.values.byName(r['status'] as String),
        lastRouteShownAt: r['lastRouteShownAt'] == null
            ? null
            : DateTime.parse(r['lastRouteShownAt'] as String),
      );

  LeaderboardEntry _leaderboard(Map<String, Object?> r) => LeaderboardEntry(
    rank: r['rank'] as int,
    name: r['name'] as String,
    initials: r['initials'] as String,
    level: r['level'] as int,
    completed: r['completed'] as int,
    points: r['points'] as int,
    color: Color(r['color'] as int),
  );
}
