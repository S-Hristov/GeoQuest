import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';

import { requireAuthenticatedUid, requireOpsAccess } from './auth';
import {
  completeChallengeHandler,
  getAppStateHandler,
  getChallengesHandler,
  getLeaderboardHandler,
  markRouteShownHandler,
  registerPushTokenHandler,
  startChallengeHandler,
  syncUserProfileHandler,
  updateProfileHandler,
  updateNotificationPrefsHandler,
    updateUserLocationHandler,
} from './handlers';
import { ChallengeRecord, NotificationPrefsRecord } from './contracts';
import { FirestoreStore } from './store';
import { runDailyPushJobs, sendCompletionPushes, sendNewChallengeBroadcast, sendOpsBroadcast } from './notifications';

const store = new FirestoreStore();
const notificationPreferenceKeys = [
  'dailyChallenge',
  'nearbyNudges',
  'streakRisk',
  'streakMilestones',
  'achievementUnlocks',
  'completionSummary',
  'newChallenges',
  'weeklyRecap',
  'leaderboardPass',
  'reEngagement',
  'ops',
] satisfies Array<keyof NotificationPrefsRecord>;

export function parseNotificationPrefsPatch(raw: unknown): Partial<NotificationPrefsRecord> {
  if (raw == null || typeof raw !== 'object' || Array.isArray(raw)) {
    throw new HttpsError('invalid-argument', 'prefs must be an object.');
  }
  const entries = Object.entries(raw);
  const allowedKeys = new Set<string>(notificationPreferenceKeys);
  const patch: Partial<NotificationPrefsRecord> = {};
  for (const [key, value] of entries) {
    if (!allowedKeys.has(key)) {
      throw new HttpsError('invalid-argument', `Unknown notification preference: ${key}.`);
    }
    if (typeof value !== 'boolean') {
      throw new HttpsError('invalid-argument', `Notification preference ${key} must be boolean.`);
    }
    patch[key as keyof NotificationPrefsRecord] = value;
  }
  return patch;
}

export async function dispatchCompletionPushes(input: {
  store: FirestoreStore;
  uid: string;
  challengeId: string;
  result: Awaited<ReturnType<typeof completeChallengeHandler>>;
  sendPushes?: typeof sendCompletionPushes;
}): Promise<void> {
  if (!input.result.awarded) return;
  const challenge = input.result.state.challenges.find((item) => item.id === input.challengeId);
  if (challenge == null) return;
  await (input.sendPushes ?? sendCompletionPushes)(input.store, {
    uid: input.uid,
    challengeTitle: challenge.title,
    pointsDelta: input.result.pointsDelta,
    streakNow: input.result.state.user.currentStreak,
    newUnlocks: input.result.newUnlocks.map((unlock) => ({
      title: unlock.title,
      rewardPoints: unlock.rewardPoints,
    })),
  });
}

export const getAppState = onCall({ minInstances: 1 }, async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = (request.data ?? {}) as {
    name?: string;
    email?: string;
    initials?: string;
    avatarPath?: string | null;
  };
  return getAppStateHandler(store, {
    uid,
    profileDefaults: data.name && data.email && data.initials
      ? {
          name: data.name,
          email: data.email,
          initials: data.initials,
          avatarPath: data.avatarPath ?? null,
        }
      : undefined,
  });
});

export const syncUserProfile = onCall({ minInstances: 1 }, async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as {
    name?: string;
    email?: string;
    initials?: string;
    avatarPath?: string | null;
  };
  if (!data.name || !data.email || !data.initials) {
    throw new HttpsError('invalid-argument', 'Missing profile fields.');
  }
  return syncUserProfileHandler(store, {
    uid,
    name: data.name,
    email: data.email,
    initials: data.initials,
    avatarPath: data.avatarPath ?? null,
  });
});

export const updateProfile = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as {
    name?: string;
    email?: string;
    initials?: string;
    avatarPath?: string | null;
  };
  if (!data.name || !data.email || !data.initials) {
    throw new HttpsError('invalid-argument', 'Missing profile fields.');
  }
  return updateProfileHandler(store, {
    uid,
    name: data.name,
    email: data.email,
    initials: data.initials,
    avatarPath: data.avatarPath ?? null,
  });
});

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

export const markRouteShown = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as { challengeId?: string };
  if (!data.challengeId) {
    throw new HttpsError('invalid-argument', 'challengeId required.');
  }
  return markRouteShownHandler(store, {
    uid,
    challengeId: data.challengeId,
  });
});

export const completeChallenge = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as {
    challengeId?: string;
    proofPath?: string | null;
  };
  if (!data.challengeId) {
    throw new HttpsError('invalid-argument', 'challengeId required.');
  }
  try {
    const result = await completeChallengeHandler(store, {
      uid,
      challengeId: data.challengeId,
      proofPath: data.proofPath ?? null,
    });
    await dispatchCompletionPushes({
      store,
      uid,
      challengeId: data.challengeId,
      result,
    });
    return result;
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    const message = error instanceof Error
      ? error.message
      : 'Failed to complete challenge.';
    throw new HttpsError('internal', message);
  }
});

export const registerPushToken = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as {
    token?: string;
    platform?: string;
    locale?: string;
  };
  if (!data.token) {
    throw new HttpsError('invalid-argument', 'token required.');
  }
  return registerPushTokenHandler(store, {
    uid,
    token: data.token,
    platform: data.platform ?? null,
    locale: data.locale ?? null,
  });
});

export const updateNotificationPrefs = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as {
    prefs?: unknown;
  };
  if (!data.prefs) {
    throw new HttpsError('invalid-argument', 'prefs required.');
  }
  return updateNotificationPrefsHandler(store, {
    uid,
    prefs: parseNotificationPrefsPatch(data.prefs),
  });
});

export const updateUserLocation = onCall(async (request) => {
  const uid = requireAuthenticatedUid(request.auth);
  const data = request.data as {
    latitude?: number;
    longitude?: number;
    recordedAt?: string;
  };
  if (typeof data.latitude !== 'number' || typeof data.longitude !== 'number') {
    throw new HttpsError('invalid-argument', 'latitude and longitude required.');
  }
  if (!Number.isFinite(data.latitude) || !Number.isFinite(data.longitude)) {
    throw new HttpsError('invalid-argument', 'latitude and longitude must be finite numbers.');
  }
  return updateUserLocationHandler(store, {
    uid,
    latitude: data.latitude,
    longitude: data.longitude,
    recordedAt: data.recordedAt,
  });
});

export const sendOpsNotification = onCall(async (request) => {
  requireOpsAccess(request.auth);
  const data = request.data as {
    title?: string;
    body?: string;
    deepLink?: string;
  };
  if (!data.body) {
    throw new HttpsError('invalid-argument', 'body required.');
  }
  return sendOpsBroadcast(store, {
    title: data.title,
    body: data.body,
    deepLink: data.deepLink,
  });
});

export const getLeaderboard = onCall(async (request) => {
  const requestedLimit = Number((request.data as { limit?: number } | undefined)?.limit ?? 50);
  const limit = Number.isFinite(requestedLimit)
    ? Math.min(200, Math.max(1, Math.trunc(requestedLimit)))
    : 50;
  return getLeaderboardHandler(store, limit);
});

export const getChallenges = onCall({ minInstances: 1 }, async () => getChallengesHandler(store));

export const pushDailyJobs = onSchedule(
  {
    schedule: 'every 60 minutes',
    timeZone: 'Europe/Sofia',
    retryCount: 0,
  },
  async () => {
    await runDailyPushJobs(store);
  },
);

export const pushNewChallengeBroadcast = onDocumentCreated(
  {
    document: 'challenges/{challengeId}',
    retry: false,
  },
  async (event) => {
    const challenge = event.data?.data();
    if (!challenge) return;
    await sendNewChallengeBroadcast(store, challenge as ChallengeRecord);
  },
);
