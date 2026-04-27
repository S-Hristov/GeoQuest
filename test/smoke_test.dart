import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoquest/data/mock_geoquest_data.dart';
import 'package:geoquest/data/mock_geoquest_data.dart' as seed;
import 'package:geoquest/db/app_database.dart';
import 'package:geoquest/l10n/app_localizations.dart';
import 'package:geoquest/main.dart';
import 'package:geoquest/models/geo_models.dart';
import 'package:geoquest/screens/auth_screens.dart';
import 'package:geoquest/services/firebase_backend_client.dart';
import 'package:geoquest/services/app_permission_service.dart';
import 'package:geoquest/screens/challenge_screens.dart';
import 'package:geoquest/screens/home_screen.dart';
import 'package:geoquest/screens/leaderboard_screen.dart';
import 'package:geoquest/screens/map_screen.dart';
import 'package:geoquest/screens/map/map_pin_style.dart';
import 'package:geoquest/screens/map/challenge_list_view.dart';
import 'package:geoquest/screens/onboarding_screen.dart';
import 'package:geoquest/screens/profile_settings_screens.dart';
import 'package:geoquest/state/app_state.dart';
import 'package:geoquest/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Widget wrap(Widget child) => ChangeNotifierProvider.value(
  value: AppState.test(),
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  sqfliteFfiInit();
  sqflite.databaseFactory = databaseFactoryFfi;
  SharedPreferences.setMockInitialValues({});
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(393, 1200);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(GeoQuestApp(appState: AppState.test()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('fresh install starts onboarding', (tester) async {
    final state = AppState.test()..onboardingSeen = false;
    await tester.pumpWidget(GeoQuestApp(appState: state));
    expect(find.textContaining('GeoQuest Bulgaria'), findsOneWidget);
  });

  testWidgets('seen onboarding starts sign in', (tester) async {
    final state = AppState.test()..onboardingSeen = true;
    await tester.pumpWidget(GeoQuestApp(appState: state));
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('onboarding get started marks seen and opens sign in', (
    tester,
  ) async {
    final state = AppState.test()..onboardingSeen = false;
    await tester.pumpWidget(GeoQuestApp(appState: state));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(state.onboardingSeen, isTrue);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('bulgarian locale changes sign in text', (tester) async {
    final state = AppState.test()
      ..onboardingSeen = true
      ..locale = const Locale('bg');
    await tester.pumpWidget(GeoQuestApp(appState: state));
    expect(find.text('Добре дошъл отново'), findsOneWidget);
  });

  testWidgets('sign in renders', (tester) async {
    await tester.pumpWidget(wrap(const SignInScreen()));
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('sign up renders', (tester) async {
    await tester.pumpWidget(wrap(const SignUpScreen()));
    expect(find.text('Start your Bulgarian adventure'), findsOneWidget);
  });

  testWidgets('sign up has confirm password + visibility toggles work', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const SignUpScreen()));

    final before = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(before.length, 4);
    expect(before[2].obscureText, isTrue);
    expect(before[3].obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined).first);
    await tester.pump();

    final after = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(after[2].obscureText, isFalse);
    expect(after[3].obscureText, isTrue);
  });

  testWidgets('sign up blocks submit when confirm password mismatches', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const SignUpScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'Test User');
    await tester.enterText(find.byType(TextField).at(1), 'test@mail.com');
    await tester.enterText(find.byType(TextField).at(2), 'Password123!');
    await tester.enterText(find.byType(TextField).at(3), 'Password999!');
    final submit = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Create Account'),
    );
    expect(submit.onPressed, isNull);
  });

  testWidgets('onboarding bulgarian renders', (tester) async {
    final state = AppState.test()..locale = const Locale('bg');
    await tester.pumpWidget(GeoQuestApp(appState: state));
    await tester.pumpAndSettle();
    expect(find.textContaining('Добре дошъл'), findsOneWidget);
  });

  testWidgets('onboarding short viewport no overflow', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(393, 700);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Permission'), findsOneWidget);
  });

  testWidgets('onboarding permissions page stays non-scrollable', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('onboarding renders', (tester) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    expect(find.textContaining('GeoQuest Bulgaria'), findsOneWidget);
  });

  testWidgets('onboarding permissions page lists notifications', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const OnboardingScreen()));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('home renders', (tester) async {
    await tester.pumpWidget(wrap(const HomeScreen()));
    expect(find.text('Daily Challenge'), findsOneWidget);
  });

  testWidgets('challenge list empty state renders', (tester) async {
    await tester.pumpWidget(wrap(const ChallengeListView(challenges: [])));
    expect(find.text('No challenges found'), findsOneWidget);
  });

  testWidgets('map renders', (tester) async {
    await tester.pumpWidget(wrap(const MapScreen()));
    expect(find.text('Explore Map'), findsOneWidget);
  });

  testWidgets('map category query applies initial filter', (tester) async {
    await tester.pumpWidget(
      wrap(const MapScreen(list: true, initialCategory: 'Nature')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belogradchik Rocks'), findsOneWidget);
    expect(find.text('Discover Rila Monastery'), findsNothing);
  });

  testWidgets('home category tap opens filtered map list', (tester) async {
    final state = AppState.test()
      ..onboardingSeen = true
      ..isAuthenticated = true;
    await tester.pumpWidget(GeoQuestApp(appState: state));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nature').last);
    await tester.pumpAndSettle();

    expect(find.text('Nearby Challenges'), findsOneWidget);
    expect(find.text('Belogradchik Rocks'), findsOneWidget);
    expect(find.text('Discover Rila Monastery'), findsNothing);
  });

  test('map pin style uses completed/active/difficulty metadata', () {
    final completed = mapPinStyle(
      challenge: challenges.first,
      isActive: false,
      isCompleted: true,
    );
    final active = mapPinStyle(
      challenge: challenges[1],
      isActive: true,
      isCompleted: false,
    );
    final hard = mapPinStyle(
      challenge: challenges[2],
      isActive: false,
      isCompleted: false,
    );

    expect(completed.visualState, MapPinVisualState.completed);
    expect(active.visualState, MapPinVisualState.active);
    expect(hard.visualState, MapPinVisualState.defaultPin);
    expect(hard.fillColor, const Color(0xFFEF4444));
  });

  testWidgets('map dark filter sheet uses dark surfaces', (tester) async {
    final state = AppState.test()..themeMode = ThemeMode.dark;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MapScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(DraggableScrollableSheet),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, isNot(Colors.white));
  });

  testWidgets('leaderboard dark mode avoids light hint card', (tester) async {
    final state = AppState.test()..themeMode = ThemeMode.dark;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          theme: buildAppTheme(),
          darkTheme: buildDarkAppTheme(),
          themeMode: ThemeMode.dark,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LeaderboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final material = tester.widget<Material>(find.byType(Material).at(3));
    expect(material.color, isNot(Colors.white));
  });

  testWidgets('leaderboard renders', (tester) async {
    await tester.pumpWidget(wrap(const LeaderboardScreen()));
    expect(find.text('All Rankings'), findsOneWidget);
  });

  testWidgets('profile renders', (tester) async {
    await tester.pumpWidget(wrap(const ProfileScreen()));
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('settings renders', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('settings permission toggles request and sync app state', (
    tester,
  ) async {
    final app = AppState.test();
    final permissions = _FakePermissionService();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: app,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(permissionService: permissions),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.length, 4);
    expect(switches[1].value, isFalse); // location
    expect(switches[2].value, isFalse); // camera
    expect(switches[3].value, isFalse); // notifications

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(3));
    await tester.pumpAndSettle();

    expect(permissions.requestCalls, 3);
    expect(app.locationEnabled, isTrue);
    expect(app.cameraEnabled, isTrue);
    expect(app.notificationsEnabled, isTrue);
  });

  testWidgets('settings off toggle opens system settings for revoke flow', (
    tester,
  ) async {
    final app = AppState.test();
    final permissions = _FakePermissionService(
      initial: const {
        AppPermissionType.location: AppPermissionState(granted: true),
        AppPermissionType.camera: AppPermissionState(granted: true),
        AppPermissionType.notifications: AppPermissionState(granted: true),
      },
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: app,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(permissionService: permissions),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).at(1)); // turn location off
    await tester.pumpAndSettle();
    expect(permissions.openSettingsCalls, 1);
  });

  testWidgets('active challenge getter reflects persisted state model', (
    tester,
  ) async {
    final state = AppState.test();
    state.activeChallengeState = ActiveChallengeState(
      challengeId: challenges.first.id,
      startedAt: DateTime(2026, 4, 16, 10, 30),
      status: ActiveChallengeStatus.active,
    );
    expect(state.activeChallengeId, challenges.first.id);
    expect(state.activeChallenge?.id, challenges.first.id);
  });

  testWidgets('challenge started screen renders persisted challenge state', (
    tester,
  ) async {
    final state = AppState.test();
    state.activeChallengeState = ActiveChallengeState(
      challengeId: challenges.first.id,
      startedAt: DateTime(2026, 4, 16, 10, 30),
      status: ActiveChallengeStatus.active,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChallengeStartedScreen(challenge: challenges.first),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Challenge Started!'), findsOneWidget);
    expect(find.text('active'), findsOneWidget);
  });

  testWidgets('challenge started screen short viewport no overflow', (
    tester,
  ) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(393, 760);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    final state = AppState.test();
    state.activeChallengeState = ActiveChallengeState(
      challengeId: challenges.first.id,
      startedAt: DateTime(2026, 4, 16, 10, 30),
      status: ActiveChallengeStatus.active,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChallengeStartedScreen(challenge: challenges.first),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Challenge Started!'), findsOneWidget);
  });

  testWidgets('edit profile saves updated name locally', (tester) async {
    final state = AppState.test();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const EditProfileScreen(),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'New Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'new@example.com');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(state.currentUser.name, 'New Name');
    expect(state.currentUser.email, 'new@example.com');
  });

  testWidgets('edit profile rejects invalid email', (tester) async {
    final state = AppState.test();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const EditProfileScreen(),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'bad-email');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  test('update profile stores avatar path in app state', () async {
    final state = AppState.test();
    const avatarPath = '/tmp/avatar.png';

    final ok = await state.updateProfile(
      name: 'Ava Tester',
      email: 'ava@test.com',
      avatarPath: avatarPath,
    );

    expect(ok, isTrue);
    expect(state.currentUser.name, 'Ava Tester');
    expect(state.currentUser.email, 'ava@test.com');
    expect(state.currentUser.avatarPath, avatarPath);
    expect(state.currentUser.initials, 'AT');
  });

  test(
    'complete challenge awards points once and clears active getter',
    () async {
      final state = AppState.test();
      final challenge = challenges.first;
      state.activeChallengeState = ActiveChallengeState(
        challengeId: challenge.id,
        startedAt: DateTime(2026, 4, 16),
        status: ActiveChallengeStatus.active,
      );

      final awarded = await state.completeChallengeAndAward(
        challengeId: challenge.id,
        proofPath: '/tmp/proof.jpg',
      );

      expect(awarded, isTrue);
      expect(state.currentUser.points, seed.currentUser.points + 450);
      expect(state.currentUser.completed, seed.currentUser.completed + 1);
      expect(state.currentUser.level, 14);
      expect(state.currentUser.nextLevelPoints, 3500);
      expect(state.activeChallengeId, isNull);
      expect(state.activeChallenge, isNull);
      expect(
        state.activeChallengeState?.status,
        ActiveChallengeStatus.completed,
      );
    },
  );

  test('duplicate challenge completion is idempotent', () async {
    final state = AppState.test();
    final challenge = challenges.first;

    final first = await state.completeChallengeAndAward(
      challengeId: challenge.id,
    );
    final pointsAfterFirst = state.currentUser.points;
    final completedAfterFirst = state.currentUser.completed;
    final second = await state.completeChallengeAndAward(
      challengeId: challenge.id,
    );

    expect(first, isTrue);
    expect(second, isFalse);
    expect(state.currentUser.points, pointsAfterFirst);
    expect(state.currentUser.completed, completedAfterFirst);
  });

  test('same day completion keeps streak same', () async {
    final state = AppState.test();
    final today = DateTime.now();
    state.user = UserProfile(
      name: state.currentUser.name,
      initials: state.currentUser.initials,
      level: state.currentUser.level,
      points: state.currentUser.points,
      nextLevelPoints: state.currentUser.nextLevelPoints,
      completed: state.currentUser.completed,
      badges: state.currentUser.badges,
      bestStreak: 7,
      currentStreak: 3,
      email: state.currentUser.email,
      avatarPath: state.currentUser.avatarPath,
      lastCompletedDate: today,
    );

    await state.completeChallengeAndAward(challengeId: challenges.first.id);
    final user = state.currentUser;

    expect(user.currentStreak, 3);
    expect(user.bestStreak, 7);
  });

  test('next day completion increments streak', () async {
    final state = AppState.test();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    state.user = UserProfile(
      name: state.currentUser.name,
      initials: state.currentUser.initials,
      level: state.currentUser.level,
      points: state.currentUser.points,
      nextLevelPoints: state.currentUser.nextLevelPoints,
      completed: state.currentUser.completed,
      badges: state.currentUser.badges,
      bestStreak: 7,
      currentStreak: 3,
      email: state.currentUser.email,
      avatarPath: state.currentUser.avatarPath,
      lastCompletedDate: yesterday,
    );

    await state.completeChallengeAndAward(challengeId: challenges.first.id);
    final user = state.currentUser;

    expect(user.currentStreak, 4);
    expect(user.bestStreak, 7);
  });

  test('missed day resets streak', () async {
    final state = AppState.test();
    final oldDate = DateTime.now().subtract(const Duration(days: 3));
    state.user = UserProfile(
      name: state.currentUser.name,
      initials: state.currentUser.initials,
      level: state.currentUser.level,
      points: state.currentUser.points,
      nextLevelPoints: state.currentUser.nextLevelPoints,
      completed: state.currentUser.completed,
      badges: state.currentUser.badges,
      bestStreak: 7,
      currentStreak: 5,
      email: state.currentUser.email,
      avatarPath: state.currentUser.avatarPath,
      lastCompletedDate: oldDate,
    );

    await state.completeChallengeAndAward(challengeId: challenges.first.id);
    final user = state.currentUser;

    expect(user.currentStreak, 1);
    expect(user.bestStreak, 7);
  });

  testWidgets('home and profile show dynamic streak values', (tester) async {
    final state = AppState.test();
    state.user = UserProfile(
      name: state.currentUser.name,
      initials: state.currentUser.initials,
      level: state.currentUser.level,
      points: state.currentUser.points,
      nextLevelPoints: state.currentUser.nextLevelPoints,
      completed: state.currentUser.completed,
      badges: state.currentUser.badges,
      bestStreak: 9,
      currentStreak: 4,
      email: state.currentUser.email,
      avatarPath: state.currentUser.avatarPath,
      lastCompletedDate: state.currentUser.lastCompletedDate,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    expect(find.text('4-day streak'), findsOneWidget);
    expect(find.text('Best: 9 days'), findsOneWidget);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('Best 9'), findsOneWidget);
  });

  test('completion unlocks first challenge achievement once', () async {
    final state = AppState.test();
    await state.completeChallengeAndAward(challengeId: challenges.first.id);
    final unlocked = state.unlockedAchievements;

    expect(unlocked.where((a) => a.title == 'First Steps').length, 1);
  });

  test('completion unlocks cultural and streak achievements', () async {
    final state = AppState.test();
    state.user = UserProfile(
      name: state.currentUser.name,
      initials: state.currentUser.initials,
      level: state.currentUser.level,
      points: state.currentUser.points,
      nextLevelPoints: state.currentUser.nextLevelPoints,
      completed: state.currentUser.completed,
      badges: state.currentUser.badges,
      bestStreak: 2,
      currentStreak: 2,
      email: state.currentUser.email,
      avatarPath: state.currentUser.avatarPath,
      lastCompletedDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    await state.completeChallengeAndAward(challengeId: challenges.first.id);
    final unlocked = state.unlockedAchievements;
    final titles = unlocked.map((a) => a.title).toSet();

    expect(titles.contains('Culture Lover'), isTrue);
    expect(titles.contains('Streak Starter'), isTrue);
  });

  test(
    'duplicate completion does not duplicate achievement unlocks',
    () async {
      final state = AppState.test();
      await state.completeChallengeAndAward(challengeId: challenges.first.id);
      await state.completeChallengeAndAward(challengeId: challenges.first.id);
      final unlocked = state.unlockedAchievements;

      expect(unlocked.where((a) => a.title == 'First Steps').length, 1);
    },
  );

  testWidgets('profile shows unlocked achievement from app state', (
    tester,
  ) async {
    final state = AppState.test();
    state.unlockedAchievements = const [
      Achievement(
        title: 'First Steps',
        subtitle: 'Complete your first challenge',
        icon: '🏆',
        progress: 1,
        total: 1,
        unlocked: '16/04/2026',
      ),
    ];
    state.achievementsInProgress = const [];

    await tester.pumpWidget(wrap(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('First Steps'), findsOneWidget);
    expect(
      find.textContaining('Complete your first challenge'),
      findsOneWidget,
    );
  });

  testWidgets('photo accepted updates points before reward details', (
    tester,
  ) async {
    final state = AppState.test()
      ..activeChallengeState = ActiveChallengeState(
        challengeId: challenges.first.id,
        startedAt: DateTime(2026, 4, 16),
        status: ActiveChallengeStatus.active,
      );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PhotoAcceptedScreen(
            challenge: challenges.first,
            proofPath: '/tmp/proof.jpg',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(state.currentUser.points, seed.currentUser.points + 450);
    expect(find.text('View Reward Details'), findsOneWidget);
  });

  testWidgets('challenge detail renders', (tester) async {
    await tester.pumpWidget(
      wrap(ChallengeDetailScreen(challenge: challenges.first)),
    );
    expect(find.text('About this Challenge'), findsOneWidget);
  });

  testWidgets('camera proof fallback renders', (tester) async {
    await tester.pumpWidget(
      wrap(CameraProofScreen(challenge: challenges.first)),
    );
    await tester.pump();
    expect(find.textContaining('Camera'), findsWidgets);
  });
  test('leaderboard reranks local user after points gain', () async {
    final state = AppState.test();
    state.user = UserProfile(
      name: 'Alex Petrov',
      initials: 'AP',
      level: 13,
      points: 3800,
      nextLevelPoints: 3500,
      completed: 30,
      badges: state.currentUser.badges,
      bestStreak: state.currentUser.bestStreak,
      currentStreak: state.currentUser.currentStreak,
      email: state.currentUser.email,
      avatarPath: state.currentUser.avatarPath,
      lastCompletedDate: state.currentUser.lastCompletedDate,
    );
    state.leaderboard = [
      const LeaderboardEntry(
        rank: 1,
        name: 'Maria Ivanova',
        initials: 'MI',
        level: 14,
        completed: 35,
        points: 5000,
        color: Color(0xFFFFF5A6),
      ),
      const LeaderboardEntry(
        rank: 2,
        name: 'Alex Petrov',
        initials: 'AP',
        level: 13,
        completed: 30,
        points: 3800,
        color: Color(0xFFEDEFF5),
      ),
    ];

    await state.completeChallengeAndAward(challengeId: challenges.first.id);
    final board = state.leaderboard;
    final userEntry = board.firstWhere((entry) => entry.initials == 'AP');

    expect(userEntry.rank, 2);
    expect(userEntry.points, 4250);
    expect(userEntry.completed, 31);
  });

  testWidgets('leaderboard shows updated current user rank from app state', (
    tester,
  ) async {
    final state = AppState.test();
    state.user = UserProfile(
      name: 'Ava Quest',
      initials: 'AQ',
      level: 14,
      points: 4100,
      nextLevelPoints: 4250,
      completed: 33,
      badges: 4,
      bestStreak: 9,
      currentStreak: 4,
      email: 'ava@test.com',
      avatarPath: null,
      lastCompletedDate: null,
    );
    state.leaderboard = const [
      LeaderboardEntry(
        rank: 1,
        name: 'Maria Ivanova',
        initials: 'MI',
        level: 15,
        completed: 38,
        points: 4520,
      ),
      LeaderboardEntry(
        rank: 2,
        name: 'Ava Quest',
        initials: 'AQ',
        level: 14,
        completed: 33,
        points: 4100,
      ),
      LeaderboardEntry(
        rank: 3,
        name: 'Stefan Dimitrov',
        initials: 'SD',
        level: 13,
        completed: 31,
        points: 3890,
      ),
      LeaderboardEntry(
        rank: 4,
        name: 'Alex Petrov',
        initials: 'AP',
        level: 12,
        completed: 24,
        points: 2850,
      ),
    ];

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LeaderboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#2'), findsWidgets);
    expect(find.text('Ava Quest'), findsOneWidget);
  });

  test(
    'syncNow merges remote challenges and leaderboard into sqlite state',
    () async {
      await AppDatabase.instance.resetForTest();
      final backend = _FakeBackendClient()
        ..remoteChallenges = [
          {
            'id': 'remote-1',
            'title': 'Remote Challenge',
            'location': 'Remote Place',
            'description': 'From backend',
            'imageAsset': 'assets/Image-Old-Town-Plovdiv@2x.png',
            'distanceKm': 4.2,
            'points': 333,
            'duration': '2h',
            'difficulty': 'medium',
            'category': 'Nature',
            'latitude': 42.7,
            'longitude': 23.4,
            'explorersCompleted': 12,
          },
        ]
        ..remoteLeaderboard = [
          {
            'rank': 1,
            'name': 'Remote Hero',
            'initials': 'RH',
            'level': 20,
            'completed': 99,
            'points': 9999,
          },
        ];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      final state = AppState(
        db: AppDatabase.instance,
        prefs: prefs,
        backendClient: backend,
      );

      await state.load();
      final ok = await state.syncNow();

      expect(ok, isTrue);
      expect(state.challenges.first.id, 'remote-1');
      expect(state.leaderboard.first.name, 'Remote Hero');
      expect(backend.syncedProfiles, 1);
    },
  );

  test(
    'load keeps cached authenticated user when backend boot fails',
    () async {
      await AppDatabase.instance.resetForTest();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('cache_user', jsonEncode({
        'name': 'Cached User',
        'initials': 'CU',
        'level': 9,
        'points': 2100,
        'nextLevelPoints': 2250,
        'completed': 18,
        'badges': 2,
        'bestStreak': 6,
        'currentStreak': 3,
        'email': 'cached@test.com',
        'avatarPath': null,
        'lastCompletedDate': DateTime(2026, 4, 20).toIso8601String(),
      }));
      final state = AppState(
        db: AppDatabase.instance,
        prefs: prefs,
        backendClient: _FailingBackendClient(),
      );

      await state.load();

      expect(state.isAuthenticated, isTrue);
      expect(state.user, isNotNull);
      expect(state.currentUser.name, 'Cached User');
      expect(state.currentUser.email, 'cached@test.com');
      expect(state.challenges, isNotEmpty);
      expect(state.leaderboard, isNotEmpty);
    },
  );

  test('backend-enabled actions push progress one-shot', () async {
    await AppDatabase.instance.resetForTest();
    final backend = _FakeBackendClient();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    final state = AppState(
      db: AppDatabase.instance,
      prefs: prefs,
      backendClient: backend,
    );

    await state.load();
    await state.startChallenge(challenges.first.id);
    await state.completeChallengeAndAward(challengeId: challenges.first.id);

    expect(backend.startedChallenges, contains(challenges.first.id));
    expect(backend.completedChallenges, contains(challenges.first.id));
  });
}

class _FakePermissionService implements AppPermissionService {
  _FakePermissionService({Map<AppPermissionType, AppPermissionState>? initial})
    : _state = {
        AppPermissionType.location: const AppPermissionState(granted: false),
        AppPermissionType.camera: const AppPermissionState(granted: false),
        AppPermissionType.notifications: const AppPermissionState(
          granted: false,
        ),
        ...?initial,
      };

  final Map<AppPermissionType, AppPermissionState> _state;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  @override
  Future<bool> openSettings() async {
    openSettingsCalls += 1;
    return true;
  }

  @override
  Future<AppPermissionState> request(AppPermissionType type) async {
    requestCalls += 1;
    const granted = AppPermissionState(granted: true);
    _state[type] = granted;
    return granted;
  }

  @override
  Future<AppPermissionState> status(AppPermissionType type) async =>
      _state[type] ?? const AppPermissionState(granted: false);
}

class _FakeBackendClient implements BackendClient {
  int syncedProfiles = 0;
  List<String> startedChallenges = [];
  List<String> completedChallenges = [];
  List<Map<String, dynamic>> remoteChallenges = [];
  List<Map<String, dynamic>> remoteLeaderboard = [];
  String? activeChallengeId;

  List<Map<String, dynamic>> get _resolvedChallenges =>
      remoteChallenges.isNotEmpty
      ? remoteChallenges
      : challenges
            .map(
              (c) => {
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
              },
            )
            .toList();

  List<Map<String, dynamic>> get _resolvedLeaderboard =>
      remoteLeaderboard.isNotEmpty
      ? remoteLeaderboard
      : [
          {
            'rank': 1,
            'name': 'Alex Petrov',
            'initials': 'AP',
            'level': seed.currentUser.level,
            'completed': seed.currentUser.completed,
            'points': seed.currentUser.points,
          },
        ];

  Map<String, dynamic> _state() => {
    'user': {
      'name': seed.currentUser.name,
      'initials': seed.currentUser.initials,
      'level': seed.currentUser.level,
      'points': seed.currentUser.points,
      'nextLevelPoints': seed.currentUser.nextLevelPoints,
      'completed': seed.currentUser.completed,
      'badges': seed.currentUser.badges,
      'bestStreak': seed.currentUser.bestStreak,
      'currentStreak': seed.currentUser.currentStreak,
      'email': seed.currentUser.email,
      'avatarPath': seed.currentUser.avatarPath,
      'lastCompletedDate': seed.currentUser.lastCompletedDate
          ?.toIso8601String(),
    },
    'challenges': _resolvedChallenges,
    'leaderboard': _resolvedLeaderboard,
    'activeChallengeState': activeChallengeId == null
        ? null
        : {
            'challengeId': activeChallengeId,
            'startedAt': DateTime.now().toIso8601String(),
            'status': ActiveChallengeStatus.active.name,
            'lastRouteShownAt': null,
          },
    'completedChallengeIds': completedChallenges,
    'achievementsInProgress': const <Map<String, dynamic>>[],
    'unlockedAchievements': const <Map<String, dynamic>>[],
    'dailyChallengeId': _resolvedChallenges.isEmpty
        ? null
        : _resolvedChallenges.first['id'],
    'nearbyChallengeIds': _resolvedChallenges
        .take(3)
        .map((e) => e['id'])
        .toList(),
  };

  @override
  Future<Map<String, dynamic>> completeChallenge(
    String challengeId, {
    String? proofPath,
  }) async {
    final alreadyCompleted = completedChallenges.contains(challengeId);
    if (!alreadyCompleted) {
      completedChallenges.add(challengeId);
    }
    activeChallengeId = null;
    return {'awarded': !alreadyCompleted, 'state': _state()};
  }

  @override
  Future<Map<String, dynamic>> registerPushToken({
    required String token,
    String? platform,
    String? locale,
  }) async => _state();

  @override
  Future<Map<String, dynamic>> getAppState({
    String? name,
    String? email,
    String? initials,
    String? avatarPath,
  }) async => _state();

  @override
  Future<List<Map<String, dynamic>>> getChallenges() async =>
      _resolvedChallenges;

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async =>
      _resolvedLeaderboard;

  @override
  Future<Map<String, dynamic>> markRouteShown(String challengeId) async =>
      _state();

  @override
  Future<Map<String, dynamic>> startChallenge(String challengeId) async {
    startedChallenges.add(challengeId);
    activeChallengeId = challengeId;
    return _state();
  }

  @override
  Future<Map<String, dynamic>> syncUserProfile({
    required String name,
    required String email,
    required String initials,
    String? avatarPath,
  }) async {
    syncedProfiles += 1;
    return _state();
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String initials,
    String? avatarPath,
  }) async => _state();

  @override
  Future<Map<String, dynamic>> updateNotificationPrefs({
    required Map<String, bool> prefs,
  }) async => _state();

  @override
  Future<Map<String, dynamic>> updateUserLocation({
    required double latitude,
    required double longitude,
    String? recordedAt,
  }) async => _state();
}

class _FailingBackendClient extends _FakeBackendClient {
  @override
  Future<Map<String, dynamic>> getAppState({
    String? name,
    String? email,
    String? initials,
    String? avatarPath,
  }) async => throw Exception('network down');
}
