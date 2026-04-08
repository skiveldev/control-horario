/// Utilidades compartidas para validación de contraseñas

/// Calcula la fortaleza de una contraseña en una escala de 0 a 4.
///
/// Criterios evaluados (1 punto cada uno):
/// - Longitud mínima (configurable, por defecto 6)
/// - Contiene mayúsculas
/// - Contiene minúsculas
/// - Contiene números
/// - Contiene caracteres especiales
///
/// Ejemplo:
/// ```dart
/// final strength = calculatePasswordStrength('MyP@ss1', minLength: 8);
/// // Retorna 4
/// ```
int calculatePasswordStrength(String password, {int minLength = 6}) {
  if (password.isEmpty) return 0;

  int strength = 0;

  if (password.length >= minLength) strength++;
  if (password.contains(RegExp(r'[A-Z]'))) strength++;
  if (password.contains(RegExp(r'[a-z]'))) strength++;
  if (password.contains(RegExp(r'[0-9]'))) strength++;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

  return strength > 4 ? 4 : strength;
}
