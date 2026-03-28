import { HttpsError } from 'firebase-functions/v2/https';

import { dispatchCompletionPushes, parseNotificationPrefsPatch } from '../src/index';

describe('parseNotificationPrefsPatch', () => {
  test('accepts known boolean prefs', () => {
    expect(parseNotificationPrefsPatch({
      dailyChallenge: false,
      weeklyRecap: true,
    })).toEqual({
      dailyChallenge: false,
      weeklyRecap: true,
    });
  });

  test('rejects unknown prefs', () => {
    expect(() => parseNotificationPrefsPatch({
      dailyChallenge: true,
      mysteryFlag: false,
    })).toThrow(HttpsError);
  });

  test('rejects non-boolean pref values', () => {
    expect(() => parseNotificationPrefsPatch({
      dailyChallenge: 'yes',
    })).toThrow(HttpsError);
  });
});

describe('dispatchCompletionPushes', () => {
  test('skips push send when completion was not awarded', async () => {
    const sendPushes = jest.fn<Promise<void>, Parameters<typeof dispatchCompletionPushes>[0]['sendPushes'] extends infer T
      ? T extends (...args: infer A) => Promise<void> ? A : never
      : never>();
    await dispatchCompletionPushes({
      store: {} as never,
      uid: 'user-1',
      challengeId: 'challenge-1',
      result: {
        awarded: false,
        state: {
          user: { currentStreak: 0 },
          challenges: [{ id: 'challenge-1', title: 'Challenge' }],
        },
        newUnlocks: [],
        pointsDelta: 0,
        streakDelta: 0,
        rankDelta: 0,
      } as never,
      sendPushes,
    });
    expect(sendPushes).not.toHaveBeenCalled();
  });
});
