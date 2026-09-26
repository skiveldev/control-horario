import 'dart:io';

/// Client-side demo user seeding is retired: it cannot provision profiles safely.
void main() {
  stderr.writeln(
    'Client demo seeding is retired. Use trusted provisioning to create '
    'Auth users and their profiles atomically.',
  );
  exitCode = 1;
}
