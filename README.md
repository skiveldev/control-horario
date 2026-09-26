# Control Horario

A repository portfolio for an employee time-control application built for local development and verification.
No live demo or deployed instance is promised by this repository.

## Capabilities

- Flutter and Riverpod provide the application UI and state-management foundation.
- Firebase services support authentication and application data workflows.
- Employee time control covers clock-in, clock-out, breaks, and work-record views.
- Role-aware workflows separate employee and administrative responsibilities.
- Provisioning reliability is addressed through account setup workflows and validation.

## Architecture and local verification

The project combines a Flutter client, Riverpod-managed application state, and Firebase-backed services.
```sh
flutter analyze
flutter test
dart run tool/check_repository_sanitization.dart
```

These commands verify local code and repository checks; manual publication blockers do not prevent local verification.

## Publication blockers

- License selection — pending/manual publication blocker.
- Reachable-history cleanup — pending/manual publication blocker.
- Firebase Console verification — pending/manual publication blocker.

## Scope limits

- This README describes repository contents, not a live service or deployment.
- It makes no claims about production readiness, clients, uptime, deployed infrastructure, or publication safety.
- Publication decisions remain manual and outside this repository's local verification boundary.
