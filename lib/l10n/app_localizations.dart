import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GeoQuest'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get google;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @continueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey'**
  String get continueJourney;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @startAdventure.
  ///
  /// In en, this message translates to:
  /// **'Start your Bulgarian adventure'**
  String get startAdventure;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bulgarian.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get bulgarian;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccess;

  /// No description provided for @cameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get cameraAccess;

  /// No description provided for @notificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications'**
  String get notificationsSub;

  /// No description provided for @darkModeSub.
  ///
  /// In en, this message translates to:
  /// **'Adjust display theme'**
  String get darkModeSub;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @exploreMap.
  ///
  /// In en, this message translates to:
  /// **'Explore Map'**
  String get exploreMap;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get mapView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @maxDistance.
  ///
  /// In en, this message translates to:
  /// **'Max Distance'**
  String get maxDistance;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'hard'**
  String get hard;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @joinExplorers.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of explorers'**
  String get joinExplorers;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nGeoQuest Bulgaria'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Explore amazing places across Bulgaria\nand complete exciting challenges to\nearn rewards'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get onboardingHowItWorksTitle;

  /// No description provided for @onboardingHowItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'Your adventure in 4 simple steps'**
  String get onboardingHowItWorksBody;

  /// No description provided for @onboardingStepDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get onboardingStepDiscover;

  /// No description provided for @onboardingStepDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'Find nearby challenges and landmarks'**
  String get onboardingStepDiscoverBody;

  /// No description provided for @onboardingStepGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get onboardingStepGo;

  /// No description provided for @onboardingStepGoBody.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the location'**
  String get onboardingStepGoBody;

  /// No description provided for @onboardingStepComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get onboardingStepComplete;

  /// No description provided for @onboardingStepCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Finish the challenge'**
  String get onboardingStepCompleteBody;

  /// No description provided for @onboardingStepRewards.
  ///
  /// In en, this message translates to:
  /// **'Earn Rewards'**
  String get onboardingStepRewards;

  /// No description provided for @onboardingStepRewardsBody.
  ///
  /// In en, this message translates to:
  /// **'Collect points and achievements'**
  String get onboardingStepRewardsBody;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'We Need Your\nPermission'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'To give you the best experience'**
  String get onboardingPermissionsBody;

  /// No description provided for @onboardingLocationAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Find challenges near you and track your progress as you explore Bulgaria'**
  String get onboardingLocationAccessBody;

  /// No description provided for @onboardingCameraAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Capture photos to complete challenges and share your adventures'**
  String get onboardingCameraAccessBody;

  /// No description provided for @onboardingNotificationsAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Get challenge reminders, progress updates, and reward alerts in real time'**
  String get onboardingNotificationsAccessBody;

  /// No description provided for @onboardingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. We only use this data to\nenhance your GeoQuest experience.'**
  String get onboardingPrivacyNote;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to\nExplore?'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your adventure across Bulgaria starts\nnow. Discover hidden gems and create\nunforgettable memories!'**
  String get onboardingReadyBody;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authFailed;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameHint;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordMismatch;

  /// No description provided for @authTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to GeoQuest\'s\nTerms of Service and Privacy Policy'**
  String get authTerms;

  /// No description provided for @welcomeBackShort.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBackShort;

  /// No description provided for @levelWord.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelWord;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get badges;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @nextAchievement.
  ///
  /// In en, this message translates to:
  /// **'Next Achievement'**
  String get nextAchievement;

  /// No description provided for @nearbyChallenges.
  ///
  /// In en, this message translates to:
  /// **'Nearby Challenges'**
  String get nearbyChallenges;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @completeWord.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeWord;

  /// No description provided for @keepItGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep it going!'**
  String get keepItGoing;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @allRankings.
  ///
  /// In en, this message translates to:
  /// **'All Rankings'**
  String get allRankings;

  /// No description provided for @yourCurrentRank.
  ///
  /// In en, this message translates to:
  /// **'Your Current Rank'**
  String get yourCurrentRank;

  /// No description provided for @keepExploringHigher.
  ///
  /// In en, this message translates to:
  /// **'Keep exploring to climb higher!'**
  String get keepExploringHigher;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete with other explorers across Bulgaria'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardTip.
  ///
  /// In en, this message translates to:
  /// **'Complete more challenges to earn points and climb the leaderboard. Rankings are updated in real-time!'**
  String get leaderboardTip;

  /// No description provided for @pointsWord.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get pointsWord;

  /// No description provided for @settingsAllowLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Allow location services'**
  String get settingsAllowLocationServices;

  /// No description provided for @settingsAllowCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access'**
  String get settingsAllowCameraAccess;

  /// No description provided for @settingsAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow push notifications'**
  String get settingsAllowNotifications;

  /// No description provided for @settingsEditProfileSub.
  ///
  /// In en, this message translates to:
  /// **'View and edit your profile'**
  String get settingsEditProfileSub;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutSub.
  ///
  /// In en, this message translates to:
  /// **'End this local session'**
  String get settingsSignOutSub;

  /// No description provided for @settingsBackendSync.
  ///
  /// In en, this message translates to:
  /// **'Backend Sync'**
  String get settingsBackendSync;

  /// No description provided for @settingsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get settingsSyncing;

  /// No description provided for @settingsNoSyncYet.
  ///
  /// In en, this message translates to:
  /// **'No sync yet'**
  String get settingsNoSyncYet;

  /// No description provided for @settingsLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {value}'**
  String settingsLastSync(Object value);

  /// No description provided for @settingsLastError.
  ///
  /// In en, this message translates to:
  /// **'Last error: {value}'**
  String settingsLastError(Object value);

  /// No description provided for @settingsSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get settingsSyncComplete;

  /// No description provided for @settingsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get settingsSyncFailed;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {value}'**
  String settingsVersion(Object value);

  /// No description provided for @challengeStateActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get challengeStateActive;

  /// No description provided for @challengeStateCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeStateCompleted;

  /// No description provided for @awayLabel.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get awayLabel;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get startedLabel;

  /// No description provided for @aboutThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'About this Challenge'**
  String get aboutThisChallenge;

  /// No description provided for @rewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get rewardLabel;

  /// No description provided for @rewardFirstStepsPoints.
  ///
  /// In en, this message translates to:
  /// **'First Steps achievement • +{points} pts'**
  String rewardFirstStepsPoints(Object points);

  /// No description provided for @viewCompletedChallenge.
  ///
  /// In en, this message translates to:
  /// **'View Completed Challenge'**
  String get viewCompletedChallenge;

  /// No description provided for @startChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start Challenge'**
  String get startChallenge;

  /// No description provided for @completeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Complete Challenge'**
  String get completeChallenge;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @checkingLocation.
  ///
  /// In en, this message translates to:
  /// **'Checking location...'**
  String get checkingLocation;

  /// No description provided for @checkLocation.
  ///
  /// In en, this message translates to:
  /// **'Check Location'**
  String get checkLocation;

  /// No description provided for @challengeCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed'**
  String get challengeCompletedTitle;

  /// No description provided for @challengeCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'You already finished this challenge. Reward details stay available.'**
  String get challengeCompletedBody;

  /// No description provided for @startFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Start first'**
  String get startFirstTitle;

  /// No description provided for @startFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Activate the challenge to unlock navigation and completion.'**
  String get startFirstBody;

  /// No description provided for @navigateLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the location'**
  String get navigateLocationTitle;

  /// No description provided for @navigateLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Open navigation, then complete the challenge when you arrive.'**
  String get navigateLocationBody;

  /// No description provided for @locationPermissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequiredTitle;

  /// No description provided for @locationPermissionRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to verify your position.'**
  String get locationPermissionRequiredBody;

  /// No description provided for @tooFarAwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Too far away'**
  String get tooFarAwayTitle;

  /// No description provided for @tooFarAwayBody.
  ///
  /// In en, this message translates to:
  /// **'Be within 100m. Current distance: {value}.'**
  String tooFarAwayBody(Object value);

  /// No description provided for @locationReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location reached'**
  String get locationReachedTitle;

  /// No description provided for @locationReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You can now start the completion flow and submit your proof photo.'**
  String get locationReachedBody;

  /// No description provided for @challengeStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge Started!'**
  String get challengeStartedTitle;

  /// No description provided for @challengeStartedBody.
  ///
  /// In en, this message translates to:
  /// **'You are all set. Head to the landmark and complete it when you arrive.'**
  String get challengeStartedBody;

  /// No description provided for @challengeStartedTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use navigation first, then tap Complete Challenge on the detail screen.'**
  String get challengeStartedTip;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// No description provided for @backToMap.
  ///
  /// In en, this message translates to:
  /// **'Back to Map'**
  String get backToMap;

  /// No description provided for @photoAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Accepted! 🎉'**
  String get photoAcceptedTitle;

  /// No description provided for @photoAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your challenge has been completed successfully.'**
  String get photoAcceptedBody;

  /// No description provided for @firstStepsBadge.
  ///
  /// In en, this message translates to:
  /// **'First Steps Achievement'**
  String get firstStepsBadge;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{points} Points Earned'**
  String pointsEarned(Object points);

  /// No description provided for @updatingRewards.
  ///
  /// In en, this message translates to:
  /// **'Updating rewards...'**
  String get updatingRewards;

  /// No description provided for @viewRewardDetails.
  ///
  /// In en, this message translates to:
  /// **'View Reward Details'**
  String get viewRewardDetails;

  /// No description provided for @uploadingProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploading proof...'**
  String get uploadingProofTitle;

  /// No description provided for @uploadingProofBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we verify your submission'**
  String get uploadingProofBody;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @tapProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap profile photo to change it'**
  String get tapProfilePhoto;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get choosePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @saveProfileError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile. Check your details.'**
  String get saveProfileError;

  /// No description provided for @profileLevelExplorer.
  ///
  /// In en, this message translates to:
  /// **'Level {value} Explorer'**
  String profileLevelExplorer(Object value);

  /// No description provided for @levelValue.
  ///
  /// In en, this message translates to:
  /// **'Level {value}'**
  String levelValue(Object value);

  /// No description provided for @pointsProgress.
  ///
  /// In en, this message translates to:
  /// **'{points} / {next} pts'**
  String pointsProgress(Object points, Object next);

  /// No description provided for @pointsToLevel.
  ///
  /// In en, this message translates to:
  /// **'{points} points to Level {level}'**
  String pointsToLevel(Object points, Object level);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @recentUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Recent Unlocks'**
  String get recentUnlocks;

  /// No description provided for @completedChallenges.
  ///
  /// In en, this message translates to:
  /// **'Completed Challenges'**
  String get completedChallenges;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{value} days'**
  String daysCount(Object value);

  /// No description provided for @bestCount.
  ///
  /// In en, this message translates to:
  /// **'Best {value}'**
  String bestCount(Object value);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{value}-day streak'**
  String dayStreak(Object value);

  /// No description provided for @bestDays.
  ///
  /// In en, this message translates to:
  /// **'Best: {value} days'**
  String bestDays(Object value);

  /// No description provided for @dailyChallengeDistanceAway.
  ///
  /// In en, this message translates to:
  /// **'⌖ {value} km away'**
  String dailyChallengeDistanceAway(Object value);

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{value} km away'**
  String distanceAway(Object value);

  /// No description provided for @pointsPts.
  ///
  /// In en, this message translates to:
  /// **'+{value} pts'**
  String pointsPts(Object value);

  /// No description provided for @challengesCount.
  ///
  /// In en, this message translates to:
  /// **'{value} challenges'**
  String challengesCount(Object value);

  /// No description provided for @challengeCompleteCongrats.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations!'**
  String get challengeCompleteCongrats;

  /// No description provided for @challengeCompleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Challenge completed successfully!'**
  String get challengeCompleteSuccess;

  /// No description provided for @yourRewards.
  ///
  /// In en, this message translates to:
  /// **'Your Rewards'**
  String get yourRewards;

  /// No description provided for @pointsEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarnedLabel;

  /// No description provided for @badgeUnlockedForCompletingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!\nfor completing challenge'**
  String get badgeUnlockedForCompletingChallenge;

  /// No description provided for @totalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total\nCompleted'**
  String get totalCompleted;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @continueExploring.
  ///
  /// In en, this message translates to:
  /// **'🚀 Continue Exploring'**
  String get continueExploring;

  /// No description provided for @reachedNewLevel.
  ///
  /// In en, this message translates to:
  /// **'✨ You reached a new level!'**
  String get reachedNewLevel;

  /// No description provided for @pointsUntilNextLevel.
  ///
  /// In en, this message translates to:
  /// **'✨ Keep up the amazing work! Only {points} points until Level {level}!'**
  String pointsUntilNextLevel(Object points, Object level);

  /// No description provided for @requestingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Requesting permissions...'**
  String get requestingPermissions;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{subtitle}\nUnlocked {date}'**
  String achievementUnlocked(Object subtitle, Object date);

  /// No description provided for @completedCheck.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get completedCheck;

  /// No description provided for @leaderboardLevelCompleted.
  ///
  /// In en, this message translates to:
  /// **'Level {level}  •  {completed} completed'**
  String leaderboardLevelCompleted(Object level, Object completed);

  /// No description provided for @achievementFirstSteps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get achievementFirstSteps;

  /// No description provided for @achievementChallengeSeeker.
  ///
  /// In en, this message translates to:
  /// **'Challenge Seeker'**
  String get achievementChallengeSeeker;

  /// No description provided for @achievementNatureExplorer.
  ///
  /// In en, this message translates to:
  /// **'Nature Explorer'**
  String get achievementNatureExplorer;

  /// No description provided for @achievementNatureMaster.
  ///
  /// In en, this message translates to:
  /// **'Nature Master'**
  String get achievementNatureMaster;

  /// No description provided for @achievementCultureLover.
  ///
  /// In en, this message translates to:
  /// **'Culture Lover'**
  String get achievementCultureLover;

  /// No description provided for @achievementHistoryHunter.
  ///
  /// In en, this message translates to:
  /// **'History Hunter'**
  String get achievementHistoryHunter;

  /// No description provided for @achievementAdventureAwaits.
  ///
  /// In en, this message translates to:
  /// **'Adventure Awaits'**
  String get achievementAdventureAwaits;

  /// No description provided for @achievementStreakStarter.
  ///
  /// In en, this message translates to:
  /// **'Streak Starter'**
  String get achievementStreakStarter;

  /// No description provided for @achievementExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get achievementExplorer;

  /// No description provided for @achievementMountainClimber.
  ///
  /// In en, this message translates to:
  /// **'Mountain Climber'**
  String get achievementMountainClimber;

  /// No description provided for @achievementCompleteFirstChallenge.
  ///
  /// In en, this message translates to:
  /// **'Complete your first challenge'**
  String get achievementCompleteFirstChallenge;

  /// No description provided for @achievementCompleteFiveNature.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 nature challenges'**
  String get achievementCompleteFiveNature;

  /// No description provided for @achievementCompleteTwentyFive.
  ///
  /// In en, this message translates to:
  /// **'Complete 25 challenges'**
  String get achievementCompleteTwentyFive;

  /// No description provided for @achievementCompleteAllMountain.
  ///
  /// In en, this message translates to:
  /// **'Complete all mountain challenges'**
  String get achievementCompleteAllMountain;

  /// No description provided for @achievementCompleteTen.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 challenges'**
  String get achievementCompleteTen;

  /// No description provided for @achievementCompleteFiveCultural.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 cultural challenges'**
  String get achievementCompleteFiveCultural;

  /// No description provided for @categoryCultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get categoryCultural;

  /// No description provided for @categoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// No description provided for @categoryHistorical.
  ///
  /// In en, this message translates to:
  /// **'Historical'**
  String get categoryHistorical;

  /// No description provided for @categoryAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get categoryAdventure;

  /// No description provided for @liveCameraPreview.
  ///
  /// In en, this message translates to:
  /// **'Live Camera Preview'**
  String get liveCameraPreview;

  /// No description provided for @cameraFallbackPreview.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable — preview fallback'**
  String get cameraFallbackPreview;

  /// No description provided for @positionLandmark.
  ///
  /// In en, this message translates to:
  /// **'Position the landmark in frame and tap to capture'**
  String get positionLandmark;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @emptyChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'No challenges found'**
  String get emptyChallengesTitle;

  /// No description provided for @emptyChallengesBody.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filters or explore another area.'**
  String get emptyChallengesBody;

  /// No description provided for @emptyInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'No achievements in progress'**
  String get emptyInProgressTitle;

  /// No description provided for @emptyInProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Start a new challenge to begin working toward your next achievement.'**
  String get emptyInProgressBody;

  /// No description provided for @emptyUnlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent unlocks'**
  String get emptyUnlocksTitle;

  /// No description provided for @emptyUnlocksBody.
  ///
  /// In en, this message translates to:
  /// **'Complete challenges to unlock achievements and milestones.'**
  String get emptyUnlocksBody;

  /// No description provided for @emptyCompletedChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'No completed challenges yet'**
  String get emptyCompletedChallengesTitle;

  /// No description provided for @emptyCompletedChallengesBody.
  ///
  /// In en, this message translates to:
  /// **'Your finished adventures will appear here.'**
  String get emptyCompletedChallengesBody;

  /// No description provided for @emptyLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard is empty'**
  String get emptyLeaderboardTitle;

  /// No description provided for @emptyLeaderboardBody.
  ///
  /// In en, this message translates to:
  /// **'Complete challenges to be the first explorer on the board.'**
  String get emptyLeaderboardBody;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String timeDaysAgo(int n);

  /// No description provided for @errorCompletingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Could not save challenge result. Check your connection.'**
  String get errorCompletingChallenge;

  /// No description provided for @errorStartingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Could not start challenge. Check your connection.'**
  String get errorStartingChallenge;

  /// No description provided for @errorBackendBoot.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server. Please sign in again.'**
  String get errorBackendBoot;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile changes.'**
  String get errorUpdatingProfile;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check your connection.'**
  String get errorGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bg', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
