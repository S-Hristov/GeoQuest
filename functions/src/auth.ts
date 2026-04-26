import { HttpsError } from 'firebase-functions/v2/https';

type CallableAuth = {
  uid?: string | null;
  token?: Record<string, unknown> | null;
} | null | undefined;

export function requireAuthenticatedUid(auth: CallableAuth): string {
  if (typeof auth?.uid !== 'string' || auth.uid.trim().length === 0) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }
  return auth.uid;
}

export function requireOpsAccess(auth: CallableAuth): string {
  const uid = requireAuthenticatedUid(auth);
  const token = auth?.token ?? {};
  if (token.admin === true || token.ops === true) {
    return uid;
  }
  throw new HttpsError('permission-denied', 'Admin privileges required.');
}
