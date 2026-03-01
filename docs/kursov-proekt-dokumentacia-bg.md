# 1. Увод

Настоящият курсов проект представлява мобилно приложение, разработено с Flutter, чиято цел е да комбинира картографиране, геолокация и игрови механики в обща среда за изпълнение на предизвикателства, свързани с реални места. От анализа на реализацията следва, че приложението е ориентирано към опознаване на обекти и маршрути в България, като още при стартиране визуализира идентичността „GeoQuest“ и слогана „Explore Bulgaria“.

Проблемът, който приложението адресира, е свързан с ниската ангажираност на потребителите при стандартно използване на карта или туристическа информация. В традиционните картографски приложения потребителят получава координати, маршрут и обща навигация, но липсва игрова мотивация, прогрес, постижения и усещане за последователно развитие. От друга страна, в чисто игровите приложения често липсва практическа ориентация в реална градска или природна среда. GeoQuest решава този проблем чрез модел, при който потребителят разглежда предизвикателства на карта, избира конкретна цел, достига физически до нея, валидира присъствието си чрез GPS и завършва активността с фотографско доказателство.

Основната цел на проекта е да се създаде работещо мобилно приложение за географски базирани предизвикателства, което:
- визуализира обекти върху карта и в списъчен изглед;
- позволява стартиране и проследяване на предизвикателство;
- проверява близостта до реалната локация чрез GPS;
- отчита завършване, точки, ниво, серия от последователни дни и постижения;
- поддържа профил на потребителя, класация и базова синхронизация с Firebase backend.

Целевите потребители са лица, които използват смартфон и имат интерес към градско и природно опознаване, тематични маршрути, игровизирано преживяване и събиране на точки/постижения. От реализираните категории предизвикателства („Cultural“, „Nature“, „Historical“, „Adventure“) може да се заключи, че приложението е насочено както към туристи и ученици/студенти, така и към местни потребители, които желаят да откриват нови места по игрови начин.

# 2. Анализ на съществуващи разработки

В рамките на анализа са разгледани три популярни типа приложения, сходни по отделни характеристики с настоящия проект: Google Maps, Geocaching и Strava. Сравнението е направено спрямо реално имплементираната функционалност в GeoQuest, без да се приписват несъществуващи възможности.

## 2.1 Google Maps

**Силни страни:**
- изключително силна картографска основа и надеждна навигация;
- широко покритие на обекти, адреси и маршрути;
- бърза и позната потребителска интеракция;
- практическа употреба за ежедневна ориентация.

**Слаби страни:**
- липса на игрови елементи като точки, нива, постижения и серия от дни;
- липса на механика за завършване на предизвикателства;
- фокусът е върху навигацията, а не върху мотивиране на потребителя да опознава дадено място чрез структурирани задачи.

**Сравнение на потребителското изживяване:**
Google Maps предоставя бърз и функционален маршрут до избрана точка, докато GeoQuest надгражда върху идеята за местоположение чрез игрова рамка. В реализирания код на GeoQuest картата се използва не само за визуализация, а и като вход към предизвикателство, състояние на маркер, навигационен режим и завършване на активност.

**Сравнение с настоящия проект:**
GeoQuest не може да се конкурира с мащаба и зрелостта на Google Maps като обща картографска платформа, но предлага реализирана в кода добавена стойност чрез прогрес, лидерборд, постижения, активни предизвикателства и GPS-валидирано завършване.

## 2.2 Geocaching

**Силни страни:**
- пряка връзка между реална географска локация и игрова дейност;
- силно усещане за откривателство и изпълнение на задача на място;
- естествено съвпадение с идеята за предизвикателства, базирани на местоположение.

**Слаби страни:**
- изживяването е по-тясно специализирано около конкретен тип активност;
- интерфейсът и логиката са по-подходящи за потребители, които вече познават концепцията;
- при определени сценарии е възможно по-високо входно усилие за нови потребители.

**Сравнение на потребителското изживяване:**
Geocaching и GeoQuest си приличат по това, че използват реални координати като ядро на дейността. Разликата е, че в текущата реализация на GeoQuest потокът е по-структуриран и ориентиран към мобилно обучение/забавление: карта -> избор на предизвикателство -> старт -> навигация -> GPS проверка -> снимка -> точки и постижения.

**Сравнение с настоящия проект:**
GeoQuest е по-ограничен като обхват, но кодът показва по-силно акцентиране върху геймификацията чрез нива, точки, серия, класация и категории. Това го прави по-подходящ за учебен проект с ясно дефиниран потребителски поток.

## 2.3 Strava

**Силни страни:**
- силна мотивационна система, основана на активност, статистики и резултати;
- добро усещане за прогрес и лично развитие;
- обществен елемент чрез класации и сравнение на резултати.

**Слаби страни:**
- фокусът е спортен и не е насочен към културни/исторически/туристически задачи;
- основната стойност идва от измерване на тренировки, а не от изпълнение на локационни мисии;
- не е предназначено за фотографско доказване на посещение в конкретна точка.

**Сравнение на потребителското изживяване:**
Strava мотивира чрез статистическо проследяване и лидерборд. GeoQuest използва сходна идея за прогрес и класация, но я прилага върху предизвикателства, свързани с посещение на обекти. В кода на проекта действително са реализирани точки, ниво, best/current streak, achievements и leaderboard entries.

**Сравнение с настоящия проект:**
Спрямо Strava, GeoQuest е по-малък по обхват, но по-тясно специализиран към опознаване на обекти и работа с карта. Проектът предлага по-ясен образователно-туристически сценарий, макар и с по-ограничени аналитични възможности.

## 2.4 Обобщение на сравнителния анализ

От сравнението следва, че GeoQuest комбинира характеристики от няколко класа системи:
- от картографските приложения – карта, маркери, маршрут, локация;
- от приложенията за откриване на обекти – посещение на конкретна точка;
- от спортно/геймифицираните приложения – точки, нива, серия, класация и постижения.

Предимството на проекта е в интеграцията на тези елементи в единна мобилна архитектура. Ограничението му е, че функционалността е целенасочена и по-тясна в сравнение с утвърдените комерсиални продукти.

# 3. Проектиране

## 3.1 Потребители

Приложението се използва от крайни потребители на мобилни устройства с Android/iOS, които желаят да откриват и изпълняват предизвикателства, свързани с реални места. От кода могат да бъдат обособени следните потребителски сценарии:

1. **Нов потребител** – преминава през onboarding, заявява разрешения, създава акаунт или влиза със съществуващ профил.
2. **Аутентикиран потребител** – използва персонализирано състояние, профил, лидерборд, постижения и синхронизация чрез Firebase Functions.
3. **Неаутентикиран потребител/локален режим** – може да зарежда публични данни за предизвикателства и класация, а в тестови/локални сценарии определени действия имат локален fallback чрез SQLite/репозитория.
4. **Административен оператор (backend)** – в backend частта е реализирана защитена callable функция `sendOpsNotification`, достъпна само при claim `admin` или `ops`.

Целевата група включва:
- млади потребители и студенти, които предпочитат игровизирано преживяване;
- туристи и посетители на градски/природни обекти;
- потребители, които желаят кратки мисии с измерим прогрес;
- хора, мотивирани от класации, точки и постижения.

## 3.2 Данни и модели

### 3.2.1 Използвани данни

От реализацията следва, че системата обработва няколко основни групи данни:
- данни за потребителя – име, инициали, точки, ниво, брой завършени предизвикателства, серия, електронна поща, аватар;
- данни за предизвикателства – заглавие, описание, категория, трудност, координати, точки, продължителност, изображение;
- данни за текущо активно предизвикателство – идентификатор, начало, състояние, момент на показване на маршрут;
- данни за постижения – заглавие, икона, прогрес, обща цел, статус на отключване;
- данни за класация – място, име, ниво, точки, брой завършени предизвикателства;
- данни за разрешения и настройки – тема, език, разрешения за локация/камера/известия;
- данни за push известия – token, предпочитания, backend jobs;
- данни за маршрут и местоположение – координати на потребителя, полилиния, проверка за близост.

### 3.2.2 Реални модели от кода

Основните клиентски модели са дефинирани във файла `lib/models/geo_models.dart`:
- `GeoQuestTab`
- `ChallengeStatus`
- `ActiveChallengeStatus`
- `Difficulty`
- `UserProfile`
- `Challenge`
- `ActiveChallengeState`
- `Achievement`
- `LeaderboardEntry`

Пример за реален модел от проекта:

```dart
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

В backend частта има отделни договори/записи във `functions/src/contracts.ts`, сред които:
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

### 3.2.3 Съхранение на данни

Приложението използва **хибриден модел на съхранение**:

1. **SharedPreferences** – за леки локални настройки:
   - `darkMode`
   - `locale`
   - `onboardingSeen`
   - `isAuthenticated`
   - `notificationsEnabled`
   - `locationEnabled`
   - `cameraEnabled`
   - `lastSyncAt`

2. **SQLite чрез sqflite** – за локални таблици и fallback режим. В `lib/db/app_database.dart` са създадени следните таблици:
   - `users`
   - `challenges`
   - `achievements`
   - `leaderboard`
   - `challenge_progress`
   - `user_achievements`

3. **Firebase Authentication** – за вход с email/password и Google.

4. **Firebase Cloud Functions** – за синхронизация на профил, предизвикателства, класация, завършване на challenge, push token и потребителска локация.

Важно е да се отбележи, че в клиентския код **не се използва директно пакетът `cloud_firestore`**. Достъпът до backend логика е реализиран чрез callable functions в `FirebaseBackendClient`.

### 3.2.4 Текстово описание на ER диаграма

ER диаграмата на системата може да бъде описана текстово по следния начин:

- Същността **User** съдържа данни за профил, точки, ниво, брой завършени задачи, серия и аватар.
- Същността **Challenge** съдържа описание на предизвикателството, категория, трудност, координати, точки и статистика за завършвания.
- Между **User** и **Challenge** съществува междинна същност **ChallengeProgress**, която пази статуса (`active`, `completed`, `abandoned`), начална дата, крайна дата, момент на показване на маршрут и път до снимка.
- Между **User** и **AchievementCatalog** съществува междинна същност **UserAchievement**, която пази кое постижение е отключено и кога.
- Същността **LeaderboardRecord** отразява позиция в класацията, която се извежда от потребителските показатели.
- В backend са налични и същности **UserLocation**, **NotificationPrefs** и **UserPush**, които поддържат геолокация и push известия.

Така централната връзка в модела е между потребител, предизвикателство и напредък по това предизвикателство.

## 3.3 Функционалност

Реално имплементираната функционалност може да се групира по следния начин.

### 3.3.1 Стартиране и първоначална настройка
- начален splash екран при асинхронно зареждане на състоянието;
- onboarding с четири страници;
- заявяване на разрешения за локация, камера и известия по време на onboarding;
- запомняне дали onboarding вече е преминат.

### 3.3.2 Аутентикация
- регистрация с email и парола;
- вход с email и парола;
- вход с Google;
- изход от профила;
- локално отбелязване на аутентикационен статус.

### 3.3.3 Работа с карта и предизвикателства
- визуализиране на предизвикателства върху Google Map;
- превключване между карта и списък;
- филтриране по категория, трудност и максимално разстояние;
- специално визуално оформление на маркерите според категория, трудност и състояние;
- клъстериране на маркери при по-нисък zoom;
- показване на текущата позиция на потребителя;
- центриране върху текущата позиция;
- навигационен режим към активно предизвикателство;
- извличане на пешеходен маршрут чрез Google Directions API;
- показване на polyline за активния маршрут.

### 3.3.4 Жизнен цикъл на предизвикателство
- отваряне на детайли за предизвикателство;
- стартиране на предизвикателство;
- поддържане на само едно активно предизвикателство в даден момент;
- маркиране, че маршрутът е показан;
- проверка за близост до целта чрез GPS;
- преминаване към камера след успешно достигане в радиус до 100 метра;
- заснемане на фотографско доказателство;
- преглед и повторно заснемане;
- екран за симулирано качване;
- завършване на предизвикателството;
- начисляване на точки, ниво, серия и постижения.

### 3.3.5 Профил и прогрес
- визуализация на име, аватар, ниво и прогрес към следващо ниво;
- статистики за точки, брой завършени задачи и брой значки;
- списък с постижения в прогрес;
- списък с отключени постижения;
- списък със завършени предизвикателства;
- редакция на име, email и аватар.

### 3.3.6 Класация
- екран с лидерборд;
- визуализация на първите три позиции като подиум;
- списък с останалите позиции;
- показване на текущата позиция на потребителя.

### 3.3.7 Настройки и персонализация
- превключване на език между български и английски;
- превключване на светла/тъмна тема;
- управление на редовете за разрешения;
- отваряне на настройки на устройството при нужда;
- изход от профила.

### 3.3.8 Известия и backend синхронизация
- заявяване на разрешение за push известия;
- получаване и регистрация на push token;
- синхронизация на предпочитания за известия;
- backend callable функции за профил, предизвикателства, класация, локация и завършване;
- backend задачи за периодични известия и broadcast при ново предизвикателство.

### 3.3.9 Реални ограничения на текущата функционалност
Следващите елементи присъстват в интерфейса или в кода, но не са напълно завършени:
- полето за търсене в `MapScreen` е визуализирано, но няма свързана логика за търсене;
- бутонът „Forgot password“ е реализиран с празен callback;
- `bio` полето в `EditProfileScreen` не се записва към профила;
- потокът със `PhotoAcceptedScreen` съществува като екран, но обичайният път отива директно към `ChallengeCompleteScreen`;
- снимката не се качва в отделно хранилище; подава се текстов `proofPath`;
- маршрутът зависи от наличен Google Maps API ключ;
- `BackendConfig.useEmulators = true`, което показва, че текущата конфигурация е ориентирана по подразбиране към локални емулатори.

## 3.4 Потребителски интерфейс и навигация

### 3.4.1 Екрани в приложението

От реалните route дефиниции и екранни класове следва, че приложението съдържа следните основни екрани:
- `AppSplashScreen`
- `OnboardingScreen`
- `SignInScreen`
- `SignUpScreen`
- `HomeScreen`
- `MapScreen`
- `ChallengeDetailScreen`
- `ChallengeStartedScreen`
- `CameraProofScreen`
- `UploadingProofScreen`
- `PhotoAcceptedScreen`
- `ChallengeCompleteScreen`
- `LeaderboardScreen`
- `ProfileScreen`
- `SettingsScreen`
- `EditProfileScreen`

### 3.4.2 Навигационен поток

Навигацията е реализирана чрез `MaterialApp` и `onGenerateRoute`. Началният маршрут зависи от състоянието на приложението:
- ако onboarding не е преминат -> `/onboarding`;
- ако има аутентикация -> `/home`;
- в противен случай -> `/sign-in`.

Реален откъс от `lib/main.dart`:

```dart
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
      initialRoute: !state.onboardingSeen
          ? '/onboarding'
          : state.isAuthenticated
          ? '/home'
          : '/sign-in',
      onGenerateRoute: _route,
    ),
  ),
);
```

Основните навигационни преходи са:
- Onboarding -> Sign In;
- Sign In / Sign Up -> Home;
- Home -> Map / Leaderboard / Profile;
- Home -> Challenge Detail;
- Map -> Challenge Preview -> Challenge Detail или Start;
- Start -> ChallengeStartedScreen -> навигационен режим на картата;
- Challenge Detail (при активно предизвикателство) -> GPS проверка -> CameraProofScreen;
- CameraProofScreen -> UploadingProofScreen -> ChallengeCompleteScreen;
- Profile -> Settings -> Edit Profile.

### 3.4.3 Текстово описание на flow диаграма

Потокът на потребителя може да бъде описан със следната текстова диаграма:

1. Потребителят стартира приложението.
2. Зареждат се локални настройки и начални данни.
3. Ако onboarding не е преминат, потребителят преминава през четири уводни страници и заявява разрешения.
4. Следва вход или регистрация.
5. След успешна аутентикация се отваря началният екран.
6. Потребителят избира предизвикателство от Home или Map.
7. Предизвикателството се стартира и става активно.
8. Потребителят отваря навигация до обекта.
9. При опит за завършване системата извършва GPS проверка.
10. При успешно достигане се отваря камерата.
11. Заснетата снимка преминава през екран за потвърждение и симулирано качване.
12. Системата приключва предизвикателството и обновява точки, ниво, серия, постижения и класация.
13. Потребителят може да разгледа профила и лидерборда.

## 3.5 Архитектура

### 3.5.1 Използван архитектурен подход

Проектът използва **слойна архитектура**, базирана на:
- **Provider** за dependency propagation в дървото на widget-ите;
- **ChangeNotifier** за централизирано състояние чрез `AppState`;
- отделяне на UI, услуги, модели, домейн логика, локално хранилище и backend интеграция.

Не се използват BLoC, Riverpod или Redux. Централният оркестратор на клиентската логика е класът `AppState`.

### 3.5.2 Структура на папките

Основната клиентска структура в `lib/` е:
- `data/` – начални/mock данни;
- `db/` – локална база данни;
- `domain/` – домейн правила и каталози;
- `l10n/` – локализация;
- `models/` – модели на данни;
- `repositories/` – локална домейн/данни логика;
- `screens/` – екранни модули;
- `services/` – външни услуги и интеграции;
- `state/` – глобално състояние;
- `theme/` – теми и стилове;
- `widgets/` – споделени UI компоненти.

Backend структурата е разделена в:
- `functions/src/` – Firebase Functions код;
- `functions/test/` – backend тестове;
- `test/` – Flutter тестове.

### 3.5.3 Разделение на отговорностите

Разделението на отговорностите е следното:
- **UI слой** – екраните визуализират състоянието и подават потребителски действия;
- **State слой (`AppState`)** – координира аутентикация, локални настройки, backend заявки и обновяване на изгледа;
- **Services слой** – реализира достъп до външни API/SDK (`AppAuthService`, `DirectionsService`, `LocationService`, `PushNotificationService`);
- **Repository слой** – реализира локална бизнес логика и работа с SQLite (`GeoRepository`);
- **Domain слой** – съдържа правила за ниво, постижения и помощни функции;
- **Backend слой** – callable functions, защита, синхронизация и push jobs.

### 3.5.4 Текстово описание на компонентна диаграма

Компонентната диаграма на системата може да бъде описана така:

- Компонент **Flutter UI** съдържа екраните и widget-ите.
- Компонент **AppState** стои между UI и източниците на данни.
- Компонент **Services** предоставя достъп до Firebase Auth, Functions, Google Directions API, GPS, камера и push известия.
- Компонент **GeoRepository + SQLite** осигурява локални операции и fallback поведение.
- Компонент **Firebase Functions backend** обработва сигурни сървърни операции по синхронизация, лидерборд, постижения и известия.
- Външните зависимости са **Google Maps/Directions API**, **Firebase Authentication**, **Firebase Messaging** и **локалното устройство** (камера, позиция, настройки).

# 4. Реализация

## 4.1 Реализация на общия дизайн в кода

Проектираната логика е имплементирана чрез централен клас `AppState`, който се създава асинхронно още при стартиране на приложението. Той зарежда `SharedPreferences`, настройва тема и локализация, преценява началния маршрут и при нужда извършва backend синхронизация.

Ключов момент е, че UI слоят не достъпва директно backend или базата. Вместо това екраните използват `context.watch<AppState>()` и `context.read<AppState>()`, а `AppState` на свой ред делегира към услуги и репозитории.

## 4.2 Реални кодови откъси от проекта

### 4.2.1 Модел на данни

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
```

Този модел показва, че профилът не е ограничен до идентификационни данни, а пази и показатели за геймификация – ниво, точки, серия и брой значки.

### 4.2.2 State management

```dart
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
      onGenerateRoute: _route,
    ),
  ),
);
```

Този откъс показва, че `AppState` е глобалният източник на истина за темата, езика и навигационната логика.

### 4.2.3 UI widget

```dart
class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({required this.challenge, super.key});
  final Challenge challenge;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PrimaryCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.pushNamed(context, '/challenge/${challenge.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadius.lg),
            ),
            child: Image.asset(
              challenge.imageAsset,
              width: 132,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    l.dailyChallengeDistanceAway(
                      challenge.distanceKm.toString(),
                    ),
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Откъсът показва, че началният екран работи с реални обекти `Challenge` и използва маршрутизация към детайлен екран.

### 4.2.4 Карта

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

Картата поддържа маркери, полилинии, собствен стил и локация на потребителя. Това потвърждава, че картният модул е съществена функционална част, а не декоративен елемент.

### 4.2.5 Логика на маркерите

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

От този код се вижда, че визуализацията на маркерите зависи от категорията, трудността и статуса на предизвикателството. По този начин картата комуникира състоянието и без да се отваря отделен детайлен екран.

### 4.2.6 GPS и проверка на местоположение

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

Този откъс е съществен, защото показва реалната бизнес проверка за завършване на задача. Предизвикателство не може да бъде завършено само чрез натискане на бутон; необходимо е физическо доближаване до целта.

### 4.2.7 Извличане на маршрут

```dart
Future<RouteResult?> route({
  required LatLng origin,
  required LatLng destination,
}) async {
  final key = await AppConfigService.googleMapsApiKey();
  if (key.isEmpty) return null;
  final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
    'origin': '${origin.latitude},${origin.longitude}',
    'destination': '${destination.latitude},${destination.longitude}',
    'mode': 'walking',
    'key': key,
  });
  final response = await http.get(uri);
  if (response.statusCode != 200) return null;
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  if (json['status'] != 'OK') return null;
```

Тук е реализирана интеграция с Google Directions API за пешеходна навигация.

### 4.2.8 Backend защита

```ts
export function requireAuthenticatedUid(auth: CallableAuth): string {
  if (typeof auth?.uid !== 'string' || auth.uid.trim().length === 0) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }
  return auth.uid;
}
```

Това е важен откъс от backend-а, защото показва, че user-scoped операции вече се изпълняват само за реално аутентикиран потребител.

## 4.3 Реализация на бизнес логиката

### 4.3.1 Централно състояние

`AppState` обединява следните отговорности:
- зареждане на локални предпочитания;
- управление на тема и локализация;
- аутентикация;
- изтегляне на публични или персонализирани данни;
- стартиране и завършване на предизвикателства;
- обновяване на профил;
- управление на push настройки;
- обновяване на UI чрез `notifyListeners()`.

Логиката е разделена според контекста:
- при аутентикиран потребител се използва backend;
- при неаутентикиран или тестов контекст има локален fallback.

### 4.3.2 Логика за прогрес и нива

В `lib/domain/progression.dart` нивото се изчислява по проста и ясна формула:

```dart
int levelForPoints(int points) => 1 + (points ~/ 250);
int nextLevelPointsForPoints(int points) => levelForPoints(points) * 250;
```

Това означава, че на всеки 250 точки потребителят преминава към следващо ниво.

### 4.3.3 Логика за активни предизвикателства

И в локалния repository, и в backend store е имплементирана бизнес логика, според която потребителят има само едно активно предизвикателство. При стартиране на ново активно такова, предишното се маркира като `abandoned`.

### 4.3.4 Логика за серия и постижения

`GeoRepository` и backend `FirestoreStore` поддържат:
- текуща серия от последователни дни;
- най-добра серия;
- прогрес към постижения по брой завършени задачи, категория и серия;
- автоматично отключване на постижения и увеличаване на броя на значките.

## 4.4 Валидация

Валидацията е реализирана на няколко нива.

### 4.4.1 Клиентска валидация
- при регистрация се проверява съвпадение на паролите;
- при редакция на профил се валидира непразно име;
- email адресът се валидира чрез регулярен израз;
- при завършване на challenge се валидира GPS близостта до целта;
- разрешенията за камера, локация и известия се проверяват и/или заявяват преди съответните операции.

Пример за реална клиентска валидация:

```dart
final ok = RegExp(
  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
).hasMatch(email);
return ok ? null : l.pleaseEnterValidEmail;
```

### 4.4.2 Backend валидация

В `functions/src/index.ts` и свързаните handler-и се валидират:
- налична аутентикация;
- задължителни параметри като `challengeId`, `token`, `prefs`;
- коректност на latitude/longitude;
- ограничение на `limit` при лидерборд.

## 4.5 Обработка на грешки

Обработката на грешки е реализирана последователно в няколко слоя.

### 4.5.1 try/catch в клиентския код

Има реални `try/catch` блокове в:
- `LocationService` – при GPS проверка;
- `CameraProofScreen` – при инициализация и заснемане;
- `PushNotificationService` – при инициализация на Firebase Messaging;
- `AppState` – при backend операции като `startChallenge`, `markRouteShown`, `completeChallenge`;
- `DirectionsService` – чрез проверка на HTTP статус и JSON статус.

### 4.5.2 Поведение при отказани разрешения

При липса на разрешение за локация приложението връща статус `locationPermissionRequired`. В `SettingsScreen` при permanently denied състояние се отварят системните настройки на устройството.

### 4.5.3 Поведение при backend проблем

При грешка в backend повикване `AppState` записва `syncError`, а в някои локални режими преминава към fallback логика. Това е полезно за устойчивост на приложението в разработваща среда.

# 5. Потребителско ръководство

## 5.1 Стартиране на приложението

1. Потребителят стартира GeoQuest.
2. Появява се начален splash екран, докато се заредят локалните настройки и началните данни.
3. Ако приложението се отваря за първи път, потребителят преминава през onboarding.

## 5.2 Преминаване през onboarding

1. Показват се четири последователни информационни страници.
2. На екрана за разрешения приложението заявява достъп до:
   - местоположение;
   - камера;
   - известия.
3. След последната страница потребителят избира „Get Started“ и се пренасочва към екрана за вход.

## 5.3 Вход и регистрация

1. Потребителят може да избере регистрация или вход.
2. При регистрация въвежда име, email и парола.
3. При вход може да използва email/password или Google профил.
4. При успешна аутентикация се отваря началният екран `/home`.

## 5.4 Разглеждане на предизвикателства

### 5.4.1 От началния екран
1. На Home екрана се виждат:
   - текуща серия;
   - дневно предизвикателство;
   - следващо постижение;
   - близки предизвикателства;
   - категории;
   - обобщение на прогреса.
2. При избор на карта или конкретна карта от категориите потребителят преминава към `MapScreen`.

### 5.4.2 От картата
1. Потребителят отваря карта или списък.
2. При нужда задава филтри по категория, трудност и дистанция.
3. Избира маркер или елемент от списъка.
4. Отваря се детайлен изглед на предизвикателството или предварителен bottom sheet.

## 5.5 Стартиране на предизвикателство

1. В детайлния екран потребителят избира „Start Challenge“.
2. Приложението запазва предизвикателството като активно.
3. Отваря се `ChallengeStartedScreen`, който показва основна информация за началото на задачата.
4. Потребителят избира „Start Navigation“.

## 5.6 Навигация

1. Приложението отваря картата в navigation mode.
2. Ако има наличен Google Maps API ключ, се извлича пешеходен маршрут.
3. Показва се полилиния между текущата локация и целевата точка.
4. Потребителят се придвижва до мястото на предизвикателството.

## 5.7 Завършване на предизвикателство

1. От екрана с детайли на активното предизвикателство потребителят избира „Complete Challenge“.
2. Приложението проверява чрез GPS дали потребителят е в радиус до 100 метра от целевата локация.
3. Ако потребителят е твърде далеч, се показва съобщение с приблизителна дистанция.
4. Ако разрешението за местоположение липсва, се показва съответно уведомление.
5. Ако локацията е достигната, се отваря `CameraProofScreen`.
6. Потребителят прави снимка или я повтаря.
7. След потвърждение се отваря `UploadingProofScreen`.
8. След успешна обработка приложението отваря `ChallengeCompleteScreen`.

## 5.8 Преглед на профил и класация

### 5.8.1 Профил
1. Потребителят отваря таб „Profile“.
2. Вижда име, аватар, ниво, прогрес към следващо ниво, статистики и списъци с постижения.
3. От бутона за настройки отваря `SettingsScreen`.
4. Оттам може да премине към `EditProfileScreen` и да промени име, email и снимка.

### 5.8.2 Лидерборд
1. Потребителят отваря таб „Leaderboard“.
2. Вижда подиум за първите три места.
3. Преглежда останалите позиции.
4. В долната част се визуализира собствената му текуща позиция.

## 5.9 Настройки

1. От Settings екрана потребителят може да:
   - смени езика между български и английски;
   - включи или изключи тъмна тема;
   - прегледа и обнови разрешенията;
   - редактира профил;
   - излезе от акаунта.

# 6. Заключение

На база на реално реализирания код може да се заключи, че приложението изпълнява основната си цел: предоставя мобилна среда за откриване и изпълнение на географски базирани предизвикателства с карта, GPS проверка и игрови механики. Проектът покрива пълен потребителски цикъл – от onboarding и аутентикация до стартиране, навигация, завършване и отчитане на прогрес.

Основните силни страни на проекта са:
- ясна и добре обособена архитектура с `Provider` и `ChangeNotifier`;
- добро разделение между UI, state, services, repository и backend;
- реална интеграция с карта, GPS, камера и Firebase;
- логически завършен поток за challenge lifecycle;
- наличие на геймификационни механики – точки, нива, серии, постижения, класация;
- локализация и настройки за персонализация.

Основните ограничения на текущата реализация са:
- част от функционалността е подготвена, но не е завършена напълно (търсене, forgot password, bio, photo accepted flow);
- доказателствената снимка не се качва към специализирано файлово хранилище;
- маршрутът зависи от наличен външен API ключ;
- конфигурацията по подразбиране е ориентирана към Firebase емулатори;
- някои публични данни и локални fallback сценарии са налице, което е полезно за разработка, но изисква ясно разграничаване при продукционна среда.

Възможни бъдещи подобрения, произтичащи естествено от текущата кодова база, са:
- завършване на реално търсене в картата;
- имплементация на „Forgot password“ поток;
- реално качване на снимки в cloud storage;
- по-пълно производство на backend конфигурация извън емулаторен режим;
- доразвиване на профилната информация и редакция на допълнителни полета;
- по-усъвършенствана геопространствена селекция на nearby challenges.

Като обобщение, GeoQuest представлява успешна и последователна университетска разработка, която демонстрира практически умения по мобилна разработка, работа с външни API, локално и отдалечено съхранение на данни, управление на състояние и проектиране на потребителски поток.

# 7. Приложение

## 7.1 Важни кодови откъси

### Откъс 1: локална база данни

```dart
await db.execute(
  'CREATE TABLE challenge_progress(userId TEXT NOT NULL, challengeId TEXT NOT NULL, status TEXT NOT NULL, startedAt TEXT, completedAt TEXT, lastRouteShownAt TEXT, proofPath TEXT, PRIMARY KEY(userId, challengeId))',
);
await db.execute(
  'CREATE TABLE user_achievements(userId TEXT NOT NULL, achievementId TEXT NOT NULL, unlockedAt TEXT NOT NULL, PRIMARY KEY(userId, achievementId))',
);
```

### Откъс 2: backend callable функции

```ts
export const startChallenge = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as { challengeId?: string };
  if (!data.challengeId) {
    throw new HttpsError('invalid-argument', 'challengeId required.');
  }
  return startChallengeHandler(store, {
    uid,
    challengeId: data.challengeId,
  });
});
```

### Откъс 3: завършване на challenge от екрана за качване

```dart
final awarded = await context.read<AppState>().completeChallengeAndAward(
  challengeId: widget.challenge.id,
  proofPath: widget.proofPath,
);
if (!mounted) return;
if (!awarded) {
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l.settingsSyncFailed)));
  return;
}
Navigator.pushReplacementNamed(
  context,
  '/challenge-complete/${widget.challenge.id}',
);
```

## 7.2 Основни класове и файлове

### Клиентска част
- `lib/main.dart` – входна точка, инициализация, `MaterialApp`, routing;
- `lib/state/app_state.dart` – централизирано състояние на приложението;
- `lib/models/geo_models.dart` – основни модели;
- `lib/db/app_database.dart` – SQLite схема и seed данни;
- `lib/repositories/geo_repository.dart` – локална бизнес логика и локален прогрес;
- `lib/services/app_auth_service.dart` – Firebase Auth и Google Sign-In;
- `lib/services/firebase_backend_client.dart` – клиент към callable functions;
- `lib/services/location_service.dart` – GPS проверка;
- `lib/services/directions_service.dart` – маршрут от Google Directions API;
- `lib/services/push_notification_service.dart` – Firebase Messaging;
- `lib/screens/home/home_screen.dart` – начален екран;
- `lib/screens/map/map_screen.dart` – карта, списък, филтри и навигационен режим;
- `lib/screens/map/geo_map_view.dart` – реална карта, маркери, clustering, route polyline;
- `lib/screens/challenge/challenge_detail_screen.dart` – детайли и завършване;
- `lib/screens/challenge/camera_proof_screen.dart` – снимка за доказателство;
- `lib/screens/challenge/uploading_proof_screen.dart` – обработка при приключване;
- `lib/screens/profile/profile_screen.dart` – профил и статистики;
- `lib/screens/profile/edit_profile_screen.dart` – редакция на профил;
- `lib/screens/profile/settings_screen.dart` – настройки и разрешения.

### Backend част
- `functions/src/index.ts` – експортира callable functions и scheduler triggers;
- `functions/src/auth.ts` – backend проверки за аутентикация и операторски достъп;
- `functions/src/handlers.ts` – обработка на конкретни операции;
- `functions/src/store.ts` – Firestore логика за потребител, challenge progress, leaderboard и achievements;
- `functions/src/contracts.ts` – модели/договори за backend записи;
- `functions/src/notifications.ts` – push известия и периодични jobs.

## 7.3 Обобщено текстово описание на системата

Системата може да бъде резюмирана като мобилно приложение с многослойна архитектура, в което Flutter UI визуализира карта и предизвикателства, `AppState` управлява състоянието и координацията, локалният repository и SQLite осигуряват локална логика и fallback режим, а Firebase backend предоставя защитена синхронизация, прогрес и известия. В резултат се реализира пълен цикъл за геолокационно предизвикателство, завършващ с обновяване на потребителския профил и класацията.
