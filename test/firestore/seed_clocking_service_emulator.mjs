// Fixture for the opt-in Dart service test; run only under emulators:exec.
import assert from 'node:assert/strict';
import { deleteApp, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const projectId = 'demo-clockin-dart';
// Validate all targets before initializing admin clients or writing any data.
assert.equal(process.env.GCLOUD_PROJECT, projectId);
assert.equal(process.env.FIRESTORE_EMULATOR_HOST, '127.0.0.1:8080');
assert.equal(process.env.FIREBASE_AUTH_EMULATOR_HOST, '127.0.0.1:9099');
const app = initializeApp({ projectId });
const db = getFirestore(app);
try {
  await getAuth(app).createUser({
    uid: 'clocking-service-owner',
    email: 'clocking-service@example.invalid',
    password: 'Emulator-only-1234',
  });
  await db.doc('users/clocking-service-owner').set({
    userId: 'clocking-service-owner', role: 'employee', isActive: true,
  });
} finally {
  await db.terminate();
  await deleteApp(app);
}
