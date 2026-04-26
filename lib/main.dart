import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

import 'models/geo_models.dart';
import 'screens/auth_screens.dart';
import 'screens/challenge_screens.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_settings_screens.dart';
import 'screens/splash/app_splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<AppState> _appStateFuture = AppState.create();

  @override
  Widget build(BuildContext context) => FutureBuilder<AppState>(
    future: _appStateFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AppSplashScreen(),
        );
      }
      return GeoQuestApp(appState: snapshot.requireData);
    },
  );
}

class GeoQuestApp extends StatelessWidget {
  const GeoQuestApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, state, _) => MaterialApp(
          title: 'GeoQuest',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildDarkAppTheme(),
          themeMode: state.themeMode,
          locale: state.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: !state.onboardingSeen
              ? '/onboarding'
              : state.isAuthenticated
              ? '/home'
              : '/sign-in',
          onGenerateRoute: _route,
        ),
      ),
    );
  }
}

Route<dynamic> _route(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/sign-in');
  return MaterialPageRoute(
    builder: (context) {
      final app = context.read<AppState>();
      return switch (uri.path) {
        '/' || '/sign-up' => const SignUpScreen(),
        '/sign-in' => const SignInScreen(),
        '/onboarding' => const OnboardingScreen(),
        '/home' => const HomeScreen(),
        '/map' => MapScreen(
          list:
              uri.queryParameters['view'] == 'list' &&
              uri.queryParameters['nav'] == null,
          navigationChallengeId: uri.queryParameters['nav'],
          initialCategory: uri.queryParameters['category'],
        ),
        '/leaderboard' => const LeaderboardScreen(),
        '/profile' => const ProfileScreen(),
        '/settings' => const SettingsScreen(),
        '/edit-profile' => const EditProfileScreen(),
        '/challenge-started' => ChallengeStartedScreen(
          challenge: app.activeChallenge ?? app.challenges.first,
        ),
        _ => _dynamicRoute(uri, app),
      };
    },
    settings: settings,
  );
}

Widget _dynamicRoute(Uri uri, AppState app) {
  final segments = uri.pathSegments;
  if (segments.length == 2 && segments.first == 'challenge-started') {
    return ChallengeStartedScreen(
      challenge: app.challengeById(segments.last),
      showBackToMap: uri.queryParameters['from'] == 'map',
    );
  }
  if (segments.length == 2 && segments.first == 'challenge') {
    return ChallengeDetailScreen(
      challenge: app.challengeById(segments.last),
      initialStatus: _status(uri.queryParameters['state']),
      fromNavigation: uri.queryParameters['from'] == 'nav',
    );
  }
  if (segments.length == 2 && segments.first == 'camera-proof') {
    return CameraProofScreen(challenge: app.challengeById(segments.last));
  }
  if (segments.length == 2 && segments.first == 'uploading-proof') {
    return UploadingProofScreen(
      challenge: app.challengeById(segments.last),
      proofPath: uri.queryParameters['proof'],
    );
  }
  if (segments.length == 2 && segments.first == 'photo-accepted') {
    return PhotoAcceptedScreen(
      challenge: app.challengeById(segments.last),
      proofPath: uri.queryParameters['proof'],
    );
  }
  if (segments.length == 2 && segments.first == 'challenge-complete') {
    return ChallengeCompleteScreen(challenge: app.challengeById(segments.last));
  }
  return const SignInScreen();
}

ChallengeStatus _status(String? value) => switch (value) {
  'tooFar' || 'too-far' => ChallengeStatus.tooFar,
  'permission' => ChallengeStatus.locationPermissionRequired,
  'reached' => ChallengeStatus.locationReached,
  _ => ChallengeStatus.ready,
};
