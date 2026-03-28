import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/app_database.dart';
import '../domain/progression.dart';
import '../data/mock_geoquest_data.dart' as seed;
import '../models/geo_models.dart';
import '../repositories/geo_repository.dart';
import '../services/app_auth_service.dart';
import '../services/firebase_backend_client.dart';
import '../services/push_notification_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.repository,
    required this.prefs,
    AppAuthService? authService,
    BackendClient? backendClient,
    PushNotificationService? pushService,
  }) : auth = authService ?? AppAuthService(),
       backend = backendClient ?? const FirebaseBackendClient(),
       push = pushService ?? PushNotificationService();
  final GeoRepository repository;
  final SharedPreferences? prefs;
  final AppAuthService auth;
  final BackendClient backend;
  final PushNotificationService push;

  ThemeMode themeMode = ThemeMode.light;
  Locale locale = const Locale('en');
  bool onboardingSeen = false;
  bool isAuthenticated = false;
  bool notificationsEnabled = true;
  bool locationEnabled = false;
  bool cameraEnabled = false;
  ActiveChallengeState? activeChallengeState;
  UserProfile? user;
  List<Challenge> challenges = [];
  List<LeaderboardEntry> leaderboard = [];
  Set<String> completedChallengeIds = <String>{};
  List<Achievement> achievementsInProgress = [];
  List<Achievement> unlockedAchievements = [];
  String? dailyChallengeId;
  List<String> nearbyChallengeIds = [];
  bool syncInProgress = false;
  String? syncError;
  DateTime? lastSyncAt;

  factory AppState.test() {
    final state = AppState(
      repository: GeoRepository(AppDatabase.instance),
      prefs: null,
    );
    state.onboardingSeen = false;
    state.isAuthenticated = false;
    state.notificationsEnabled = true;
    state.locationEnabled = false;
    state.cameraEnabled = false;
    state.user = seed.currentUser;
    state.challenges = seed.challenges;
    state.leaderboard = seed.leaderboard;
    state.activeChallengeState = null;
    state.completedChallengeIds = <String>{};
    state.achievementsInProgress = seed.achievements;
    state.unlockedAchievements = seed.unlockedAchievements;
    return state;
  }

  static Future<AppState> create({bool enablePush = true}) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(
      repository: GeoRepository(AppDatabase.instance),
      prefs: prefs,
    );
    await state.load();
    if (enablePush && state.onboardingSeen && state.notificationsEnabled) {
      await state.push.initIfConfigured();
      await state._syncPushRegistrationIfPossible();
    }
    return state;
  }

  Future<void> load() async {
    themeMode = prefs?.getBool('darkMode') == true
        ? ThemeMode.dark
        : ThemeMode.light;
    locale = Locale(prefs?.getString('locale') ?? 'en');
    onboardingSeen = prefs?.getBool('onboardingSeen') == true;
    isAuthenticated = prefs?.getBool('isAuthenticated') == true;
    notificationsEnabled = prefs?.getBool('notificationsEnabled') ?? true;
    locationEnabled = prefs?.getBool('locationEnabled') ?? false;
    cameraEnabled = prefs?.getBool('cameraEnabled') ?? false;
    // SQLite local cache disabled. Keep state empty until backend sync.
    user = null;
    challenges = [];
    leaderboard = [];
    activeChallengeState = null;
    completedChallengeIds = <String>{};
    achievementsInProgress = [];
    unlockedAchievements = [];
    final lastSyncRaw = prefs?.getString('lastSyncAt');
    lastSyncAt = lastSyncRaw == null ? null : DateTime.tryParse(lastSyncRaw);
    debugPrint(
      '🧨🧨🧨 BACKEND BOOT START | AppState.load -> _refreshFromBackend()',
    );
    try {
      await _refreshInitialData();
      debugPrint(
        '✅✅✅ BACKEND BOOT OK | AppState.load <- _refreshFromBackend()',
      );
    } catch (error) {
      syncError = error.toString();
      debugPrint(
        '❌❌❌ BACKEND BOOT FAIL | AppState.load | syncError=$syncError',
      );
    }
    notifyListeners();
  }

  UserProfile get currentUser => user ?? seed.currentUser;

  Challenge challengeById(String id) {
    final source = challenges.isNotEmpty ? challenges : seed.challenges;
    return source.firstWhere((c) => c.id == id, orElse: () => source.first);
  }

  Challenge? get dailyChallenge =>
      challenges.where((c) => c.id == dailyChallengeId).firstOrNull ??
      challenges.firstOrNull;

  List<Challenge> get nearbyChallenges {
    final ordered = nearbyChallengeIds
        .map((id) => challenges.where((c) => c.id == id).firstOrNull)
        .whereType<Challenge>()
        .toList();
    if (ordered.isNotEmpty) return ordered;
    final copy = [...challenges]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return copy.take(3).toList();
  }

  String? get activeChallengeId =>
      activeChallengeState?.status == ActiveChallengeStatus.active
      ? activeChallengeState?.challengeId
      : null;

  Challenge? get activeChallenge => activeChallengeId == null
      ? null
      : challenges.where((c) => c.id == activeChallengeId).firstOrNull;

  bool isChallengeActive(String challengeId) =>
      activeChallengeId == challengeId;

  bool isChallengeCompleted(String challengeId) =>
      completedChallengeIds.contains(challengeId) ||
      (activeChallengeState?.status == ActiveChallengeStatus.completed &&
          activeChallengeState?.challengeId == challengeId);

  Future<void> setAuthenticated(bool value) async {
    isAuthenticated = value;
    await prefs?.setBool('isAuthenticated', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    await prefs?.setBool('notificationsEnabled', value);
    await _syncPushRegistrationIfPossible();
    notifyListeners();
  }

  Future<void> setLocationEnabled(bool value) async {
    locationEnabled = value;
    await prefs?.setBool('locationEnabled', value);
    notifyListeners();
  }

  Future<void> setCameraEnabled(bool value) async {
    cameraEnabled = value;
    await prefs?.setBool('cameraEnabled', value);
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    isAuthenticated = false;
    await prefs?.setBool('isAuthenticated', false);
    notifyListeners();
  }

  Future<void> signInLocally() async {
    isAuthenticated = true;
    await prefs?.setBool('isAuthenticated', true);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingSeen = true;
    await prefs?.setBool('onboardingSeen', true);
    if (notificationsEnabled) {
      await push.initIfConfigured();
    }
    await _syncPushRegistrationIfPossible();
    notifyListeners();
  }

  Future<void> startChallenge(String challengeId) async {
    if (isChallengeCompleted(challengeId)) {
      syncError = 'startChallenge blocked: challenge already completed';
      debugPrint('⚠️ startChallenge blocked: challenge already completed');
      notifyListeners();
      return;
    }
    if (!isAuthenticated) {
      await repository.startChallenge(challengeId);
      activeChallengeState = await repository.activeChallengeState();
      notifyListeners();
      return;
    }
    try {
      final state = await backend.startChallenge(challengeId);
      _applyRemoteState(state);
      notifyListeners();
      return;
    } catch (error) {
      if (prefs == null) {
        await repository.startChallenge(challengeId);
        activeChallengeState = await repository.activeChallengeState();
      } else {
        syncError = 'startChallenge failed: $error';
        debugPrint('❌ startChallenge failed: $error');
      }
      notifyListeners();
    }
  }

  Future<void> markRouteShown(String challengeId) async {
    if (!isAuthenticated) {
      await repository.markRouteShown(challengeId);
      activeChallengeState = await repository.activeChallengeState();
      notifyListeners();
      return;
    }
    try {
      final state = await backend.markRouteShown(challengeId);
      _applyRemoteState(state);
      notifyListeners();
      return;
    } catch (error) {
      if (prefs == null) {
        await repository.markRouteShown(challengeId);
        activeChallengeState = await repository.activeChallengeState();
      } else {
        syncError = 'markRouteShown failed: $error';
        debugPrint('❌ markRouteShown failed: $error');
      }
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? avatarPath,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim();
    if (normalizedName.isEmpty) return false;
    final emailOk = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(normalizedEmail);
    if (!emailOk) return false;

    if (prefs == null || !isAuthenticated) {
      final initials = normalizedName
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => part[0])
          .join()
          .toUpperCase();
      final current = currentUser;
      user = UserProfile(
        name: normalizedName,
        initials: initials.isEmpty ? current.initials : initials,
        level: current.level,
        points: current.points,
        nextLevelPoints: current.nextLevelPoints,
        completed: current.completed,
        badges: current.badges,
        bestStreak: current.bestStreak,
        currentStreak: current.currentStreak,
        email: normalizedEmail,
        avatarPath: avatarPath,
        lastCompletedDate: current.lastCompletedDate,
      );
      notifyListeners();
      return true;
    }

    await repository.updateUserProfile(
      name: normalizedName,
      email: normalizedEmail,
      avatarPath: avatarPath,
    );
    user = await repository.currentUser();
    final initials = normalizedName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    final result = await backend.updateProfile(
      name: normalizedName,
      email: normalizedEmail,
      initials: initials.isEmpty ? currentUser.initials : initials,
      avatarPath: avatarPath,
    );
    final remoteUser = result['user'];
    if (remoteUser is Map) {
      _applyRemoteState({'user': remoteUser});
    } else {
      await _refreshFromBackend();
    }
    notifyListeners();
    return true;
  }

  Future<bool> completeChallengeAndAward({
    required String challengeId,
    String? proofPath,
  }) async {
    if (prefs == null || !isAuthenticated) {
      return _completeChallengeAndAwardLocally(
        challengeId: challengeId,
        proofPath: proofPath,
      );
    }

    try {
      final result = await backend.completeChallenge(
        challengeId,
        proofPath: proofPath,
      );
      final awardedRemote = result['awarded'] == true;
      final state = result['state'];
      if (state is Map) {
        _applyRemoteState(Map<String, dynamic>.from(state));
      } else if (result.isNotEmpty) {
        _applyRemoteState(result);
      }
      await setAuthenticated(true);
      notifyListeners();
      return awardedRemote || state is Map || result.isNotEmpty;
    } catch (error) {
      syncError = 'completeChallenge failed: $error';
      debugPrint('❌ completeChallenge failed: $error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> _completeChallengeAndAwardLocally({
    required String challengeId,
    String? proofPath,
  }) async {
    final challenge = challengeById(challengeId);
    final current = currentUser;
    final alreadyCompleted =
        activeChallengeState?.status == ActiveChallengeStatus.completed &&
        activeChallengeState?.challengeId == challengeId;
    if (alreadyCompleted) return false;
    final newCompleted = current.completed + 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final previous = current.lastCompletedDate == null
        ? null
        : DateTime(
            current.lastCompletedDate!.year,
            current.lastCompletedDate!.month,
            current.lastCompletedDate!.day,
          );
    final diff = previous == null ? null : today.difference(previous).inDays;
    final nextCurrentStreak = previous == null
        ? (current.currentStreak > 0 ? current.currentStreak : 1)
        : diff! <= 0
        ? (current.currentStreak > 0 ? current.currentStreak : 1)
        : diff == 1
        ? current.currentStreak + 1
        : 1;
    final nextBestStreak = nextCurrentStreak > current.bestStreak
        ? nextCurrentStreak
        : current.bestStreak;
    final category = challenge.category.toLowerCase();
    final progressMap = <String, int>{
      'first_challenge': newCompleted > 0 ? 1 : 0,
      'five_challenges': newCompleted > 5 ? 5 : newCompleted,
      'first_nature': category.contains('nature') ? 1 : 0,
      'first_cultural':
          (category.contains('culture') || category.contains('cultural'))
          ? 1
          : 0,
      'first_historical': category.contains('historical') ? 1 : 0,
      'first_adventure': category.contains('adventure') ? 1 : 0,
      'three_day_streak': nextCurrentStreak > 3 ? 3 : nextCurrentStreak,
    };
    final unlockedIds = unlockedAchievements
        .map((achievement) => achievement.title)
        .toSet();
    final achievementRewardById = <String, int>{
      'first_challenge': 50,
      'five_challenges': 120,
      'first_nature': 40,
      'first_cultural': 40,
      'first_historical': 40,
      'first_adventure': 40,
      'three_day_streak': 80,
    };
    String titleForId(String id) => switch (id) {
      'first_challenge' => 'First Steps',
      'five_challenges' => 'Challenge Seeker',
      'first_nature' => 'Nature Explorer',
      'first_cultural' => 'Culture Lover',
      'first_historical' => 'History Hunter',
      'first_adventure' => 'Adventure Awaits',
      'three_day_streak' => 'Streak Starter',
      _ => id,
    };
    var achievementBonusPoints = 0;
    for (final entry in progressMap.entries) {
      final needsUnlock = switch (entry.key) {
        'five_challenges' => entry.value >= 5,
        'three_day_streak' => entry.value >= 3,
        _ => entry.value >= 1,
      };
      final title = titleForId(entry.key);
      if (needsUnlock) {
        final isNew = !unlockedIds.contains(title);
        unlockedIds.add(title);
        if (isNew) {
          achievementBonusPoints += achievementRewardById[entry.key] ?? 0;
        }
      }
    }
    final totalPointsAwarded = challenge.points + achievementBonusPoints;
    user = UserProfile(
      name: current.name,
      initials: current.initials,
      level: levelForPoints(current.points + totalPointsAwarded),
      points: current.points + totalPointsAwarded,
      nextLevelPoints: nextLevelPointsForPoints(
        current.points + totalPointsAwarded,
      ),
      completed: newCompleted,
      badges: unlockedIds.length,
      bestStreak: nextBestStreak,
      currentStreak: nextCurrentStreak,
      email: current.email,
      avatarPath: current.avatarPath,
      lastCompletedDate: today,
    );
    activeChallengeState = ActiveChallengeState(
      challengeId: challengeId,
      startedAt: activeChallengeState?.startedAt ?? DateTime.now(),
      status: ActiveChallengeStatus.completed,
      lastRouteShownAt: activeChallengeState?.lastRouteShownAt,
    );
    completedChallengeIds = {...completedChallengeIds, challengeId};
    leaderboard =
        leaderboard.map((entry) {
          final sameUser =
              entry.name == current.name && entry.initials == current.initials;
          if (!sameUser) return entry;
          return LeaderboardEntry(
            rank: entry.rank,
            name: current.name,
            initials: current.initials,
            level: levelForPoints(current.points + totalPointsAwarded),
            completed: newCompleted,
            points: current.points + totalPointsAwarded,
            color: entry.color,
          );
        }).toList()..sort((a, b) {
          final pointsCompare = b.points.compareTo(a.points);
          if (pointsCompare != 0) return pointsCompare;
          final completedCompare = b.completed.compareTo(a.completed);
          if (completedCompare != 0) return completedCompare;
          return a.name.compareTo(b.name);
        });
    leaderboard = [
      for (var i = 0; i < leaderboard.length; i++)
        LeaderboardEntry(
          rank: i + 1,
          name: leaderboard[i].name,
          initials: leaderboard[i].initials,
          level: leaderboard[i].level,
          completed: leaderboard[i].completed,
          points: leaderboard[i].points,
          color: leaderboard[i].color,
        ),
    ];
    if (proofPath != null) {
      debugPrint('📸 local proof stored at $proofPath');
    }
    notifyListeners();
    return true;
  }

  Future<void> setDarkMode(bool enabled) async {
    themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await prefs?.setBool('darkMode', enabled);
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    locale = value;
    await prefs?.setString('locale', value.languageCode);
    notifyListeners();
  }

  Future<void> _refreshFromBackend() async {
    if (!isAuthenticated) {
      await _refreshPublicData();
      return;
    }
    final state = await backend.getAppState(
      name: user?.name,
      email: user?.email,
      initials: user?.initials,
      avatarPath: user?.avatarPath,
    );
    _applyRemoteState(state);
  }

  Future<void> _refreshInitialData() async {
    if (isAuthenticated) {
      await _refreshFromBackend();
      return;
    }
    await _refreshPublicData();
  }

  Future<void> _refreshPublicData() async {
    final challenges = await backend.getChallenges();
    final leaderboard = await backend.getLeaderboard();
    _applyRemoteState({'challenges': challenges, 'leaderboard': leaderboard});
  }

  Future<bool> syncNow() async {
    if (syncInProgress) return false;
    syncInProgress = true;
    syncError = null;
    notifyListeners();
    try {
      await _syncProfileToBackend();
      await _refreshFromBackend();
      lastSyncAt = DateTime.now();
      await prefs?.setString('lastSyncAt', lastSyncAt!.toIso8601String());
      syncInProgress = false;
      notifyListeners();
      return true;
    } catch (error) {
      syncInProgress = false;
      syncError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> _syncProfileToBackend() async {
    if (user == null || !isAuthenticated) return const {};
    return backend.syncUserProfile(
      name: currentUser.name,
      email: currentUser.email,
      initials: currentUser.initials,
      avatarPath: currentUser.avatarPath,
    );
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) return false;
    try {
      final result = await auth.signInWithEmail(trimmedEmail, password);
      if (result == null) return false;
      await repository.updateUserProfile(
        name: result.name,
        email: result.email,
        avatarPath: currentUser.avatarPath,
      );
      user = await repository.currentUser();
      final state = await _syncProfileToBackend();
      await setAuthenticated(true);
      if (state.isNotEmpty) {
        _applyRemoteState(state);
      } else {
        await _refreshFromBackend();
      }
      await _syncPushRegistrationIfPossible();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.length < 6) {
      return false;
    }
    try {
      final result = await auth.signUpWithEmail(
        name: trimmedName,
        email: trimmedEmail,
        password: password,
      );
      if (result == null) return false;
      await repository.updateUserProfile(
        name: result.name,
        email: result.email,
        avatarPath: currentUser.avatarPath,
      );
      user = await repository.currentUser();
      final state = await _syncProfileToBackend();
      await setAuthenticated(true);
      if (state.isNotEmpty) {
        _applyRemoteState(state);
      } else {
        await _refreshFromBackend();
      }
      await _syncPushRegistrationIfPossible();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _applyRemoteState(Map<String, dynamic> data) {
    String _str(dynamic value, [String fallback = '']) =>
        value is String ? value : fallback;
    int _int(dynamic value, [int fallback = 0]) =>
        value is num ? value.toInt() : fallback;
    double _double(dynamic value, [double fallback = .0]) =>
        value is num ? value.toDouble() : fallback;
    Difficulty _difficulty(dynamic value) {
      final raw = _str(value, Difficulty.easy.name);
      for (final item in Difficulty.values) {
        if (item.name == raw) return item;
      }
      return Difficulty.easy;
    }

    final remoteUser = data['user'];
    if (remoteUser is Map) {
      final map = Map<String, dynamic>.from(remoteUser);
      user = UserProfile(
        name: _str(map['name'], currentUser.name),
        initials: _str(map['initials'], currentUser.initials),
        level: _int(map['level'], currentUser.level),
        points: _int(map['points'], currentUser.points),
        nextLevelPoints: _int(
          map['nextLevelPoints'],
          currentUser.nextLevelPoints,
        ),
        completed: _int(map['completed'], currentUser.completed),
        badges: _int(map['badges'], currentUser.badges),
        bestStreak: _int(map['bestStreak'], currentUser.bestStreak),
        currentStreak: _int(map['currentStreak'], currentUser.currentStreak),
        email: _str(map['email'], currentUser.email),
        avatarPath: map['avatarPath'] as String?,
        lastCompletedDate: map['lastCompletedDate'] == null
            ? null
            : DateTime.tryParse(_str(map['lastCompletedDate'])),
      );
    }

    final remoteChallenges = data['challenges'];
    if (remoteChallenges is List) {
      challenges = remoteChallenges
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => Challenge(
              id: _str(item['id']),
              title: _str(item['title']),
              location: _str(item['location']),
              description: _str(item['description']),
              imageAsset: _str(
                item['imageAsset'],
                'assets/Image-Old-Town-Plovdiv@2x.png',
              ),
              distanceKm: _double(item['distanceKm']),
              points: _int(item['points']),
              duration: _str(item['duration']),
              difficulty: _difficulty(item['difficulty']),
              category: _str(item['category']),
              latitude: _double(item['latitude']),
              longitude: _double(item['longitude']),
              explorersCompleted: _int(item['explorersCompleted']),
            ),
          )
          .toList();
    }

    final remoteLeaderboard = data['leaderboard'];
    if (remoteLeaderboard is List) {
      leaderboard = remoteLeaderboard
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => LeaderboardEntry(
              rank: _int(item['rank'], 0),
              name: _str(item['name'], 'Explorer'),
              initials: _str(item['initials'], 'EX'),
              level: _int(item['level'], 1),
              completed: _int(item['completed'], 0),
              points: _int(item['points'], 0),
            ),
          )
          .toList();
    }

    final remoteActive = data['activeChallengeState'];
    if (remoteActive is Map) {
      final map = Map<String, dynamic>.from(remoteActive);
      activeChallengeState = ActiveChallengeState(
        challengeId: _str(map['challengeId']),
        startedAt: DateTime.tryParse(_str(map['startedAt'])) ?? DateTime.now(),
        status: ActiveChallengeStatus.values.byName(
          _str(map['status'], ActiveChallengeStatus.active.name),
        ),
        lastRouteShownAt: map['lastRouteShownAt'] == null
            ? null
            : DateTime.tryParse(_str(map['lastRouteShownAt'])),
      );
    } else {
      activeChallengeState = null;
    }

    final remoteCompleted = data['completedChallengeIds'];
    if (remoteCompleted is List) {
      completedChallengeIds = remoteCompleted.whereType<String>().toSet();
    }

    final remoteProgressAchievements = data['achievementsInProgress'];
    if (remoteProgressAchievements is List) {
      achievementsInProgress = remoteProgressAchievements
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => Achievement(
              title: _str(item['title']),
              subtitle: _str(item['subtitle']),
              icon: _str(item['icon'], '🏆'),
              rewardPoints: _int(item['rewardPoints']),
              progress: _int(item['progress']),
              total: _int(item['total'], 1),
              unlocked: _str(item['unlocked']),
            ),
          )
          .toList();
    }

    final remoteUnlockedAchievements = data['unlockedAchievements'];
    if (remoteUnlockedAchievements is List) {
      unlockedAchievements = remoteUnlockedAchievements
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => Achievement(
              title: _str(item['title']),
              subtitle: _str(item['subtitle']),
              icon: _str(item['icon'], '🏆'),
              rewardPoints: _int(item['rewardPoints']),
              progress: _int(item['progress']),
              total: _int(item['total'], 1),
              unlocked: _str(item['unlocked']),
            ),
          )
          .toList();
    }

    dailyChallengeId = data['dailyChallengeId'] is String
        ? data['dailyChallengeId'] as String
        : null;
    final remoteNearby = data['nearbyChallengeIds'];
    if (remoteNearby is List) {
      nearbyChallengeIds = remoteNearby.whereType<String>().toList();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final result = await auth.signInWithGoogle();
      if (result == null) return false;
      await repository.saveGoogleUser(
        googleId: result.uid,
        name: result.name,
        email: result.email,
      );
      user = await repository.currentUser();
      final state = await _syncProfileToBackend();
      await setAuthenticated(true);
      if (state.isNotEmpty) {
        _applyRemoteState(state);
      } else {
        await _refreshFromBackend();
      }
      await _syncPushRegistrationIfPossible();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _syncPushRegistrationIfPossible() async {
    if (!onboardingSeen) return;
    if (!isAuthenticated) return;

    final prefsPayload = <String, bool>{
      'dailyChallenge': notificationsEnabled,
      'nearbyNudges': notificationsEnabled,
      'streakRisk': notificationsEnabled,
      'streakMilestones': notificationsEnabled,
      'achievementUnlocks': notificationsEnabled,
      'completionSummary': notificationsEnabled,
      'newChallenges': notificationsEnabled,
      'weeklyRecap': notificationsEnabled,
      'leaderboardPass': notificationsEnabled,
      'reEngagement': notificationsEnabled,
      'ops': notificationsEnabled,
    };

    try {
      await backend.updateNotificationPrefs(prefs: prefsPayload);
    } catch (_) {}

    await _syncUserLocationIfPossible();

    if (!notificationsEnabled) return;
    try {
      await push.initIfConfigured();
      if (push.token == null) return;
      final platform = defaultTargetPlatform.name;
      final localeCode = locale.languageCode;
      await backend.registerPushToken(
        token: push.token!,
        platform: platform,
        locale: localeCode,
      );
    } catch (_) {}
  }

  Future<void> _syncUserLocationIfPossible() async {
    if (!locationEnabled) return;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await backend.updateUserLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        recordedAt: DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }
}
