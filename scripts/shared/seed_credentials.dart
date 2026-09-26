import 'dart:io';

/// Thrown when a required seed password is missing or empty.
class SeedCredentialError implements Exception {
  final String message;
  const SeedCredentialError(this.message);

  @override
  String toString() => 'SeedCredentialError: $message';
}

/// Returns the password for [envKey] from the process environment.
///
/// When [env] is provided (for testing), that map is used instead of
/// [Platform.environment].
///
/// Throws [SeedCredentialError] when the variable is unset or empty.
String resolveSeedPassword(String envKey, {Map<String, String>? env}) {
  final effectiveEnv = env ?? Platform.environment;
  final value = effectiveEnv[envKey];
  if (value == null) {
    throw SeedCredentialError(
      'Environment variable $envKey is not set. '
      'Set it before running the seed script.',
    );
  }
  if (value.isEmpty) {
    throw SeedCredentialError(
      'Environment variable $envKey is empty. '
      'Provide a non-empty password.',
    );
  }
  return value;
}
