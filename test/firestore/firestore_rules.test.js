import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  collectionGroup,
  deleteField,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

const PROJECT_ID = 'control-horario-firestore-rules';
const RULES_PATH = new URL('../../firestore.rules', import.meta.url);

let testEnv;

before(async () => {
  const rules = await fs.readFile(RULES_PATH, 'utf8');
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seedBaseData();
});

after(async () => {
  await testEnv.cleanup();
});

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

async function seedBaseData() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await Promise.all([
      setDoc(doc(db, 'users', 'admin'), buildUser('admin', { role: 'admin' })),
      setDoc(doc(db, 'users', 'rrhh'), buildUser('rrhh', { role: 'rrhh' })),
      setDoc(
        doc(db, 'users', 'supervisorA'),
        buildUser('supervisorA', { isSupervisor: true }),
      ),
      setDoc(
        doc(db, 'users', 'supervisorB'),
        buildUser('supervisorB', { isSupervisor: true }),
      ),
      setDoc(
        doc(db, 'users', 'employeeA'),
        buildUser('employeeA', { supervisorId: 'supervisorA' }),
      ),
      setDoc(
        doc(db, 'users', 'employeeB'),
        buildUser('employeeB', { supervisorId: 'supervisorB' }),
      ),
      setDoc(
        doc(db, 'users', 'inactiveEmployee'),
        buildUser('inactiveEmployee', {
          supervisorId: 'supervisorA',
          isActive: false,
        }),
      ),
      setDoc(
        doc(db, 'users', 'inactiveSupervisor'),
        buildUser('inactiveSupervisor', {
          isSupervisor: true,
          isActive: false,
        }),
      ),
      setDoc(
        doc(db, 'users', 'employeeA', 'time_records', 'recordA'),
        buildTimeRecord('employeeA'),
      ),
      setDoc(
        doc(db, 'users', 'employeeB', 'time_records', 'recordB'),
        buildTimeRecord('employeeB'),
      ),
      setDoc(
        doc(db, 'users', 'inactiveEmployee', 'time_records', 'recordC'),
        buildTimeRecord('inactiveEmployee'),
      ),
      setDoc(
        doc(db, 'team_month_closures', 'supervisorB_2026-04'),
        buildClosure('supervisorB'),
      ),
    ]);
  });
}

function buildUser(uid, overrides = {}) {
  return {
    userId: uid,
    employeeId: `EMP-${uid}`,
    email: `${uid}@example.com`,
    displayName: uid,
    role: 'employee',
    isSupervisor: false,
    weeklyHours: 40,
    isActive: true,
    createdAt: new Date('2026-04-01T00:00:00.000Z'),
    ...overrides,
  };
}

function buildTimeRecord(userId, overrides = {}) {
  return {
    userId,
    date: '2026-04-10',
    category: 'work',
    startTime: '09:00',
    endTime: '17:00',
    durationMinutes: 480,
    createdAt: new Date('2026-04-10T09:00:00.000Z'),
    updatedAt: new Date('2026-04-10T17:00:00.000Z'),
    createdBy: userId,
    isManual: false,
    recordStatus: 'completed',
    validationStatus: 'editable',
    ...overrides,
  };
}

function buildClosure(supervisorId, overrides = {}) {
  return {
    supervisorId,
    month: '2026-04',
    status: 'closed',
    closedAt: new Date('2026-04-30T18:00:00.000Z'),
    closedBy: supervisorId,
    teamSnapshot: {
      teamMembers: 1,
      totalRecords: 1,
      pendingRecords: 0,
    },
    updatedAt: new Date('2026-04-30T18:00:00.000Z'),
    ...overrides,
  };
}

describe('Phase 3 - admin supervisor assignment persistence', () => {
  it('allows admin to persist supervisorId while editing an employee', async () => {
    const employeeRef = doc(authedDb('admin'), 'users', 'employeeB');

    await assertSucceeds(
      updateDoc(employeeRef, {
        supervisorId: 'supervisorA',
      }),
    );

    const snapshot = await assertSucceeds(getDoc(employeeRef));
    assert.equal(snapshot.data().supervisorId, 'supervisorA');
  });
});

describe('users create security', () => {
  it('denies self-creation when the new user tries to elevate role to admin', async () => {
    const employeeRef = doc(authedDb('newEmployee'), 'users', 'newEmployee');

    await assertFails(
      setDoc(employeeRef, buildUser('newEmployee', { role: 'admin' })),
    );
  });

  it('denies self-creation when the new user tries to mark themselves as supervisor', async () => {
    const employeeRef = doc(authedDb('newSupervisor'), 'users', 'newSupervisor');

    await assertFails(
      setDoc(
        employeeRef,
        buildUser('newSupervisor', { isSupervisor: true }),
      ),
    );
  });

  it('still allows a safe self-creation without authorization fields elevated', async () => {
    const employeeRef = doc(authedDb('safeEmployee'), 'users', 'safeEmployee');

    await assertSucceeds(setDoc(employeeRef, buildUser('safeEmployee')));
  });
});

describe('Phase 5.1 - validation permissions', () => {
  it('denies an employee from self-validating their own record', async () => {
    const recordRef = doc(
      authedDb('employeeA'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertFails(
      updateDoc(recordRef, {
        validationStatus: 'validated',
        validatedBy: 'employeeA',
        validatedAt: new Date('2026-04-11T12:00:00.000Z'),
        updatedAt: new Date('2026-04-11T12:00:00.000Z'),
      }),
    );
  });

  it('allows admin to validate any employee record', async () => {
    const recordRef = doc(
      authedDb('admin'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertSucceeds(
      updateDoc(recordRef, {
        validationStatus: 'validated',
        validatedBy: 'admin',
        validatedAt: new Date('2026-04-11T12:00:00.000Z'),
        updatedAt: new Date('2026-04-11T12:00:00.000Z'),
      }),
    );

    const snapshot = await assertSucceeds(getDoc(recordRef));
    assert.equal(snapshot.data().validationStatus, 'validated');
    assert.equal(snapshot.data().validatedBy, 'admin');
    assert.equal(
      snapshot.data().validatedAt.toDate().toISOString(),
      '2026-04-11T12:00:00.000Z',
    );
  });

  it('allows the assigned supervisor to validate a team member record', async () => {
    const recordRef = doc(
      authedDb('supervisorA'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertSucceeds(
      updateDoc(recordRef, {
        validationStatus: 'validated',
        validatedBy: 'supervisorA',
        validatedAt: new Date('2026-04-11T12:00:00.000Z'),
        updatedAt: new Date('2026-04-11T12:00:00.000Z'),
      }),
    );

    const snapshot = await assertSucceeds(getDoc(recordRef));
    assert.equal(snapshot.data().validationStatus, 'validated');
    assert.equal(snapshot.data().validatedBy, 'supervisorA');
    assert.equal(
      snapshot.data().validatedAt.toDate().toISOString(),
      '2026-04-11T12:00:00.000Z',
    );
  });

  it('denies a supervisor from validating a record outside their team', async () => {
    const recordRef = doc(
      authedDb('supervisorA'),
      'users',
      'employeeB',
      'time_records',
      'recordB',
    );

    await assertFails(
      updateDoc(recordRef, {
        validationStatus: 'validated',
        validatedBy: 'supervisorA',
        validatedAt: new Date('2026-04-11T12:00:00.000Z'),
        updatedAt: new Date('2026-04-11T12:00:00.000Z'),
      }),
    );
  });

  it('still allows the employee to edit their own record without validating it', async () => {
    const recordRef = doc(
      authedDb('employeeA'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertSucceeds(
      updateDoc(recordRef, {
        startTime: '08:30',
        updatedAt: new Date('2026-04-11T08:30:00.000Z'),
      }),
    );

    const snapshot = await assertSucceeds(getDoc(recordRef));
    assert.equal(snapshot.data().startTime, '08:30');
    assert.equal(snapshot.data().validationStatus, 'editable');
  });

  it('denies an employee from changing ownership fields on their own record', async () => {
    const recordRef = doc(
      authedDb('employeeA'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertFails(
      updateDoc(recordRef, {
        userId: 'employeeB',
        createdBy: 'employeeB',
        createdAt: new Date('2026-04-11T08:30:00.000Z'),
      }),
    );
  });

  it('denies a supervisor from editing non-validation fields on a team record', async () => {
    const recordRef = doc(
      authedDb('supervisorA'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertFails(
      updateDoc(recordRef, {
        startTime: '08:30',
        updatedAt: new Date('2026-04-11T08:30:00.000Z'),
      }),
    );
  });
});

describe('Phase 5.2 - team read scope', () => {
  it('allows an employee to query their own month records in the subcollection', async () => {
    const db = authedDb('employeeA');
    const ownMonthQuery = query(
      collection(db, 'users', 'employeeA', 'time_records'),
      where('date', '>=', '2026-04-01'),
      where('date', '<=', '2026-04-30'),
    );

    const snapshot = await assertSucceeds(getDocs(ownMonthQuery));
    assert.deepEqual(snapshot.docs.map((item) => item.id), ['recordA']);
  });

  it('allows a supervisor to query only their own active team members', async () => {
    const db = authedDb('supervisorA');
    const teamQuery = query(
      collection(db, 'users'),
      where('supervisorId', '==', 'supervisorA'),
      where('isActive', '==', true),
    );

    const snapshot = await assertSucceeds(getDocs(teamQuery));
    assert.deepEqual(snapshot.docs.map((item) => item.id), ['employeeA']);
  });

  it('denies a supervisor from reading an employee outside their team', async () => {
    const employeeRef = doc(authedDb('supervisorA'), 'users', 'employeeB');
    await assertFails(getDoc(employeeRef));
  });

  it('allows a supervisor to query team time records through collectionGroup', async () => {
    const db = authedDb('supervisorA');
    const recordsQuery = query(
      collectionGroup(db, 'time_records'),
      where('userId', 'in', ['employeeA']),
      where('date', '>=', '2026-04-01'),
      where('date', '<=', '2026-04-30'),
    );

    const snapshot = await assertSucceeds(getDocs(recordsQuery));
    assert.deepEqual(snapshot.docs.map((item) => item.id), ['recordA']);
  });

  it('allows a supervisor to query a team member month records in the subcollection', async () => {
    const db = authedDb('supervisorA');
    const teamMemberMonthQuery = query(
      collection(db, 'users', 'employeeA', 'time_records'),
      where('date', '>=', '2026-04-01'),
      where('date', '<=', '2026-04-30'),
    );

    const snapshot = await assertSucceeds(getDocs(teamMemberMonthQuery));
    assert.deepEqual(snapshot.docs.map((item) => item.id), ['recordA']);
  });

  it('denies a supervisor from querying time records outside their team', async () => {
    const db = authedDb('supervisorA');
    const recordsQuery = query(
      collectionGroup(db, 'time_records'),
      where('userId', 'in', ['employeeB']),
      where('date', '>=', '2026-04-01'),
      where('date', '<=', '2026-04-30'),
    );

    await assertFails(getDocs(recordsQuery));
  });
});

describe('Phase 5.3 - team month closures', () => {
  it('allows a supervisor to create and read their own month closure', async () => {
    const db = authedDb('supervisorA');
    const closureRef = doc(db, 'team_month_closures', 'supervisorA_2026-04');

    await assertSucceeds(setDoc(closureRef, buildClosure('supervisorA')));

    const snapshot = await assertSucceeds(getDoc(closureRef));
    assert.equal(snapshot.data().supervisorId, 'supervisorA');
    assert.equal(snapshot.data().closedBy, 'supervisorA');
    assert.equal(snapshot.data().month, '2026-04');
    assert.equal(snapshot.data().status, 'closed');
    assert.equal(
      snapshot.data().closedAt.toDate().toISOString(),
      '2026-04-30T18:00:00.000Z',
    );
  });

  it('denies a supervisor from creating a closure for another supervisorId', async () => {
    const closureRef = doc(
      authedDb('supervisorA'),
      'team_month_closures',
      'supervisorB_2026-04',
    );

    await assertFails(setDoc(closureRef, buildClosure('supervisorB')));
  });

  it('denies a closure create when the closureId does not match supervisor and month', async () => {
    const closureRef = doc(
      authedDb('supervisorA'),
      'team_month_closures',
      'supervisorA_2026-05',
    );

    await assertFails(
      setDoc(
        closureRef,
        buildClosure('supervisorA', {
          month: '2026-04',
        }),
      ),
    );
  });

  it('denies rewriting identity fields of an existing team closure', async () => {
    const closureRef = doc(
      authedDb('supervisorA'),
      'team_month_closures',
      'supervisorA_2026-04',
    );

    await assertSucceeds(setDoc(closureRef, buildClosure('supervisorA')));

    await assertFails(
      updateDoc(closureRef, {
        closedBy: 'supervisorB',
      }),
    );
  });

  it('denies a supervisor from reading another supervisors closure', async () => {
    const closureRef = doc(
      authedDb('supervisorA'),
      'team_month_closures',
      'supervisorB_2026-04',
    );

    await assertFails(getDoc(closureRef));
  });

  it('allows admin to read any team month closure', async () => {
    const closureRef = doc(
      authedDb('admin'),
      'team_month_closures',
      'supervisorB_2026-04',
    );

    const snapshot = await assertSucceeds(getDoc(closureRef));
    assert.equal(snapshot.data().supervisorId, 'supervisorB');
  });
});

describe('Phase 5.4 - inactive users', () => {
  it('denies an inactive employee from reading their own time records', async () => {
    const recordRef = doc(
      authedDb('inactiveEmployee'),
      'users',
      'inactiveEmployee',
      'time_records',
      'recordC',
    );

    await assertFails(getDoc(recordRef));
  });

  it('denies an inactive supervisor from creating a team month closure', async () => {
    const closureRef = doc(
      authedDb('inactiveSupervisor'),
      'team_month_closures',
      'inactiveSupervisor_2026-04',
    );

    await assertFails(setDoc(closureRef, buildClosure('inactiveSupervisor')));
  });
});

describe('Issue 1 - team_month_closures immutable after creation', () => {
  it('denies update to an existing team month closure', async () => {
    // supervisorB_2026-04 already exists in seed data
    const closureRef = doc(
      authedDb('supervisorB'),
      'team_month_closures',
      'supervisorB_2026-04',
    );

    await assertFails(
      updateDoc(closureRef, {
        teamSnapshot: { teamMembers: 99, totalRecords: 99, pendingRecords: 0 },
        updatedAt: new Date('2026-05-01T00:00:00.000Z'),
      }),
    );
  });
});

describe('Issue 2 - time_records create ownership enforcement', () => {
  it('denies creating a time_record with a spoofed createdBy', async () => {
    const recordRef = doc(
      authedDb('employeeA'),
      'users',
      'employeeA',
      'time_records',
      'spoofedRecord',
    );

    await assertFails(
      setDoc(recordRef, buildTimeRecord('employeeA', { createdBy: 'admin' })),
    );
  });

  it('denies creating a time_record with pre-seeded audit fields', async () => {
    const recordRef = doc(
      authedDb('employeeA'),
      'users',
      'employeeA',
      'time_records',
      'auditRecord',
    );

    await assertFails(
      setDoc(
        recordRef,
        buildTimeRecord('employeeA', {
          validatedBy: 'admin',
          validatedAt: new Date('2026-04-11T12:00:00.000Z'),
        }),
      ),
    );
  });
});

describe('Issue 3 - block/unblock admin operations', () => {
  it('allows admin to block a time record', async () => {
    const recordRef = doc(
      authedDb('admin'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertSucceeds(
      updateDoc(recordRef, {
        validationStatus: 'blocked',
        blockedBy: 'admin',
        blockedAt: new Date('2026-04-12T10:00:00.000Z'),
        blockReason: 'Fraude detectado',
        updatedAt: new Date('2026-04-12T10:00:00.000Z'),
      }),
    );

    const snapshot = await assertSucceeds(getDoc(recordRef));
    assert.equal(snapshot.data().validationStatus, 'blocked');
    assert.equal(snapshot.data().blockedBy, 'admin');
  });

  it('allows admin to unblock a blocked time record', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(
        doc(db, 'users', 'employeeA', 'time_records', 'blockedRecord'),
        buildTimeRecord('employeeA', {
          validationStatus: 'blocked',
          blockedBy: 'admin',
          blockedAt: new Date('2026-04-11T10:00:00.000Z'),
          blockReason: 'Fraude detectado',
        }),
      );
    });

    const recordRef = doc(
      authedDb('admin'),
      'users',
      'employeeA',
      'time_records',
      'blockedRecord',
    );

    await assertSucceeds(
      updateDoc(recordRef, {
        validationStatus: 'editable',
        blockedBy: deleteField(),
        blockedAt: deleteField(),
        blockReason: deleteField(),
        updatedAt: new Date('2026-04-12T10:00:00.000Z'),
      }),
    );

    const snapshot = await assertSucceeds(getDoc(recordRef));
    assert.equal(snapshot.data().validationStatus, 'editable');
    assert.equal(snapshot.data().blockedBy, undefined);
  });

  it('denies a non-admin from blocking a time record', async () => {
    const recordRef = doc(
      authedDb('supervisorA'),
      'users',
      'employeeA',
      'time_records',
      'recordA',
    );

    await assertFails(
      updateDoc(recordRef, {
        validationStatus: 'blocked',
        blockedBy: 'supervisorA',
        blockedAt: new Date('2026-04-12T10:00:00.000Z'),
        updatedAt: new Date('2026-04-12T10:00:00.000Z'),
      }),
    );
  });
});
