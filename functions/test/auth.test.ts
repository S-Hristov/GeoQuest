import { HttpsError } from 'firebase-functions/v2/https';

import { requireAuthenticatedUid, requireOpsAccess } from '../src/auth';

describe('auth helpers', () => {
  test('requireAuthenticatedUid returns caller uid', () => {
    expect(requireAuthenticatedUid({ uid: 'user-123' })).toBe('user-123');
  });

  test('requireAuthenticatedUid rejects missing auth', () => {
    expect.assertions(2);
    try {
      requireAuthenticatedUid(null);
    } catch (error) {
      expect(error).toBeInstanceOf(HttpsError);
      expect((error as HttpsError).code).toBe('unauthenticated');
    }
  });

  test('requireOpsAccess allows admin claim', () => {
    expect(
      requireOpsAccess({
        uid: 'ops-user',
        token: { admin: true },
      }),
    ).toBe('ops-user');
  });

  test('requireOpsAccess allows ops claim', () => {
    expect(
      requireOpsAccess({
        uid: 'ops-user',
        token: { ops: true },
      }),
    ).toBe('ops-user');
  });

  test('requireOpsAccess rejects non-admin caller', () => {
    expect.assertions(2);
    try {
      requireOpsAccess({
        uid: 'plain-user',
        token: {},
      });
    } catch (error) {
      expect(error).toBeInstanceOf(HttpsError);
      expect((error as HttpsError).code).toBe('permission-denied');
    }
  });
});
