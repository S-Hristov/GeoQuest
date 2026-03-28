import { HttpsError } from 'firebase-functions/v2/https';

import {
  assertChallengeCompletionEligibility,
  isDemoSeedingEnabled,
  normalizeProofPath,
} from '../src/store';

describe('isDemoSeedingEnabled', () => {
  test('disabled by default', () => {
    expect(isDemoSeedingEnabled({})).toBe(false);
  });

  test('enabled for emulator env', () => {
    expect(isDemoSeedingEnabled({ FUNCTIONS_EMULATOR: 'true' })).toBe(true);
    expect(isDemoSeedingEnabled({ FIRESTORE_EMULATOR_HOST: '127.0.0.1:8080' })).toBe(true);
  });
});

describe('normalizeProofPath', () => {
  test('normalizes proof under caller namespace', () => {
    expect(normalizeProofPath('user-1', '/tmp/proof.jpg')).toBe('proofs/user-1/proof.jpg');
  });

  test('rejects unsupported proof file', () => {
    expect(() => normalizeProofPath('user-1', '/tmp/proof.exe')).toThrow(HttpsError);
  });
});

describe('assertChallengeCompletionEligibility', () => {
  const challenge = {
    id: 'challenge-1',
    title: 'Challenge',
    location: 'Here',
    description: 'desc',
    imageAsset: 'asset.png',
    distanceKm: 1,
    points: 100,
    duration: '10m',
    difficulty: 'easy' as const,
    category: 'Nature',
    latitude: 42.6543,
    longitude: 23.3533,
    explorersCompleted: 0,
  };

  test('requires active progress', () => {
    expect(() => assertChallengeCompletionEligibility({
      uid: 'user-1',
      challenge,
      user: {
        lastLocation: {
          latitude: challenge.latitude,
          longitude: challenge.longitude,
          recordedAt: '2026-04-26T00:00:00.000Z',
        },
      },
      progress: null,
      proofPath: null,
    })).toThrow(HttpsError);
  });

  test('requires nearby location and returns normalized proof path', () => {
    expect(assertChallengeCompletionEligibility({
      uid: 'user-1',
      challenge,
      user: {
        lastLocation: {
          latitude: challenge.latitude,
          longitude: challenge.longitude,
          recordedAt: '2026-04-26T00:00:00.000Z',
        },
      },
      progress: {
        uid: 'user-1',
        challengeId: challenge.id,
        status: 'active',
        startedAt: '2026-04-26T00:00:00.000Z',
      },
      proofPath: '/tmp/proof.jpg',
    })).toBe('proofs/user-1/proof.jpg');
  });

  test('rejects distant completion attempts', () => {
    expect(() => assertChallengeCompletionEligibility({
      uid: 'user-1',
      challenge,
      user: {
        lastLocation: {
          latitude: 42.6643,
          longitude: 23.3533,
          recordedAt: '2026-04-26T00:00:00.000Z',
        },
      },
      progress: {
        uid: 'user-1',
        challengeId: challenge.id,
        status: 'active',
        startedAt: '2026-04-26T00:00:00.000Z',
      },
      proofPath: null,
    })).toThrow(HttpsError);
  });
});
