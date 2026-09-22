# Portfolio and Local-Only Quickstart

> **No live deployment. No bundled credentials. No production Firebase project. No client promise.**

This repository is a portfolio artifact. It is intentionally safe to inspect and run only with infrastructure you control.

## What you provide

Before running the app, provide your own:

- Firebase project and application configuration
- Local Firebase Emulator Suite, or an isolated non-production Firebase project
- Test accounts and data appropriate to that environment

Keep configuration and credentials outside version control. Do not reuse a customer, school, or production environment.

## Local workflow

1. Choose an emulator-backed or isolated project.
2. Add its configuration through your local development setup.
3. Create disposable test data.
4. Verify the behavior only in that environment.

## Release signing

Release signing is local-only and absent by design. If you need a signed build, create and protect your own signing material outside this repository. This portfolio does not supply signing keys, signing configuration, or a release-ready distribution process.

## Scope

This document does not establish a hosted service, operational support, production verification, or a commitment to deliver software to a client.
