# Firestore Composite Indexes

## Focused Attendance Improvements

Required composite indexes for efficient querying of new collections.

### `overtime_requests`

| Index ID | Fields | Purpose |
|----------|--------|---------|
| `overtime_requests_userId_weekStart` | `userId` ASC, `weekStart` ASC | Query overtime requests for a specific user and week |
| `overtime_requests_status` | `status` ASC | Query pending requests across all users |

### `anomalies`

| Index ID | Fields | Purpose |
|----------|--------|---------|
| `anomalies_userId_date` | `userId` ASC, `date` ASC | Query anomalies for a specific user and date |
| `anomalies_userId_month` | `userId` ASC, `date` ASC | Query anomalies for a user within a date range |

### `employee_vacations`

| Index ID | Fields | Purpose |
|----------|--------|---------|
| `employee_vacations_employeeId_date` | `employeeId` ASC, `date` ASC | Query vacations for a specific employee and date |
| `employee_vacations_employeeId_month` | `employeeId` ASC, `date` ASC | Query vacations for an employee within a month range |

## Deployment

Create these indexes in the Firebase Console → Firestore → Indexes tab, or deploy
via `firebase deploy --only firestore:indexes` with a `firestore.indexes.json` file.
