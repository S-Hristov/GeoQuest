import * as admin from 'firebase-admin';

import { ChallengeProgressRecord, ChallengeRecord, UserProfileRecord } from './contracts';
import { FirestoreStore } from './store';

const DEMO_MODE = process.env.GEOQUEST_DEMO_MODE === 'true';

const nowIso = () => new Date().toISOString();

function isSameUtcDay(aIso: string | null | undefined, b: Date): boolean {
  if (!aIso) return false;
  const a = new Date(aIso);
  return (
    a.getUTCFullYear() === b.getUTCFullYear() &&
    a.getUTCMonth() === b.getUTCMonth() &&
    a.getUTCDate() === b.getUTCDate()
  );
}

function isSameUtcWeek(aIso: string | null | undefined, b: Date): boolean {
  if (!aIso) return false;
  const a = new Date(aIso);
  const day = (date: Date) => {
    const d = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
    const n = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - n);
    const y = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d.getTime() - y.getTime()) / 86400000) + 1) / 7);
  };
  return a.getUTCFullYear() === b.getUTCFullYear() && day(a) === day(b);
}

function daysSince(aIso: string | null | undefined, now: Date): number {
  if (!aIso) return 999;
  const a = new Date(aIso);
  const from = Date.UTC(a.getUTCFullYear(), a.getUTCMonth(), a.getUTCDate());
  const to = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  return Math.floor((to - from) / 86400000);
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

function t(
  locale: string | null | undefined,
  key:
    | 'dailyTitle'
    | 'dailyBody'
    | 'nearbyTitle'
    | 'nearbyBody'
    | 'streakRiskTitle'
    | 'streakRiskBody'
    | 'streakMilestoneTitle'
    | 'streakMilestoneBody'
    | 'achievementTitle'
    | 'achievementBody'
    | 'completeTitle'
    | 'completeBody'
    | 'newChallengeTitle'
    | 'newChallengeBody'
    | 'weeklyTitle'
    | 'weeklyBody'
    | 'rankDownTitle'
    | 'rankDownBody'
    | 'rankUpTitle'
    | 'rankUpBody'
    | 'reengageTitle'
    | 'reengageBody'
    | 'opsTitle',
  vars?: Record<string, string | number>,
): string {
  const bg = (locale ?? 'en').toLowerCase().startsWith('bg');
  const mapEn: Record<string, string> = {
    dailyTitle: 'Daily challenge is live',
    dailyBody: 'Today: {challenge} (+{points} pts).',
    nearbyTitle: 'Challenge nearby',
    nearbyBody: '{challenge} is close. Finish it now.',
    streakRiskTitle: 'Keep your streak alive',
    streakRiskBody: 'Complete 1 challenge today to protect your streak.',
    streakMilestoneTitle: 'Streak milestone',
    streakMilestoneBody: 'You reached a {days}-day streak. 🔥',
    achievementTitle: 'Achievement unlocked',
    achievementBody: '{title} (+{points} pts)',
    completeTitle: 'Challenge completed',
    completeBody: '{challenge} done. +{points} pts.',
    newChallengeTitle: 'New challenge dropped',
    newChallengeBody: '{challenge} is now available.',
    weeklyTitle: 'Weekly recap',
    weeklyBody: '{completed} completed • {points} pts • rank #{rank}',
    rankDownTitle: 'You were passed',
    rankDownBody: 'You dropped to rank #{rank}.',
    rankUpTitle: 'Leaderboard climb',
    rankUpBody: 'You moved up to rank #{rank}.',
    reengageTitle: 'Come back to GeoQuest',
    reengageBody: 'New rewards waiting. Start a quick challenge now.',
    opsTitle: 'GeoQuest update',
  };
  const mapBg: Record<string, string> = {
    dailyTitle: 'Дневното предизвикателство е активно',
    dailyBody: 'Днес: {challenge} (+{points} т.).',
    nearbyTitle: 'Има предизвикателство наблизо',
    nearbyBody: '{challenge} е близо. Завърши го сега.',
    streakRiskTitle: 'Запази серията си',
    streakRiskBody: 'Завърши 1 предизвикателство днес, за да запазиш серията.',
    streakMilestoneTitle: 'Нова серия',
    streakMilestoneBody: 'Достигна {days}-дневна серия. 🔥',
    achievementTitle: 'Отключено постижение',
    achievementBody: '{title} (+{points} т.)',
    completeTitle: 'Предизвикателството е завършено',
    completeBody: '{challenge} е завършено. +{points} т.',
    newChallengeTitle: 'Ново предизвикателство',
    newChallengeBody: '{challenge} вече е налично.',
    weeklyTitle: 'Седмичен отчет',
    weeklyBody: '{completed} завършени • {points} т. • място #{rank}',
    rankDownTitle: 'Изпревариха те',
    rankDownBody: 'Падна до място #{rank}.',
    rankUpTitle: 'Изкачване в класацията',
    rankUpBody: 'Изкачи се до място #{rank}.',
    reengageTitle: 'Върни се в GeoQuest',
    reengageBody: 'Чакат те нови награди. Стартирай бързо предизвикателство.',
    opsTitle: 'Обновление в GeoQuest',
  };
  const template = (bg ? mapBg : mapEn)[key];
  return template.replace(/\{(\w+)\}/g, (_, name) => String(vars?.[name] ?? ''));
}

async function sendToUser(
  user: UserProfileRecord,
  payload: {
    title: string;
    body: string;
    data?: Record<string, string>;
  },
): Promise<void> {
  const token = user.push?.token;
  if (!token) return;
  try {
    await admin.messaging().send({
      token,
      notification: { title: payload.title, body: payload.body },
      data: payload.data ?? {},
      android: { priority: 'high' },
      apns: {
        headers: { 'apns-priority': '10' },
      },
    });
  } catch (error) {
    console.error('push send skipped', {
      uid: user.uid,
      reason: error instanceof Error ? error.message : String(error),
    });
  }
}

function unresolvedNearby(
  challenges: ChallengeRecord[],
  progress: ChallengeProgressRecord[],
  user: UserProfileRecord,
): { challenge: ChallengeRecord; distanceKm: number } | null {
  if (user.lastLocation == null) return null;
  const completed = new Set(
    progress.filter((p) => p.status === 'completed').map((p) => p.challengeId),
  );
  return challenges
    .filter((c) => !completed.has(c.id))
    .map((challenge) => ({
      challenge,
      distanceKm: haversineKm(
        user.lastLocation!.latitude,
        user.lastLocation!.longitude,
        challenge.latitude,
        challenge.longitude,
      ),
    }))
    .sort((a, b) => a.distanceKm - b.distanceKm)[0] ?? null;
}

export async function sendCompletionPushes(
  store: FirestoreStore,
  input: {
    uid: string;
    challengeTitle: string;
    pointsDelta: number;
    streakNow: number;
    newUnlocks: Array<{ title: string; rewardPoints: number }>;
  },
): Promise<void> {
  const user = await store.getUser(input.uid);
  if (!user?.push?.token) return;
  const locale = user.push.locale;
  const prefs = user.notificationPrefs;
  if (prefs?.completionSummary !== false) {
    await sendToUser(user, {
      title: t(locale, 'completeTitle'),
      body: t(locale, 'completeBody', {
        challenge: input.challengeTitle,
        points: input.pointsDelta,
      }),
      data: { type: 'complete_summary' },
    });
  }
  if (prefs?.achievementUnlocks !== false) {
    for (const unlock of input.newUnlocks) {
      await sendToUser(user, {
        title: t(locale, 'achievementTitle'),
        body: t(locale, 'achievementBody', {
          title: unlock.title,
          points: unlock.rewardPoints,
        }),
        data: { type: 'achievement_unlock' },
      });
    }
  }
  if (prefs?.streakMilestones !== false && [3, 7, 14, 30].includes(input.streakNow)) {
    await sendToUser(user, {
      title: t(locale, 'streakMilestoneTitle'),
      body: t(locale, 'streakMilestoneBody', { days: input.streakNow }),
      data: { type: 'streak_milestone' },
    });
  }
}

export async function runDailyPushJobs(store: FirestoreStore): Promise<void> {
  const now = new Date();
  const users = await store.listUsersForPush();
  const challenges = await store.listChallenges();
  const leaderboard = await store.listLeaderboard(200);
  const rankByUid = new Map(leaderboard.map((u, i) => [u.uid, i + 1]));
  const daily = challenges.length === 0 ? null : challenges[
    Math.floor((Date.now() - Date.UTC(now.getUTCFullYear(), 0, 0)) / 86400000) % challenges.length
  ];

  for (const user of users) {
    const locale = user.push?.locale;
    const prefs = user.notificationPrefs;
    const push = user.push ?? {};
    const appState = await store.getOrCreateUser(user.uid).then(() => null);
    void appState;

    if (daily && prefs?.dailyChallenge !== false && (!isSameUtcDay(push.lastDailyAt, now) || DEMO_MODE)) {
      await sendToUser(user, {
        title: t(locale, 'dailyTitle'),
        body: t(locale, 'dailyBody', { challenge: daily.title, points: daily.points }),
        data: { type: 'daily_challenge', challengeId: daily.id },
      });
      await store.markPushState(user.uid, { lastDailyAt: nowIso() });
    }

    const progress = await store.listChallengeProgress(user.uid);
    const nearby = unresolvedNearby(challenges, progress, user);
    if (
      nearby &&
      nearby.distanceKm <= 1.5 &&
      prefs?.nearbyNudges !== false &&
      (!isSameUtcDay(push.lastNearbyAt, now) || DEMO_MODE)
    ) {
      await sendToUser(user, {
        title: t(locale, 'nearbyTitle'),
        body: t(locale, 'nearbyBody', { challenge: nearby.challenge.title }),
        data: { type: 'nearby_nudge', challengeId: nearby.challenge.id },
      });
      await store.markPushState(user.uid, { lastNearbyAt: nowIso() });
    }

    const streakAtRisk = (user.currentStreak ?? 0) > 0 && daysSince(user.lastCompletedDate, now) >= 1;
    if (streakAtRisk && prefs?.streakRisk !== false && (!isSameUtcDay(push.lastStreakRiskAt, now) || DEMO_MODE)) {
      await sendToUser(user, {
        title: t(locale, 'streakRiskTitle'),
        body: t(locale, 'streakRiskBody'),
        data: { type: 'streak_risk' },
      });
      await store.markPushState(user.uid, { lastStreakRiskAt: nowIso() });
    }

    if (prefs?.weeklyRecap !== false && (!isSameUtcWeek(push.lastWeeklyAt, now) || DEMO_MODE) && (now.getUTCDay() === 1 || DEMO_MODE)) {
      const rank = rankByUid.get(user.uid) ?? 999;
      await sendToUser(user, {
        title: t(locale, 'weeklyTitle'),
        body: t(locale, 'weeklyBody', {
          completed: user.completed,
          points: user.points,
          rank,
        }),
        data: { type: 'weekly_recap' },
      });
      await store.markPushState(user.uid, { lastWeeklyAt: nowIso() });
    }

    if (prefs?.leaderboardPass !== false) {
      const rank = rankByUid.get(user.uid) ?? null;
      const previous = push.lastLeaderboardRank ?? null;
      if (rank != null && previous != null && rank !== previous) {
        const movedDown = rank > previous;
        await sendToUser(user, {
          title: t(locale, movedDown ? 'rankDownTitle' : 'rankUpTitle'),
          body: t(locale, movedDown ? 'rankDownBody' : 'rankUpBody', { rank }),
          data: { type: 'leaderboard_move', rank: String(rank) },
        });
      }
      if (rank != null) {
        await store.markPushState(user.uid, { lastLeaderboardRank: rank });
      }
    }

    const inactiveDays = Math.max(daysSince(user.lastActiveAt, now), daysSince(user.lastCompletedDate, now));
    if (
      prefs?.reEngagement !== false &&
      [3, 7, 14].includes(inactiveDays) &&
      (!isSameUtcDay(push.lastReengagementAt, now) || DEMO_MODE)
    ) {
      await sendToUser(user, {
        title: t(locale, 'reengageTitle'),
        body: t(locale, 'reengageBody'),
        data: { type: 'reengagement', days: String(inactiveDays) },
      });
      await store.markPushState(user.uid, { lastReengagementAt: nowIso() });
    }
  }
}

export async function sendNewChallengeBroadcast(
  store: FirestoreStore,
  challenge: ChallengeRecord,
): Promise<void> {
  const users = await store.listUsersForPush();
  for (const user of users) {
    if (user.notificationPrefs?.newChallenges === false) continue;
    await sendToUser(user, {
      title: t(user.push?.locale, 'newChallengeTitle'),
      body: t(user.push?.locale, 'newChallengeBody', { challenge: challenge.title }),
      data: { type: 'new_challenge', challengeId: challenge.id },
    });
  }
}

export async function sendOpsBroadcast(
  store: FirestoreStore,
  payload: { title?: string; body: string; deepLink?: string },
): Promise<{ sent: number }> {
  const users = await store.listUsersForPush();
  let sent = 0;
  for (const user of users) {
    if (user.notificationPrefs?.ops === false) continue;
    await sendToUser(user, {
      title: payload.title ?? t(user.push?.locale, 'opsTitle'),
      body: payload.body,
      data: payload.deepLink ? { type: 'ops', deepLink: payload.deepLink } : { type: 'ops' },
    });
    sent += 1;
  }
  return { sent };
}
