// Firebase Admin — used only to verify the ID token the mobile app gets after
// an SSO sign-in. If no service-account credentials are mounted the app still
// boots; /v1/auth/session then returns 503 until the key is added.
import { readFileSync } from 'node:fs';
import admin from 'firebase-admin';

let auth = null;
let reason = 'not initialised';

try {
  const path = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!path) {
    reason = 'FIREBASE_SERVICE_ACCOUNT not set';
  } else {
    const serviceAccount = JSON.parse(readFileSync(path, 'utf8'));
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    auth = admin.auth();
    reason = 'ok';
    console.log(`[firebase] initialised for project ${serviceAccount.project_id}`);
  }
} catch (err) {
  reason = `init failed: ${err.message}`;
  console.error('[firebase]', reason);
}

export const firebaseReady = () => auth !== null;
export const firebaseStatus = () => reason;

/** Verify a Firebase ID token, returning its decoded claims. Throws if unset. */
export async function verifyIdToken(idToken) {
  if (!auth) {
    const e = new Error('auth backend not configured');
    e.statusCode = 503;
    throw e;
  }
  return auth.verifyIdToken(idToken);
}
