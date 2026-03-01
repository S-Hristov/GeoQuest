# Документация на курсова разработка: GeoQuest

## 1. Увод

Съвременните мобилни приложения за навигация и геолокация предоставят богата картографска информация, но в много случаи не предлагат достатъчно силен механизъм за ангажиране на потребителя чрез игрови елементи, целеви маршрути и проследяване на личен напредък. От друга страна, приложенията с елементи на геймификация често са насочени към спортна активност или към общности с потребителски генерирано съдържание, без да предлагат ясно структурирани, подготвени предварително предизвикателства.

Проектът **GeoQuest** е мобилно приложение, разработено с **Flutter**, което комбинира карта, географски предизвикателства, проверка на местоположение, доказателство чрез снимка, потребителски профил, класация и система от постижения. Основната цел на приложението е да мотивира потребителя да посещава реални обекти и локации, като изпълнява конкретни предизвикателства и получава точки, нива, серии и отличия.

Проектът е предназначен за потребители, които желаят:

- да откриват интересни локации чрез карта и списък;
- да бъдат мотивирани чрез точки, нива и постижения;
- да получават ежедневни и близки предизвикателства;
- да проследяват напредъка си в личен профил;
- да използват мобилно приложение с интеграция на GPS, камера и push известия.

Целевите потребители са основно млади и активни хора, туристи, градски изследователи и потребители, които предпочитат интерактивен и игрово ориентиран подход при опознаване на физически пространства.

## 2. Анализ на съществуващи разработки

При анализа на съществуващи разработки бяха разгледани приложения, които имат отношение към картография, геолокация, игрови механики или мотивация чрез потребителски напредък.

### 2.1 Google Maps

**Силни страни:**

- много добро картографско покритие;
- надеждна навигация;
- богата информация за обекти и маршрути;
- висока скорост и стабилност.

**Слаби страни:**

- липса на геймификация;
- липса на система за предизвикателства, точки и постижения;
- липса на профил, ориентиран към игрово развитие.

**Сравнение с GeoQuest:**

Google Maps е по-силно приложение по отношение на обща навигация и мащабируемост, но GeoQuest предлага функционалност, която е фокусирана върху мотивация и ангажиране чрез игрови механизми. В настоящия проект картата не е само средство за навигация, а основна среда за взаимодействие с предизвикателства.

### 2.2 Geocaching

**Силни страни:**

- силен елемент на реално географско търсене;
- добра идея за откриване на локации чрез задачи;
- висока ангажираност при потребители, които търсят приключенски сценарий.

**Слаби страни:**

- силна зависимост от общностно съдържание;
- по-малко структурирани и курирани предизвикателства;
- потребителското изживяване често зависи от качеството на създадените от други потребители обекти.

**Сравнение с GeoQuest:**

GeoQuest използва сходна идея за посещение на реални локации, но в проекта предизвикателствата са предварително дефинирани в системата, имат категории, трудност, точки и ясна връзка с профил, класация и постижения. Това води до по-контролирано и последователно потребителско изживяване.

### 2.3 Strava

**Силни страни:**

- силна мотивация чрез статистика и класации;
- добре реализирано проследяване на активност;
- изразен социален и състезателен компонент.

**Слаби страни:**

- основен фокус върху спорт и тренировки;
- не е ориентирано към културни, исторически или туристически обекти;
- изисква по-специализиран тип използване.

**Сравнение с GeoQuest:**

Strava е по-силно приложение за спортен анализ, но GeoQuest е по-подходящо за потребители, които искат да откриват места и да изпълняват предизвикателства, без приложението да бъде ограничено само до спортна активност. GeoQuest включва класация и серии, но в по-лек и достъпен за широк кръг потребители вид.

### 2.4 Обобщение на сравнителния анализ

В сравнение с разгледаните приложения GeoQuest не цели да ги замести в техния пълен обхват, а да реализира по-тясно специализирана концепция: **мобилно географско приложение с игрова мотивация и контролирани предизвикателства**. Силната страна на проекта е именно съчетаването на карта, GPS проверка, профил, точки, постижения и класация в единна мобилна среда.

## 3. Проектиране

### 3.1 Потребители

Приложението се използва от крайни мобилни потребители, които взаимодействат със системата през смартфон. На базата на реализацията в кода могат да бъдат отделени следните потребителски групи:

1. **Нерегистрирани или неизцяло автентикирани потребители**  
   Приложението позволява ограничено използване и в локален режим. Потребителят може да разглежда публични предизвикателства и класация, а част от действията могат да се обработват локално.

2. **Регистрирани потребители**  
   Те използват електронна поща и парола или Google вход. За тях приложението поддържа синхронизация с бекенд, профил, завършени предизвикателства, push регистрация, известия и локация.

3. **Оператори/администратори**  
   В бекенда е реализирана отделна callable функция `sendOpsNotification`, защитена чрез custom claims (`admin` или `ops`). Това показва наличие на административна роля за изпращане на оперативни broadcast известия.

**Целева група:**  
Основната целева група са потребители, които се интересуват от градско изследване, туристически маршрути, културни и природни обекти, както и от игрови механизми като точки, нива и постижения.

### 3.2 Данни и модели

#### 3.2.1 Данни в клиентската част

От анализа на кода се установява, че клиентската част използва следните основни модели, дефинирани в `lib/models/geo_models.dart`:

- `UserProfile`
- `Challenge`
- `ActiveChallengeState`
- `Achievement`
- `LeaderboardEntry`
- изброими типове:
  - `GeoQuestTab`
  - `ChallengeStatus`
  - `ActiveChallengeStatus`
  - `Difficulty`

Тези модели описват потребителя, предизвикателствата, статуса на активно предизвикателство, постиженията и елементите в класацията.

#### 3.2.2 Данни в бекенд частта

В `functions/src/contracts.ts` са дефинирани съответните бекенд записи:

- `UserProfileRecord`
- `UserLocationRecord`
- `NotificationPrefsRecord`
- `UserPushRecord`
- `ChallengeRecord`
- `ChallengeProgressRecord`
- `UserAchievementRecord`
- `LeaderboardRecord`
- `AchievementCatalogRecord`
- `AchievementViewRecord`
- `ActiveChallengeStateRecord`
- `AppStateRecord`

Това показва ясно разграничение между клиентския модел и бекенд представянето на данните.

#### 3.2.3 Структуриране и съхранение на данните

Приложението използва **двустепенно съхранение на данни**:

1. **Локално съхранение**
   - SQLite база данни чрез `sqflite` (`lib/db/app_database.dart`);
   - `SharedPreferences` за настройки и флагове.

2. **Отдалечено съхранение**
   - Firebase Authentication;
   - Firebase Cloud Functions;
   - Cloud Firestore, достъпван индиректно от Cloud Functions;
   - Firebase Cloud Messaging за push известия.

#### 3.2.4 SQLite структура

В `AppDatabase` са създадени следните таблици:

- `users`
- `challenges`
- `achievements`
- `leaderboard`
- `challenge_progress`
- `user_achievements`

SQLite служи за локален кеш и за локална логика при неавтентикиран режим.

#### 3.2.5 Данни в SharedPreferences

От `AppState.load()` и останалите методи се вижда, че се пазят следните настройки:

- `darkMode`
- `locale`
- `onboardingSeen`
- `isAuthenticated`
- `notificationsEnabled`
- `locationEnabled`
- `cameraEnabled`
- `lastSyncAt`

#### 3.2.6 Текстово описание на ER диаграма

В логически план връзките между основните обекти са следните:

- **UserProfile / UserProfileRecord** — централен обект за потребителската информация;
- един потребител има **много записи** в `challengeProgress`;
- едно предизвикателство може да участва в **много записи** в `challengeProgress`;
- един потребител има **много отключени постижения** в `userAchievements`;
- каталогът от постижения (`achievementCatalog`) участва като справочна таблица за `userAchievements`;
- класацията се извежда на база потребителските точки, завършени предизвикателства и ниво.

Следователно основната ER структура може да се опише така:

- `User` 1:N `ChallengeProgress`
- `Challenge` 1:N `ChallengeProgress`
- `User` 1:N `UserAchievement`
- `AchievementCatalog` 1:N `UserAchievement`

### 3.3 Функционалност

На базата на кода в проекта могат да бъдат обособени следните **реално реализирани** функционалности.

#### 3.3.1 Начално стартиране и onboarding

- стартиране на приложението в портретен режим;
- splash екран при инициализация;
- onboarding с четири страници;
- възможност за пропускане на onboarding;
- заявяване на разрешения за:
  - локация;
  - камера;
  - известия.

#### 3.3.2 Автентикация

- регистрация с име, e-mail и парола;
- вход с e-mail и парола;
- вход с Google;
- локално запомняне на флаг за автентикация;
- изход от профила.

#### 3.3.3 Работа с предизвикателства

- извличане на списък с предизвикателства;
- зареждане на детайли за конкретно предизвикателство;
- стартиране на предизвикателство;
- поддържане само на едно активно предизвикателство;
- отбелязване, че е показан маршрут;
- проверка дали потребителят е достигнал локацията;
- завършване на предизвикателство;
- запис на `proofPath` като доказателство;
- преминаване към екран за резултат след завършване.

#### 3.3.4 Карта и навигация

- визуализация на предизвикателства върху `GoogleMap`;
- превключване между карта и списък;
- филтриране по:
  - категория;
  - трудност;
  - максимално разстояние;
- центриране върху текущата локация;
- custom markers;
- клъстериране на маркери при ниско увеличение;
- отделна визуализация за активно и завършено предизвикателство;
- маршрутизация чрез Google Directions API;
- визуализиране на polyline маршрут.

#### 3.3.5 Геймификация

- точки за предизвикателства;
- нива;
- прогрес към следващо ниво;
- текуща серия и най-добра серия;
- постижения;
- отключени постижения;
- класация;
- дневно предизвикателство;
- близки предизвикателства.

#### 3.3.6 Профил и настройки

- екран с профил на потребителя;
- преглед на завършени предизвикателства;
- преглед на постижения в процес;
- преглед на отключени постижения;
- редакция на име, e-mail и профилна снимка;
- превключване на светла/тъмна тема;
- превключване на език между български и английски;
- управление на разрешенията чрез настройки;
- преглед на версията на приложението.

#### 3.3.7 Известия и синхронизация

- регистрация на push token;
- обновяване на предпочитания за известия;
- синхронизация на потребителска локация към бекенда;
- извличане на агрегирано приложение състояние от бекенда;
- периодични бекенд задачи за известия;
- известия при:
  - дневно предизвикателство;
  - близко предизвикателство;
  - риск за серия;
  - нова серия;
  - отключено постижение;
  - завършено предизвикателство;
  - седмичен отчет;
  - промяна в класацията;
  - повторно ангажиране;
  - оперативен broadcast.

#### 3.3.8 Ограничения на текущата реализация

В кода са налични и следните ограничения:

- полето за търсене в картата е само визуално и не изпълнява реално търсене;
- бутонът „Forgot password“ е наличен в интерфейса, но няма имплементирано действие;
- полето `bio` в `EditProfileScreen` не се записва в модела;
- екранът `UploadingProofScreen` симулира качване, без реална интеграция с облачно хранилище;
- `PhotoAcceptedScreen` е имплементиран, но не е основният маршрут в стандартния поток;
- приложението по подразбиране е конфигурирано да използва Firebase емулатори.

### 3.4 Потребителски интерфейс и навигация

#### 3.4.1 Основни екрани

От `lib/main.dart` и свързаните файлове се установяват следните екрани:

- `AppSplashScreen`
- `OnboardingScreen`
- `SignInScreen`
- `SignUpScreen`
- `HomeScreen`
- `MapScreen`
- `LeaderboardScreen`
- `ProfileScreen`
- `SettingsScreen`
- `EditProfileScreen`
- `ChallengeStartedScreen`
- `ChallengeDetailScreen`
- `CameraProofScreen`
- `UploadingProofScreen`
- `PhotoAcceptedScreen`
- `ChallengeCompleteScreen`

#### 3.4.2 Навигационен поток

Приложението използва route-базирана навигация чрез `MaterialApp.onGenerateRoute`.

Основният поток е следният:

1. При първо стартиране се показва `OnboardingScreen`.
2. След onboarding потребителят се пренасочва към `SignInScreen`.
3. След успешен вход се отваря `HomeScreen`.
4. От началния екран потребителят може да премине към:
   - карта (`MapScreen`);
   - класация (`LeaderboardScreen`);
   - профил (`ProfileScreen`).
5. От карта или списък може да се отвори:
   - предварителен преглед на предизвикателство;
   - детайлен екран `ChallengeDetailScreen`;
   - стартиране на предизвикателство.
6. След стартиране се показва `ChallengeStartedScreen`.
7. При навигация към целта се отваря `MapScreen` в режим `nav`.
8. При завършване се проверява локацията; ако е достигната, се преминава към `CameraProofScreen`.
9. След заснемане и потвърждение се отваря `UploadingProofScreen`.
10. След успешно приключване се показва `ChallengeCompleteScreen`.

#### 3.4.3 Текстово описание на диаграма на потребителски поток

Потребителският поток може да бъде описан текстово така:

`Splash -> Onboarding -> Sign In / Sign Up -> Home -> Map/List -> Challenge Details -> Start Challenge -> Navigation -> GPS Check -> Camera Proof -> Uploading Proof -> Challenge Complete -> Profile/Leaderboard/Home`

Този поток показва, че приложението е организирано около цикъл от откриване, изпълнение и отчитане на предизвикателства.

### 3.5 Архитектура

#### 3.5.1 Използван архитектурен подход

Приложението **не използва BLoC, Riverpod или Redux**. Използваният подход е:

- `Provider` за инжектиране на състояние;
- `ChangeNotifier` за реактивно оповестяване на промени;
- отделни слоеве за модели, състояние, услуги, репозитории и интерфейс.

Централният клас за управление на състоянието е `AppState`.

#### 3.5.2 Структура на проекта

От директориите в `lib/` се установява следната организация:

- `data` — мок данни;
- `db` — SQLite слой;
- `domain` — домейн логика, например прогресия и каталог на постижения;
- `l10n` — локализация;
- `models` — модели на данните;
- `repositories` — достъп и бизнес операции над локалната база;
- `screens` — екрани и подекрани;
- `services` — интеграции с външни услуги и устройство;
- `state` — глобално състояние на приложението;
- `theme` — теми и визуални настройки;
- `widgets` — споделени визуални компоненти.

Бекенд частта е отделена в `functions/src/`.

#### 3.5.3 Разделение на отговорностите

Разделението на отговорностите е ясно:

- **UI слой** — `screens/` и `widgets/`;
- **State management слой** — `state/app_state.dart`;
- **Repository слой** — `repositories/geo_repository.dart`;
- **Локално съхранение** — `db/app_database.dart`;
- **Device services** — камера, GPS, разрешения, конфигурация;
- **Remote services** — Firebase auth, Cloud Functions, push;
- **Backend logic** — `functions/src/*`.

#### 3.5.4 Текстово описание на архитектурна диаграма

Архитектурната схема може да бъде представена текстово така:

`Flutter UI -> AppState (ChangeNotifier) -> Services / Repository -> Local SQLite + SharedPreferences`

и при автентициран режим:

`Flutter UI -> AppState -> FirebaseBackendClient -> Cloud Functions -> Firestore / Firebase Messaging`

Това показва хибридна архитектура, която комбинира локална работа и отдалечена синхронизация.

## 4. Реализация

### 4.1 Инициализация и state management

Основната инициализация е реализирана в `lib/main.dart`. Приложението работи в портретен режим, след което създава `AppState` и го предоставя чрез `ChangeNotifierProvider`.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const _BootstrapApp());
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
```

Реализацията показва, че изборът на началния екран зависи от два флага:

- дали onboarding е вече преминат;
- дали потребителят е автентикиран.

### 4.2 Реализация на моделите

Клиентските модели са описани като обикновени immutable класове. Следният откъс показва структурата на `Challenge` и `UserProfile`.

```dart
class UserProfile {
  const UserProfile({
    required this.name,
    required this.initials,
    required this.level,
    required this.points,
    required this.nextLevelPoints,
    required this.completed,
    required this.badges,
    required this.bestStreak,
    required this.currentStreak,
    required this.email,
    this.avatarPath,
    this.lastCompletedDate,
  });
  final String name;
  final String initials;
  final int level;
  final int points;
  final int nextLevelPoints;
  final int completed;
  final int badges;
  final int bestStreak;
  final int currentStreak;
  final String email;
  final String? avatarPath;
  final DateTime? lastCompletedDate;
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.imageAsset,
    required this.distanceKm,
    required this.points,
    required this.duration,
    required this.difficulty,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.explorersCompleted,
  });
  final String id;
  final String title;
  final String location;
  final String description;
  final String imageAsset;
  final double distanceKm;
  final int points;
  final String duration;
  final Difficulty difficulty;
  final String category;
  final double latitude;
  final double longitude;
  final int explorersCompleted;
}
```

Тази организация улеснява четимостта, сериализацията и прехвърлянето на данни между UI, локалния слой и бекенда.

### 4.3 Локално съхранение

SQLite базата е реализирана в `lib/db/app_database.dart`. Следният откъс показва част от схемата:

```dart
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
      'CREATE TABLE challenge_progress(userId TEXT NOT NULL, challengeId TEXT NOT NULL, status TEXT NOT NULL, startedAt TEXT, completedAt TEXT, lastRouteShownAt TEXT, proofPath TEXT, PRIMARY KEY(userId, challengeId))',
    );
  },
);
```

Локалната база осигурява офлайн или fallback логика и позволява приложението да работи и без пълна бекенд зависимост във всеки сценарий.

### 4.4 Бизнес логика и приложение състояние

Класът `AppState` координира данните, синхронизацията, автентикацията и ключовите бизнес операции. Следният код показва част от логиката за начално зареждане:

```dart
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
  user = null;
  challenges = [];
  leaderboard = [];
  activeChallengeState = null;
  completedChallengeIds = <String>{};
  achievementsInProgress = [];
  unlockedAchievements = [];
  final lastSyncRaw = prefs?.getString('lastSyncAt');
  lastSyncAt = lastSyncRaw == null ? null : DateTime.tryParse(lastSyncRaw);
  try {
    await _refreshInitialData();
  } catch (error) {
    syncError = error.toString();
  }
  notifyListeners();
}
```

След стартиране на предизвикателство `AppState` делегира към локалния репозиторий или към бекенда според режима на работа:

```dart
Future<void> startChallenge(String challengeId) async {
  if (isChallengeCompleted(challengeId)) {
    syncError = 'startChallenge blocked: challenge already completed';
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
    }
    notifyListeners();
  }
}
```

Тук се вижда приложената хибридна логика: локално изпълнение при неавтентикиран потребител и отдалечено изпълнение при активна синхронизация.

### 4.5 Реализация на UI компоненти

UI слоят е реализиран чрез самостоятелни екрани и повторно използваеми визуални компоненти. Следният откъс от `ChallengeDetailScreen` показва как интерфейсът се свързва с логиката за започване и завършване на предизвикателство:

```dart
if (isCompleted)
  GradientButton(
    label: l.viewCompletedChallenge,
    gradient: AppColors.purpleGradient,
    onPressed: () => Navigator.pushNamed(
      context,
      '/challenge-complete/${c.id}',
    ),
  )
else if (!isActive)
  GradientButton(
    label: l.startChallenge,
    gradient: AppColors.purpleGradient,
    onPressed: () async {
      await context.read<AppState>().startChallenge(c.id);
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/challenge-started/${c.id}',
      );
    },
  )
```

Този подход съчетава декларативен интерфейс и директно извикване на бизнес логика през `Provider`.

### 4.6 Реализация на картата

Картата е изградена чрез `google_maps_flutter` в `GeoMapView`.

```dart
GoogleMap(
  initialCameraPosition: const CameraPosition(
    target: LatLng(42.7339, 25.4858),
    zoom: _initialZoom,
  ),
  style: mapStyle,
  onMapCreated: (controller) {
    _controller = controller;
    _refreshUserLocation();
  },
  onCameraMove: (position) => _pendingZoom = position.zoom,
  onCameraIdle: _handleCameraIdle,
  myLocationEnabled: true,
  myLocationButtonEnabled: false,
  zoomControlsEnabled: false,
  markers: markers,
  polylines: polylines,
)
```

Реализирани са:

- карта с персонализиран стил;
- показване на текуща локация;
- колекция от маркери;
- polyline маршрут;
- реакция при създаване на картата и промяна на камерата.

### 4.7 Реализация на marker логиката

Визуалното състояние на маркерите се определя според категория, трудност и статус.

```dart
MapPinStyleData mapPinStyle({
  required Challenge challenge,
  required bool isActive,
  required bool isCompleted,
}) {
  final category = normalizeCategory(challenge.category);
  final icon = switch (category) {
    'Cultural' => Icons.account_balance,
    'Nature' => Icons.park_outlined,
    'Historical' => Icons.castle_outlined,
    'Adventure' => Icons.landscape_outlined,
    _ => Icons.place_outlined,
  };

  if (isCompleted) {
    return MapPinStyleData(
      fillColor: const Color(0xFFC9D0DB),
      iconColor: const Color(0xFF8C97A8),
      icon: Icons.check_rounded,
      visualState: MapPinVisualState.completed,
      key: 'v7-completed-$category',
    );
  }
```

На тази база:

- завършените предизвикателства се различават визуално;
- активното предизвикателство има отделно състояние;
- трудността влияе върху цвета на маркера;
- категорията влияе върху иконата.

Допълнително в `GeoMapView` е реализирано клъстериране на маркери при нисък zoom, което е важно за добра четимост на картата.

### 4.8 Реализация на GPS и проверка на местоположение

Проверката дали потребителят е достигнал локацията е реализирана в `LocationService`.

```dart
class LocationService {
  const LocationService();
  static const completionRadiusMeters = 100.0;

  Future<LocationCheckResult> checkChallenge(Challenge challenge) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationCheckResult(
          status: ChallengeStatus.locationPermissionRequired,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationCheckResult(
          status: ChallengeStatus.locationPermissionRequired,
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        challenge.latitude,
        challenge.longitude,
      );
      return LocationCheckResult(
        status: distance <= completionRadiusMeters
            ? ChallengeStatus.locationReached
            : ChallengeStatus.tooFar,
        distanceMeters: distance,
      );
    } catch (_) {
      return const LocationCheckResult(
        status: ChallengeStatus.locationPermissionRequired,
      );
    }
  }
}
```

От кода се вижда, че:

- се проверява дали услугата за локация е активна;
- проверява се разрешението;
- при нужда се изисква разрешение;
- взема се текуща позиция с висока точност;
- използва се радиус от **100 метра** за приемане на завършване.

### 4.9 Реализация на маршрутизация

Маршрутизацията е реализирана чрез `DirectionsService`, който използва Google Directions API. Визуализацията на маршрута се извършва чрез polyline в картата. При липсващ API ключ или неуспешен отговор услугата връща `null`, което е пример за контролирано деградиране на функционалността.

### 4.10 Реализация на камера и доказателство

Камерата се използва чрез `camera` пакета:

```dart
class CameraProofService {
  CameraController? _controller;
  CameraController? get controller => _controller;

  Future<CameraController?> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    return _controller;
  }

  Future<XFile?> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return controller.takePicture();
  }
}
```

Текущата реализация осигурява:

- инициализация на камерата;
- заснемане на снимка;
- използване на път до локален файл като `proofPath`.

Важно е да се подчертае, че в настоящата версия **не е реализирано реално качване на снимката в облачно хранилище**. Това се вижда от `UploadingProofScreen`, където прогресът е симулиран чрез таймер.

```dart
timer = Timer.periodic(const Duration(milliseconds: 350), (t) {
  setState(() => value += .18);
  if (value >= 1) {
    t.cancel();
    _completeAndOpenResult();
  }
});
```

### 4.11 Валидация

Валидацията се реализира както в UI слоя, така и в `AppState` и бекенда.

#### 4.11.1 Валидация в потребителския интерфейс

В `AuthScaffold` има проверка за съвпадение на паролите:

```dart
bool get _passwordsMatch =>
    widget.isSignIn || _password.text == _confirmPassword.text;

Future<void> _submit() async {
  if (_busy) return;
  if (!widget.isSignIn && !_passwordsMatch) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).authPasswordMismatch),
      ),
    );
    return;
  }
```

В `EditProfileScreen` има проверка за задължително име и валиден e-mail:

```dart
validator: (value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return l.pleaseEnterEmail;
  final ok = RegExp(
    r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$',
  ).hasMatch(email);
  return ok ? null : l.pleaseEnterValidEmail;
},
```

#### 4.11.2 Валидация в `AppState`

При обновяване на профила има допълнителна защита:

```dart
if (normalizedName.isEmpty) return false;
final emailOk = RegExp(
  r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$',
).hasMatch(normalizedEmail);
if (!emailOk) return false;
```

#### 4.11.3 Валидация в бекенда

В `functions/src/index.ts` се проверяват аргументите на callable функциите, например:

- наличие на `challengeId`;
- наличие на `token`;
- наличие на `prefs`;
- валидни крайни координати при `updateUserLocation`.

Освен това user-scoped callable функциите използват:

```ts
const uid = requireAuthenticatedUid(request.auth);
```

а оперативният endpoint използва:

```ts
requireOpsAccess(request.auth);
```

Това показва реална бекенд валидация и контрол на достъпа.

### 4.12 Обработка на грешки

В проекта са използвани няколко механизма за обработка на грешки:

1. **`try/catch` в клиентския код**  
   Използва се при:
   - вход и регистрация;
   - синхронизация с бекенда;
   - GPS проверка;
   - работа с разрешения;
   - push регистрация.

2. **Fallback поведение**  
   При част от операциите има локално резервно поведение, особено при неавтентикиран режим.

3. **Връщане на статут вместо срив**  
   Пример е `LocationService.checkChallenge`, където при грешка се връща `locationPermissionRequired`, а не се прекратява приложението.

4. **Потребителски съобщения чрез `SnackBar`**  
   При неуспешно завършване, невалидни данни или отказани разрешения потребителят получава кратко визуално известие.

### 4.13 Реализация на бекенда

Комуникацията с Firebase се реализира през `FirebaseBackendClient`, който извиква callable Cloud Functions:

```dart
Future<Map<String, dynamic>> _mapCall(
  String name, [
  Map<String, dynamic>? data,
]) async {
  await _ensureFirebase();
  final result = await _functionsInstance.httpsCallable(name).call(data);
  final payload = result.data;
  if (payload is Map) return Map<String, dynamic>.from(payload);
  return const {};
}
```

В бекенда callable функциите са дефинирани в `functions/src/index.ts`. Част от тях са:

- `getAppState`
- `syncUserProfile`
- `updateProfile`
- `startChallenge`
- `markRouteShown`
- `completeChallenge`
- `registerPushToken`
- `updateNotificationPrefs`
- `updateUserLocation`
- `getLeaderboard`
- `getChallenges`

Бекендът реализира и периодични или автоматични събития:

- `pushDailyJobs`
- `pushNewChallengeBroadcast`

### 4.14 Реализация на бизнес правилата за завършване

Логиката за завършване на предизвикателство в бекенда актуализира точки, серии, нива и постижения:

```ts
const finishAt = nowIso();
const streak = this.nextStreak({
  now: new Date(finishAt),
  currentStreak: currentUser.currentStreak,
  bestStreak: currentUser.bestStreak,
  lastCompletedDate: currentUser.lastCompletedDate ?? null,
});
const nextPoints = currentUser.points + challenge.points;
const nextCompleted = currentUser.completed + 1;
```

След това системата:

- обновява потребителския профил;
- записва прогреса като `completed`;
- увеличава `explorersCompleted`;
- отключва нови постижения;
- изчислява допълнителни бонус точки.

Това показва централизиране на критичните игрови правила в бекенд слоя, което е правилен архитектурен подход.

## 5. Потребителско ръководство

### 5.1 Първоначално използване

1. Потребителят стартира приложението.
2. Показва се onboarding с четири последователни стъпки.
3. При страницата за разрешения приложението може да поиска достъп до:
   - местоположение;
   - камера;
   - известия.
4. След завършване на onboarding потребителят преминава към екран за вход.

### 5.2 Регистрация и вход

Потребителят може:

- да създаде профил с име, e-mail и парола;
- да влезе с вече съществуващ акаунт;
- да използва Google вход.

При успешен вход приложението отваря началния екран.

### 5.3 Разглеждане на предизвикателства

1. От `HomeScreen` потребителят вижда:
   - дневно предизвикателство;
   - следващо постижение;
   - близки предизвикателства;
   - категории.
2. При избор на категория се отваря `MapScreen` в списъчен режим с приложен филтър.
3. В `MapScreen` потребителят може да:
   - превключва между карта и списък;
   - отваря филтри;
   - избере конкретно предизвикателство.

### 5.4 Стартиране на предизвикателство

1. Потребителят отваря детайлите на предизвикателство.
2. Натиска бутона **Start Challenge**.
3. Приложението запазва активното предизвикателство.
4. Показва се `ChallengeStartedScreen`.
5. От този екран може да бъде стартирана навигация към целта.

### 5.5 Навигация до локацията

1. При навигация приложението отваря картата в специален navigation режим.
2. Ако Google Directions API е конфигуриран правилно, се визуализира маршрут.
3. Потребителят може да следва картата до реалната локация.

### 5.6 Завършване на предизвикателство

1. След достигане на локацията потребителят избира **Complete Challenge**.
2. Приложението проверява GPS позицията.
3. Ако потребителят се намира в радиус до 100 метра:
   - отваря се `CameraProofScreen`.
4. Потребителят заснема снимка и я потвърждава.
5. Отваря се `UploadingProofScreen`, където прогресът се визуализира.
6. След приключване системата отчита завършеното предизвикателство и показва `ChallengeCompleteScreen`.

### 5.7 Преглед на профил и класация

От долната навигация потребителят може да отвори:

- **Leaderboard**, за да види класирането и собственото си място;
- **Profile**, за да види:
  - ниво;
  - точки;
  - серия;
  - постижения;
  - завършени предизвикателства.

### 5.8 Настройки

От `ProfileScreen` потребителят отваря `SettingsScreen`, където може:

- да смени езика;
- да включи/изключи тъмен режим;
- да провери и управлява разрешенията;
- да отвори редакция на профила;
- да излезе от приложението.

## 6. Заключение

Въз основа на анализа на кода може да се направи изводът, че проектът **GeoQuest** изпълнява основната си цел: да предостави мобилно приложение за географски предизвикателства с игрови механизми, карта, GPS проверка, профил, постижения и класация.

### 6.1 Степен на удовлетворяване на потребителските нужди

Приложението отговаря на нуждите на потребители, които търсят:

- ориентиране чрез карта;
- ясни предизвикателства;
- мотивация чрез точки и постижения;
- персонален прогрес;
- мобилно преживяване, използващо реални сензори и услуги.

### 6.2 Основни силни страни

- ясна тематична концепция;
- добра модулна структура на кода;
- интеграция на карта, GPS, камера и push известия;
- реално използване на локално и отдалечено съхранение;
- налична геймификация с точки, нива, серии и постижения;
- отделен бекенд слой с callable функции и защитен достъп.

### 6.3 Ограничения

- липсва реално търсене в картата;
- няма имплементирана функционалност за забравена парола;
- липсва реално качване на снимка към облачно хранилище;
- полето за биография не се записва;
- част от поведението е ориентирано към демонстрационни данни и емулатори;
- няма социални функции като коментари, чат или създаване на потребителски предизвикателства.

### 6.4 Възможни бъдещи подобрения

На базата на текущата реализация естествени бъдещи разширения биха били:

- реална интеграция с Firebase Storage за снимки;
- реално текстово търсене и по-богати филтри;
- възстановяване на парола;
- по-подробна аналитика на маршрути и история;
- социални функции;
- административен панел за управление на предизвикателства;
- по-пълна офлайн синхронизация.

## 7. Приложение

### 7.1 Основни класове и файлове

#### Клиентска част

- `lib/main.dart` — начална точка и routing;
- `lib/state/app_state.dart` — глобално състояние;
- `lib/models/geo_models.dart` — модели;
- `lib/db/app_database.dart` — SQLite база;
- `lib/repositories/geo_repository.dart` — локална бизнес логика;
- `lib/services/firebase_backend_client.dart` — комуникация с Cloud Functions;
- `lib/services/location_service.dart` — GPS проверка;
- `lib/services/directions_service.dart` — маршрутизация;
- `lib/services/camera_proof_service.dart` — камера;
- `lib/services/app_auth_service.dart` — автентикация;
- `lib/services/app_permission_service.dart` — разрешения;
- `lib/services/push_notification_service.dart` — push известия;
- `lib/screens/home/home_screen.dart` — начален екран;
- `lib/screens/map/map_screen.dart` — карта и списък;
- `lib/screens/map/geo_map_view.dart` — Google Map реализация;
- `lib/screens/map/map_pin_style.dart` — маркери;
- `lib/screens/challenge/challenge_detail_screen.dart` — детайли на предизвикателство;
- `lib/screens/challenge/camera_proof_screen.dart` — снимка като доказателство;
- `lib/screens/challenge/uploading_proof_screen.dart` — симулирано качване;
- `lib/screens/profile/profile_screen.dart` — профил;
- `lib/screens/profile/settings_screen.dart` — настройки;
- `lib/screens/profile/edit_profile_screen.dart` — редакция на профил.

#### Бекенд част

- `functions/src/index.ts` — callable функции и scheduler/trigger точки;
- `functions/src/auth.ts` — автентикация и права;
- `functions/src/contracts.ts` — типове и договори;
- `functions/src/handlers.ts` — оркестрация на отговори и състояние;
- `functions/src/store.ts` — достъп до Firestore и бизнес операции;
- `functions/src/notifications.ts` — логика за push известия.

### 7.2 Важни кодови откъси

#### Route конфигурация

```dart
initialRoute: !state.onboardingSeen
    ? '/onboarding'
    : state.isAuthenticated
    ? '/home'
    : '/sign-in',
```

#### Проверка на GPS близост

```dart
status: distance <= completionRadiusMeters
    ? ChallengeStatus.locationReached
    : ChallengeStatus.tooFar,
```

#### Симулирано качване на доказателство

```dart
timer = Timer.periodic(const Duration(milliseconds: 350), (t) {
  setState(() => value += .18);
  if (value >= 1) {
    t.cancel();
    _completeAndOpenResult();
  }
});
```

#### Callable защита в бекенда

```ts
export function requireAuthenticatedUid(auth: CallableAuth): string {
  if (typeof auth?.uid !== 'string' || auth.uid.trim().length === 0) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }
  return auth.uid;
}
```

#### Изчисляване на прогрес и награди

```ts
const nextPoints = currentUser.points + challenge.points;
const nextCompleted = currentUser.completed + 1;
```

### 7.3 Текстово описание на допълнителни диаграми

#### Диаграма на синхронизация

Процесът на синхронизация може да бъде описан така:

1. Flutter клиентът извиква метод от `AppState`;
2. `AppState` делегира към `FirebaseBackendClient`;
3. `FirebaseBackendClient` извиква callable функция;
4. Cloud Function валидира потребителя;
5. `FirestoreStore` чете/записва данни в Firestore;
6. резултатът се връща към клиента;
7. `AppState` обновява in-memory състоянието и интерфейсът се прерисува.

#### Диаграма на жизнения цикъл на предизвикателство

Жизненият цикъл на едно предизвикателство е:

`готово -> активно -> завършено`  
или  
`готово -> активно -> изоставено`

Това е отразено чрез `ActiveChallengeStatus { active, completed, abandoned }`.

---

Настоящият текст представлява пълен първоначален проект на документация, изготвен въз основа на реално наличния код в проекта и подготвен за последваща редакция, оформяне и допълване според конкретните изисквания на университетската дисциплина.
