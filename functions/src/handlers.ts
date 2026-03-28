import {
  AchievementCatalogRecord,
  AchievementViewRecord,
  AppStateRecord,
  ChallengeProgressRecord,
  ChallengeRecord,
  LeaderboardRecord,
  NotificationPrefsRecord,
  UserAchievementRecord,
  UserProfileRecord,
} from './contracts';
import { FirestoreStore } from './store';

const nowIso = () => new Date().toISOString();

export interface SyncUserProfileInput {
  uid: string;
  name: string;
  email: string;
  initials: string;
  avatarPath?: string | null;
}

export interface UpdateProfileInput {
  uid: string;
  name: string;
  email: string;
  initials: string;
  avatarPath?: string | null;
}

export interface RegisterPushTokenInput {
  uid: string;
  token: string;
  platform?: string | null;
  locale?: string | null;
}

export interface UpdateNotificationPrefsInput {
  uid: string;
  prefs: Partial<NotificationPrefsRecord>;
}

export interface UpdateUserLocationInput {
  uid: string;
  latitude: number;
  longitude: number;
  recordedAt?: string;
}

export interface StartChallengeInput {
  uid: string;
  challengeId: string;
}

export interface CompleteChallengeInput {
  uid: string;
  challengeId: string;
  proofPath?: string | null;
}

export interface MarkRouteShownInput {
  uid: string;
  challengeId: string;
}

function formatUnlockedDate(value: string): string {
  const date = new Date(value);
  const day = String(date.getUTCDate()).padStart(2, '0');
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const year = date.getUTCFullYear();
  return `${day}/${month}/${year}`;
}

function normalizeCategory(value: string): string {
  const lower = value.trim().toLowerCase();
  switch (lower) {
    case 'culture':
    case 'cultural':
      return 'cultural';
    case 'nature':
      return 'nature';
    case 'historical':
    case 'history':
      return 'historical';
    case 'adventure':
      return 'adventure';
    default:
      return lower;
  }
}

function achievementProgress(input: {
  user: UserProfileRecord;
  completedChallenges: ChallengeRecord[];
}): Record<string, number> {
  const safeCompleted = finiteOr(input.user.completed, 0);
  const safeStreak = finiteOr(input.user.currentStreak, 0);
  const categories = new Set(input.completedChallenges.map((challenge) => normalizeCategory(challenge.category)));
  return {
    first_challenge: safeCompleted > 0 ? 1 : 0,
    five_challenges: Math.min(5, safeCompleted),
    first_nature: categories.has('nature') ? 1 : 0,
    first_cultural: categories.has('cultural') ? 1 : 0,
    first_historical: categories.has('historical') ? 1 : 0,
    first_adventure: categories.has('adventure') ? 1 : 0,
    three_day_streak: Math.min(3, safeStreak),
  };
}

function toAchievementViews(input: {
  catalog: AchievementCatalogRecord[];
  unlocked: UserAchievementRecord[];
  progress: Record<string, number>;
}): { unlockedAchievements: AchievementViewRecord[]; achievementsInProgress: AchievementViewRecord[] } {
  const unlockedById = new Map(input.unlocked.map((item) => [item.achievementId, item]));

  const unlockedAchievements = input.catalog
    .filter((achievement) => unlockedById.has(achievement.id))
    .map((achievement) => ({
      title: achievement.title,
      subtitle: achievement.subtitle,
      icon: achievement.icon,
      rewardPoints: achievement.rewardPoints,
      progress: achievement.total,
      total: achievement.total,
      unlocked: formatUnlockedDate(unlockedById.get(achievement.id)!.unlockedAt),
    }))
    .sort((a, b) => b.unlocked.localeCompare(a.unlocked));

  const achievementsInProgress = input.catalog
    .filter((achievement) => !unlockedById.has(achievement.id))
    .map((achievement) => ({
      title: achievement.title,
      subtitle: achievement.subtitle,
      icon: achievement.icon,
      rewardPoints: achievement.rewardPoints,
      progress: finiteOr(
        Math.min(achievement.total, input.progress[achievement.id] ?? 0),
        0,
      ),
      total: achievement.total,
      unlocked: '',
    }))
    .sort((a, b) => {
      const aRemaining = a.total - a.progress;
      const bRemaining = b.total - b.progress;
      if (aRemaining !== bRemaining) return aRemaining - bRemaining;
      return a.title.localeCompare(b.title);
    });

  return { unlockedAchievements, achievementsInProgress };
}

function toLeaderboard(users: UserProfileRecord[], limit: number): LeaderboardRecord[] {
  return users.slice(0, limit).map((user, index) => ({
    uid: user.uid,
    name: user.name,
    initials: user.initials,
    level: user.level,
    completed: user.completed,
    points: user.points,
    rank: index + 1,
    updatedAt: user.updatedAt,
  }));
}

function toActiveChallengeState(progress: ChallengeProgressRecord | undefined) {
  if (!progress || progress.status !== 'active') return null;
  return {
    challengeId: progress.challengeId,
    startedAt: progress.startedAt,
    status: progress.status,
    lastRouteShownAt: progress.lastRouteShownAt ?? null,
  };
}

function dailyChallengeId(challenges: ChallengeRecord[]): string | null {
  if (challenges.length === 0) return null;
  const dayOfYear = Math.floor((Date.now() - Date.UTC(new Date().getUTCFullYear(), 0, 0)) / 86400000);
  return challenges[dayOfYear % challenges.length]?.id ?? challenges[0].id;
}

const finiteOr = (value: unknown, fallback: number): number => {
  const n = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(n) ? n : fallback;
};

function sanitizeUser(user: UserProfileRecord): UserProfileRecord {
  const rawLat = user.lastLocation?.latitude;
  const rawLng = user.lastLocation?.longitude;
  const hasValidRawLocation = Number.isFinite(rawLat) && Number.isFinite(rawLng);
  const lastLocation = user.lastLocation == null
    ? null
    : {
        latitude: finiteOr(user.lastLocation.latitude, 0),
        longitude: finiteOr(user.lastLocation.longitude, 0),
        recordedAt: user.lastLocation.recordedAt,
      };

  return {
    ...user,
    level: finiteOr(user.level, 1),
    points: finiteOr(user.points, 0),
    nextLevelPoints: finiteOr(user.nextLevelPoints, 250),
    completed: finiteOr(user.completed, 0),
    badges: finiteOr(user.badges, 0),
    bestStreak: finiteOr(user.bestStreak, 0),
    currentStreak: finiteOr(user.currentStreak, 0),
    lastLocation: hasValidRawLocation ? lastLocation : null,
  };
}

function sanitizeChallenge(challenge: ChallengeRecord): ChallengeRecord {
  return {
    ...challenge,
    distanceKm: finiteOr(challenge.distanceKm, 0),
    points: finiteOr(challenge.points, 0),
    latitude: finiteOr(challenge.latitude, 0),
    longitude: finiteOr(challenge.longitude, 0),
    explorersCompleted: finiteOr(challenge.explorersCompleted, 0),
  };
}

export async function getAppStateHandler(
  store: FirestoreStore,
  input: { uid: string; profileDefaults?: Partial<Pick<UserProfileRecord, 'name' | 'email' | 'initials' | 'avatarPath'>> },
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  const { uid } = input;
  await store.touchUserActivity(uid);
  const user = sanitizeUser(
    await store.getOrCreateUser(uid, input.profileDefaults),
  );
  const [challenges, leaderboardUsers, progressItems, catalog, unlocked] = await Promise.all([
    store.listChallenges(),
    store.listLeaderboard(50),
    store.listChallengeProgress(uid),
    store.listAchievementCatalog(),
    store.listUserAchievements(uid),
  ]);

  const completedIds = progressItems
    .filter((item) => item.status === 'completed')
    .map((item) => item.challengeId);
  const completedChallenges = challenges.filter((challenge) => completedIds.includes(challenge.id));
  const progress = achievementProgress({ user, completedChallenges });
  const achievementViews = toAchievementViews({ catalog, unlocked, progress });

  const safeUser = sanitizeUser(user);
  const safeChallenges = challenges.map(sanitizeChallenge);
  const safeLeaderboardUsers = leaderboardUsers.map(sanitizeUser);

  const sortedChallenges = [...safeChallenges].sort((a, b) => a.distanceKm - b.distanceKm || a.title.localeCompare(b.title));
  const nearbyChallengeIds = sortedChallenges.slice(0, 3).map((challenge) => challenge.id);
  const categories = Array.from(new Set(safeChallenges.map((challenge) => challenge.category)));

  return {
    user: safeUser,
    challenges: safeChallenges,
    leaderboard: toLeaderboard(safeLeaderboardUsers, 50),
    activeChallengeState: toActiveChallengeState(progressItems.find((item) => item.status === 'active')),
    completedChallengeIds: completedIds,
    achievementsInProgress: achievementViews.achievementsInProgress,
    unlockedAchievements: achievementViews.unlockedAchievements,
    dailyChallengeId: dailyChallengeId(sortedChallenges),
    nearbyChallengeIds,
    categories,
    filterOptions: {
      categories,
      difficulties: ['easy', 'medium', 'hard'],
      maxDistancesKm: [1, 5, 10, 25],
    },
  };
}

export async function syncUserProfileHandler(
  store: FirestoreStore,
  input: SyncUserProfileInput,
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  await store.touchUserActivity(input.uid);
  await store.upsertUserProfile({
    uid: input.uid,
    name: input.name,
    email: input.email,
    initials: input.initials,
    avatarPath: input.avatarPath ?? null,
  });
  return getAppStateHandler(store, { uid: input.uid });
}

export async function updateProfileHandler(
  store: FirestoreStore,
  input: UpdateProfileInput,
): Promise<{ user: UserProfileRecord }> {
  await store.ensureDemoSeeded();
  const user = await store.upsertUserProfile({
    uid: input.uid,
    name: input.name,
    email: input.email,
    initials: input.initials,
    avatarPath: input.avatarPath ?? null,
  });
  return { user };
}

export async function startChallengeHandler(
  store: FirestoreStore,
  input: StartChallengeInput,
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  await store.touchUserActivity(input.uid);
  await store.startChallenge(input.uid, input.challengeId);
  return getAppStateHandler(store, { uid: input.uid });
}

export async function markRouteShownHandler(
  store: FirestoreStore,
  input: MarkRouteShownInput,
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  await store.touchUserActivity(input.uid);
  await store.markRouteShown(input.uid, input.challengeId);
  return getAppStateHandler(store, { uid: input.uid });
}

export async function completeChallengeHandler(
  store: FirestoreStore,
  input: CompleteChallengeInput,
): Promise<{
  awarded: boolean;
  state: AppStateRecord;
  newUnlocks: AchievementViewRecord[];
  pointsDelta: number;
  streakDelta: number;
  rankDelta: number;
}> {
  await store.ensureDemoSeeded();
  const before = await getAppStateHandler(store, { uid: input.uid });
  const awarded = await store.completeChallenge(
    input.uid,
    input.challengeId,
    input.proofPath ?? null,
  );
  const state = await getAppStateHandler(store, { uid: input.uid });
  const beforeUnlocks = new Set(before.unlockedAchievements.map((a) => a.title));
  const newUnlocks = state.unlockedAchievements.filter((a) => !beforeUnlocks.has(a.title));
  return {
    awarded,
    state,
    newUnlocks,
    pointsDelta: state.user.points - before.user.points,
    streakDelta: state.user.currentStreak - before.user.currentStreak,
    rankDelta: 0,
  };
}

export async function registerPushTokenHandler(
  store: FirestoreStore,
  input: RegisterPushTokenInput,
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  await store.upsertPushToken({
    uid: input.uid,
    token: input.token,
    platform: input.platform ?? null,
    locale: input.locale ?? null,
  });
  return getAppStateHandler(store, { uid: input.uid });
}

export async function updateNotificationPrefsHandler(
  store: FirestoreStore,
  input: UpdateNotificationPrefsInput,
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  await store.updateNotificationPrefs(input.uid, input.prefs);
  return getAppStateHandler(store, { uid: input.uid });
}

export async function updateUserLocationHandler(
  store: FirestoreStore,
  input: UpdateUserLocationInput,
): Promise<AppStateRecord> {
  await store.ensureDemoSeeded();
  await store.upsertUserLocation({
    uid: input.uid,
    latitude: input.latitude,
    longitude: input.longitude,
    recordedAt: input.recordedAt,
  });
  return getAppStateHandler(store, { uid: input.uid });
}

export async function getLeaderboardHandler(
  store: FirestoreStore,
  limit = 50,
): Promise<LeaderboardRecord[]> {
  await store.ensureDemoSeeded();
  const users = await store.listLeaderboard(limit);
  return toLeaderboard(users, limit);
}

export async function getChallengesHandler(
  store: FirestoreStore,
): Promise<ChallengeRecord[]> {
  await store.ensureDemoSeeded();
  return store.listChallenges();
}
