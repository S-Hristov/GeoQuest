import * as admin from 'firebase-admin';
import { FieldValue } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';

import {
  AchievementCatalogRecord,
  ChallengeProgressRecord,
  ChallengeRecord,
  NotificationPrefsRecord,
  UserAchievementRecord,
  UserPushRecord,
  UserProfileRecord,
} from './contracts';
import {
  defaultDemoUid,
  demoAchievementCatalog,
  demoChallengeProgress,
  demoChallenges,
  demoUserAchievements,
  demoUsers,
} from './demo_data';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

const levelForPoints = (points: number) => 1 + Math.floor(points / 250);
const nextLevelPointsForPoints = (points: number) => levelForPoints(points) * 250;
const nowIso = () => new Date().toISOString();
const progressDocId = (uid: string, challengeId: string) => `${uid}_${challengeId}`;
const userAchievementDocId = (uid: string, achievementId: string) => `${uid}_${achievementId}`;
const challengeCompletionRadiusKm = 0.25;

const defaultNotificationPrefs = (): NotificationPrefsRecord => ({
  dailyChallenge: true,
  nearbyNudges: true,
  streakRisk: true,
  streakMilestones: true,
  achievementUnlocks: true,
  completionSummary: true,
  newChallenges: true,
  weeklyRecap: true,
  leaderboardPass: true,
  reEngagement: true,
  ops: true,
});

const defaultPushState = (): UserPushRecord => ({
  token: null,
  platform: null,
  locale: null,
  tokenUpdatedAt: null,
  lastDailyAt: null,
  lastNearbyAt: null,
  lastStreakRiskAt: null,
  lastWeeklyAt: null,
  lastReengagementAt: null,
  lastLeaderboardRank: null,
});

export function isDemoSeedingEnabled(
  env: NodeJS.ProcessEnv = process.env,
): boolean {
  return env.FUNCTIONS_EMULATOR === 'true' ||
    typeof env.FIRESTORE_EMULATOR_HOST === 'string' ||
    env.GEOQUEST_ENABLE_DEMO_SEED === 'true';
}

function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const r = 6371.0;
  const toRad = (deg: number) => deg * Math.PI / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export function normalizeProofPath(uid: string, proofPath?: string | null): string | null {
  if (proofPath == null) return null;
  const trimmed = proofPath.trim();
  if (trimmed.length === 0) return null;
  const basename = trimmed.split(/[\\/]/).filter(Boolean).pop();
  if (!basename) {
    throw new HttpsError('invalid-argument', 'proofPath must reference a file name.');
  }
  if (!/^[A-Za-z0-9._-]+\.(?:jpg|jpeg|png|heic|webp)$/i.test(basename)) {
    throw new HttpsError('invalid-argument', 'proofPath must reference a supported image file.');
  }
  return `proofs/${uid}/${basename}`;
}

export function assertChallengeCompletionEligibility(input: {
  uid: string;
  challenge: ChallengeRecord;
  user: Pick<UserProfileRecord, 'lastLocation'>;
  progress: ChallengeProgressRecord | null;
  proofPath?: string | null;
}): string | null {
  if (input.progress == null) {
    throw new HttpsError('failed-precondition', 'Start the challenge before completing it.');
  }
  if (input.progress.status !== 'active') {
    throw new HttpsError('failed-precondition', 'Only the active challenge can be completed.');
  }
  const lastLocation = input.user.lastLocation;
  if (lastLocation == null) {
    throw new HttpsError('failed-precondition', 'Location update required before completing challenge.');
  }
  if (!Number.isFinite(lastLocation.latitude) || !Number.isFinite(lastLocation.longitude)) {
    throw new HttpsError('invalid-argument', 'Stored user location is invalid.');
  }
  const distanceKm = haversineKm(
    lastLocation.latitude,
    lastLocation.longitude,
    input.challenge.latitude,
    input.challenge.longitude,
  );
  if (distanceKm > challengeCompletionRadiusKm) {
    throw new HttpsError(
      'failed-precondition',
      `User is too far from challenge location (${distanceKm.toFixed(2)}km).`,
    );
  }
  return normalizeProofPath(input.uid, input.proofPath);
}

export class FirestoreStore {
  private seedPromise: Promise<void> | null = null;

  async ensureDemoSeeded(): Promise<void> {
    if (!isDemoSeedingEnabled()) return;
    this.seedPromise ??= this.seedDemoDataIfNeeded();
    await this.seedPromise;
  }

  private async seedDemoDataIfNeeded(): Promise<void> {
    const requiredChallengeSnap = await db.collection('challenges').doc('test-inergy-borovo').get();
    const shouldSeedAll = !requiredChallengeSnap.exists;
    const batch = db.batch();
    for (const achievement of demoAchievementCatalog) {
      batch.set(db.collection('achievementCatalog').doc(achievement.id), achievement, { merge: true });
    }
    if (shouldSeedAll) {
      for (const challenge of demoChallenges) {
        batch.set(db.collection('challenges').doc(challenge.id), challenge);
      }
      for (const user of demoUsers) {
        batch.set(db.collection('users').doc(user.uid), user, { merge: true });
      }
      for (const progress of demoChallengeProgress) {
        batch.set(
          db.collection('challengeProgress').doc(progressDocId(progress.uid, progress.challengeId)),
          progress,
        );
      }
      for (const unlock of demoUserAchievements) {
        batch.set(
          db.collection('userAchievements').doc(userAchievementDocId(unlock.uid, unlock.achievementId)),
          unlock,
        );
      }
    }
    await batch.commit();
  }

  async getOrCreateUser(
    uid: string,
    defaults?: Partial<Pick<UserProfileRecord, 'name' | 'email' | 'initials' | 'avatarPath'>>,
  ): Promise<UserProfileRecord> {
    const existing = await this.getUser(uid);
    if (existing) {
      const hydrated: UserProfileRecord = {
        uid: existing.uid || uid,
        name: existing.name?.trim() || defaults?.name?.trim() || (uid === defaultDemoUid ? 'Alex Petrov' : 'Demo Explorer'),
        email: existing.email?.trim() || defaults?.email?.trim() || `${uid}@example.com`,
        initials: (existing.initials?.trim() || defaults?.initials?.trim() || 'DE').toUpperCase(),
        points: Number.isFinite(existing.points) ? existing.points : 0,
        level: Number.isFinite(existing.level) ? existing.level : 1,
        nextLevelPoints: Number.isFinite(existing.nextLevelPoints) ? existing.nextLevelPoints : 250,
        completed: Number.isFinite(existing.completed) ? existing.completed : 0,
        badges: Number.isFinite(existing.badges) ? existing.badges : 0,
        bestStreak: Number.isFinite(existing.bestStreak) ? existing.bestStreak : 0,
        currentStreak: Number.isFinite(existing.currentStreak) ? existing.currentStreak : 0,
        avatarPath: existing.avatarPath ?? defaults?.avatarPath ?? null,
        lastCompletedDate: existing.lastCompletedDate ?? null,
        lastActiveAt: existing.lastActiveAt ?? nowIso(),
        lastLocation: existing.lastLocation ?? null,
        notificationPrefs: existing.notificationPrefs ?? defaultNotificationPrefs(),
        push: existing.push ?? defaultPushState(),
        updatedAt: existing.updatedAt ?? nowIso(),
      };
      await db.collection('users').doc(uid).set(hydrated, { merge: true });
      return hydrated;
    }

    const profile: UserProfileRecord = {
      uid,
      name: defaults?.name?.trim() || (uid === defaultDemoUid ? 'Alex Petrov' : 'Demo Explorer'),
      email: defaults?.email?.trim() || `${uid}@example.com`,
      initials: (defaults?.initials?.trim() || 'DE').toUpperCase(),
      points: 0,
      level: 1,
      nextLevelPoints: 250,
      completed: 0,
      badges: 0,
      bestStreak: 0,
      currentStreak: 0,
      avatarPath: defaults?.avatarPath ?? null,
      lastCompletedDate: null,
      lastActiveAt: nowIso(),
      lastLocation: null,
      notificationPrefs: defaultNotificationPrefs(),
      push: defaultPushState(),
      updatedAt: nowIso(),
    };
    await db.collection('users').doc(uid).set(profile, { merge: true });
    return profile;
  }

  async getUser(uid: string): Promise<UserProfileRecord | null> {
    const snap = await db.collection('users').doc(uid).get();
    return snap.exists ? (snap.data() as UserProfileRecord) : null;
  }

  async upsertUserProfile(input: {
    uid: string;
    name: string;
    email: string;
    initials: string;
    avatarPath?: string | null;
  }): Promise<UserProfileRecord> {
    const current = await this.getOrCreateUser(input.uid, input);
    const next: UserProfileRecord = {
      ...current,
      name: input.name.trim(),
      email: input.email.trim(),
      initials: input.initials.trim().toUpperCase(),
      avatarPath: input.avatarPath ?? current.avatarPath ?? null,
      lastLocation: current.lastLocation ?? null,
      notificationPrefs: current.notificationPrefs ?? defaultNotificationPrefs(),
      push: current.push ?? defaultPushState(),
      updatedAt: nowIso(),
    };
    await db.collection('users').doc(input.uid).set(next, { merge: true });
    return next;
  }

  async listChallenges(): Promise<ChallengeRecord[]> {
    const snap = await db.collection('challenges').get();
    return snap.docs.map((doc) => doc.data() as ChallengeRecord);
  }

  async getChallenge(challengeId: string): Promise<ChallengeRecord | null> {
    const snap = await db.collection('challenges').doc(challengeId).get();
    return snap.exists ? (snap.data() as ChallengeRecord) : null;
  }

  async listChallengeProgress(uid: string): Promise<ChallengeProgressRecord[]> {
    const snap = await db.collection('challengeProgress').where('uid', '==', uid).get();
    return snap.docs.map((doc) => doc.data() as ChallengeProgressRecord);
  }

  async listAchievementCatalog(): Promise<AchievementCatalogRecord[]> {
    const snap = await db.collection('achievementCatalog').orderBy('sortOrder').get();
    return snap.docs.map((doc) => doc.data() as AchievementCatalogRecord);
  }

  async listUserAchievements(uid: string): Promise<UserAchievementRecord[]> {
    const snap = await db.collection('userAchievements').where('uid', '==', uid).get();
    return snap.docs.map((doc) => doc.data() as UserAchievementRecord);
  }

  async listLeaderboard(limit: number): Promise<UserProfileRecord[]> {
    const snap = await db.collection('users').get();
    return snap.docs
      .map((doc) => doc.data() as UserProfileRecord)
      .sort((a, b) => {
        const pointsCompare = b.points - a.points;
        if (pointsCompare !== 0) return pointsCompare;
        const completedCompare = b.completed - a.completed;
        if (completedCompare !== 0) return completedCompare;
        return a.name.localeCompare(b.name);
      })
      .slice(0, limit);
  }

  async upsertPushToken(input: {
    uid: string;
    token: string;
    platform?: string | null;
    locale?: string | null;
  }): Promise<void> {
    const user = await this.getOrCreateUser(input.uid);
    await db.collection('users').doc(input.uid).set(
      {
        push: {
          ...(user.push ?? defaultPushState()),
          token: input.token,
          platform: input.platform ?? user.push?.platform ?? null,
          locale: input.locale ?? user.push?.locale ?? null,
          tokenUpdatedAt: nowIso(),
        } satisfies UserPushRecord,
        lastActiveAt: nowIso(),
        updatedAt: nowIso(),
      } satisfies Partial<UserProfileRecord>,
      { merge: true },
    );
  }

  async updateNotificationPrefs(
    uid: string,
    partial: Partial<NotificationPrefsRecord>,
  ): Promise<UserProfileRecord> {
    const user = await this.getOrCreateUser(uid);
    const nextPrefs: NotificationPrefsRecord = {
      ...(user.notificationPrefs ?? defaultNotificationPrefs()),
      ...partial,
    };
    await db.collection('users').doc(uid).set(
      {
        notificationPrefs: nextPrefs,
        updatedAt: nowIso(),
      } satisfies Partial<UserProfileRecord>,
      { merge: true },
    );
    return (await this.getUser(uid)) as UserProfileRecord;
  }

  async touchUserActivity(uid: string): Promise<void> {
    await this.getOrCreateUser(uid);
    await db.collection('users').doc(uid).set(
      {
        lastActiveAt: nowIso(),
        updatedAt: nowIso(),
      } satisfies Partial<UserProfileRecord>,
      { merge: true },
    );
  }

  async upsertUserLocation(input: {
    uid: string;
    latitude: number;
    longitude: number;
    recordedAt?: string;
  }): Promise<void> {
    if (!Number.isFinite(input.latitude) || !Number.isFinite(input.longitude)) {
      throw new Error('Invalid user location payload.');
    }
    const user = await this.getOrCreateUser(input.uid);
    await db.collection('users').doc(input.uid).set(
      {
        lastLocation: {
          latitude: input.latitude,
          longitude: input.longitude,
          recordedAt: input.recordedAt ?? nowIso(),
        },
        notificationPrefs: user.notificationPrefs ?? defaultNotificationPrefs(),
        push: user.push ?? defaultPushState(),
        lastActiveAt: nowIso(),
        updatedAt: nowIso(),
      } satisfies Partial<UserProfileRecord>,
      { merge: true },
    );
  }

  async listUsersForPush(): Promise<UserProfileRecord[]> {
    const snap = await db.collection('users').get();
    return snap.docs
      .map((doc) => doc.data() as UserProfileRecord)
      .filter((user) => !!user.push?.token);
  }

  async markPushState(
    uid: string,
    partialPush: Partial<UserPushRecord>,
  ): Promise<void> {
    const user = await this.getOrCreateUser(uid);
    await db.collection('users').doc(uid).set(
      {
        push: {
          ...(user.push ?? defaultPushState()),
          ...partialPush,
        } satisfies UserPushRecord,
        updatedAt: nowIso(),
      } satisfies Partial<UserProfileRecord>,
      { merge: true },
    );
  }

  async startChallenge(uid: string, challengeId: string): Promise<void> {
    await db.runTransaction(async (tx) => {
      const challengeRef = db.collection('challenges').doc(challengeId);
      const challengeSnap = await tx.get(challengeRef);
      if (!challengeSnap.exists) {
        throw new HttpsError('not-found', `Challenge not found: ${challengeId}`);
      }
      const user = await this.getOrCreateUser(uid);
      void user;
      const challengeProgressRef = db.collection('challengeProgress').doc(progressDocId(uid, challengeId));
      const targetProgressSnap = await tx.get(challengeProgressRef);
      const targetProgress = targetProgressSnap.exists
        ? (targetProgressSnap.data() as ChallengeProgressRecord)
        : null;
      if (targetProgress?.status === 'completed') {
        throw new Error(`Challenge already completed: ${challengeId}`);
      }

      const progressQuery = db.collection('challengeProgress').where('uid', '==', uid);
      const progressSnap = await tx.get(progressQuery);
      for (const doc of progressSnap.docs) {
        const progress = doc.data() as ChallengeProgressRecord;
        if (progress.status === 'active' && progress.challengeId !== challengeId) {
          tx.set(doc.ref, { status: 'abandoned' }, { merge: true });
        }
      }

      tx.set(
        challengeProgressRef,
        {
          uid,
          challengeId,
          status: 'active',
          startedAt: nowIso(),
          completedAt: null,
          proofPath: null,
        } satisfies ChallengeProgressRecord,
        { merge: true },
      );
    });
  }

  async markRouteShown(uid: string, challengeId: string): Promise<void> {
    await db.collection('challengeProgress').doc(progressDocId(uid, challengeId)).set(
      {
        uid,
        challengeId,
        lastRouteShownAt: nowIso(),
      } satisfies Partial<ChallengeProgressRecord>,
      { merge: true },
    );
  }

  async completeChallenge(
    uid: string,
    challengeId: string,
    proofPath?: string | null,
  ): Promise<boolean> {
    return db.runTransaction(async (tx) => {
      const challengeRef = db.collection('challenges').doc(challengeId);
      const userRef = db.collection('users').doc(uid);
      const progressRef = db.collection('challengeProgress').doc(progressDocId(uid, challengeId));
      const userAchievementsQuery = db.collection('userAchievements').where('uid', '==', uid);
      const userProgressQuery = db.collection('challengeProgress').where('uid', '==', uid);

      const [challengeSnap, userSnap, progressSnap, unlockSnap, progressDocsSnap] = await Promise.all([
        tx.get(challengeRef),
        tx.get(userRef),
        tx.get(progressRef),
        tx.get(userAchievementsQuery),
        tx.get(userProgressQuery),
      ]);

      if (!challengeSnap.exists) {
        throw new Error(`Challenge not found: ${challengeId}`);
      }

      const challenge = challengeSnap.data() as ChallengeRecord;
      const currentUser = userSnap.exists
        ? (userSnap.data() as UserProfileRecord)
        : {
            uid,
            name: uid === defaultDemoUid ? 'Alex Petrov' : 'Demo Explorer',
            email: `${uid}@example.com`,
            initials: 'DE',
            points: 0,
            level: 1,
            nextLevelPoints: 250,
            completed: 0,
            badges: 0,
            bestStreak: 0,
            currentStreak: 0,
            avatarPath: null,
            lastCompletedDate: null,
            lastLocation: null,
            updatedAt: nowIso(),
          } satisfies UserProfileRecord;
      const existingProgress = progressSnap.exists ? (progressSnap.data() as ChallengeProgressRecord) : null;
      if (existingProgress?.status === 'completed') {
        return false;
      }
      const normalizedProofPath = assertChallengeCompletionEligibility({
        uid,
        challenge,
        user: currentUser,
        progress: existingProgress,
        proofPath,
      });

      const allProgress = progressDocsSnap.docs.map((doc) => doc.data() as ChallengeProgressRecord);
      const completedIds = new Set(
        allProgress.filter((item) => item.status === 'completed').map((item) => item.challengeId),
      );
      completedIds.add(challengeId);

      const challengeById = new Map<string, ChallengeRecord>([[challengeId, challenge]]);
      const missingChallengeRefs = [...completedIds]
        .filter((id) => !challengeById.has(id))
        .map((id) => db.collection('challenges').doc(id));
      const missingChallenges = await Promise.all(missingChallengeRefs.map((ref) => tx.get(ref)));
      for (const snap of missingChallenges) {
        if (snap.exists) {
          const value = snap.data() as ChallengeRecord;
          challengeById.set(value.id, value);
        }
      }

      const finishAt = nowIso();
      const streak = this.nextStreak({
        now: new Date(finishAt),
        currentStreak: currentUser.currentStreak,
        bestStreak: currentUser.bestStreak,
        lastCompletedDate: currentUser.lastCompletedDate ?? null,
      });
      const nextPoints = currentUser.points + challenge.points;
      const nextCompleted = currentUser.completed + 1;

      const progressMap = this.achievementProgress({
        completedCount: nextCompleted,
        currentStreak: streak.currentStreak,
        completedChallenges: [...completedIds]
          .map((id) => challengeById.get(id))
          .filter((value): value is ChallengeRecord => value != null),
      });

      const existingUnlocks = new Set(
        unlockSnap.docs.map((doc) => (doc.data() as UserAchievementRecord).achievementId),
      );
      const newUnlocks = demoAchievementCatalog
        .filter((achievement) => (progressMap[achievement.id] ?? 0) >= achievement.total)
        .map((achievement) => achievement.id)
        .filter((achievementId) => !existingUnlocks.has(achievementId));
      const totalBadges = existingUnlocks.size + newUnlocks.length;
      const achievementBonusPoints = demoAchievementCatalog
        .filter((achievement) => newUnlocks.includes(achievement.id))
        .reduce((sum, achievement) => sum + achievement.rewardPoints, 0);

      const nextUser: UserProfileRecord = {
        ...currentUser,
        points: nextPoints + achievementBonusPoints,
        completed: nextCompleted,
        level: levelForPoints(nextPoints + achievementBonusPoints),
        nextLevelPoints: nextLevelPointsForPoints(nextPoints + achievementBonusPoints),
        bestStreak: streak.bestStreak,
        currentStreak: streak.currentStreak,
        lastCompletedDate: streak.lastCompletedDate,
        badges: totalBadges,
        updatedAt: nowIso(),
      };

      tx.set(userRef, nextUser, { merge: true });
      tx.set(
        progressRef,
        {
          uid,
          challengeId,
          status: 'completed',
          startedAt: existingProgress?.startedAt ?? finishAt,
          completedAt: finishAt,
          proofPath: normalizedProofPath,
          lastRouteShownAt: existingProgress?.lastRouteShownAt ?? null,
        } satisfies ChallengeProgressRecord,
        { merge: true },
      );
      tx.set(challengeRef, { explorersCompleted: FieldValue.increment(1) }, { merge: true });

      for (const achievementId of newUnlocks) {
        tx.set(
          db.collection('userAchievements').doc(userAchievementDocId(uid, achievementId)),
          {
            uid,
            achievementId,
            unlockedAt: finishAt,
          } satisfies UserAchievementRecord,
        );
      }
      return true;
    });
  }

  private nextStreak(input: {
    now: Date;
    currentStreak: number;
    bestStreak: number;
    lastCompletedDate?: string | null;
  }): { currentStreak: number; bestStreak: number; lastCompletedDate: string } {
    const previous = input.lastCompletedDate ? new Date(input.lastCompletedDate) : null;
    const today = new Date(input.now.getFullYear(), input.now.getMonth(), input.now.getDate());
    let nextCurrent = input.currentStreak;
    if (!previous) {
      nextCurrent = input.currentStreak > 0 ? input.currentStreak : 1;
    } else {
      const prevDay = new Date(previous.getFullYear(), previous.getMonth(), previous.getDate());
      const diff = Math.round((today.getTime() - prevDay.getTime()) / 86400000);
      if (diff <= 0) {
        nextCurrent = input.currentStreak > 0 ? input.currentStreak : 1;
      } else if (diff === 1) {
        nextCurrent = input.currentStreak + 1;
      } else {
        nextCurrent = 1;
      }
    }
    return {
      currentStreak: nextCurrent,
      bestStreak: Math.max(nextCurrent, input.bestStreak),
      lastCompletedDate: today.toISOString(),
    };
  }

  private normalizeCategory(value: string): string {
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

  private achievementProgress(input: {
    completedCount: number;
    currentStreak: number;
    completedChallenges: ChallengeRecord[];
  }): Record<string, number> {
    const categories = new Set(input.completedChallenges.map((challenge) => this.normalizeCategory(challenge.category)));
    return {
      first_challenge: input.completedCount > 0 ? 1 : 0,
      five_challenges: Math.min(5, input.completedCount),
      first_nature: categories.has('nature') ? 1 : 0,
      first_cultural: categories.has('cultural') ? 1 : 0,
      first_historical: categories.has('historical') ? 1 : 0,
      first_adventure: categories.has('adventure') ? 1 : 0,
      three_day_streak: Math.min(3, input.currentStreak),
    };
  }
}
