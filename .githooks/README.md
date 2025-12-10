# 🪝 Git Hooks - Control Horario

Este directorio contiene scripts de Git Hooks personalizados para mantener la calidad del código.

## 📋 ¿Qué son los Git Hooks?

Los Git Hooks son scripts que se ejecutan automáticamente en ciertos eventos de Git (commit, push, etc.). Ayudan a:

- ✅ Prevenir commits con errores
- ✅ Formatear código automáticamente
- ✅ Ejecutar linters y tests
- ✅ Mantener consistencia en el equipo

## 🚀 Instalación (Una sola vez)

### En Windows (PowerShell o CMD):

```bash
# Configurar Git para usar esta carpeta de hooks
git config core.hooksPath .githooks

# Hacer el script ejecutable (solo si usas Git Bash)
chmod +x .githooks/pre-commit
```

### En Mac/Linux:

```bash
# Configurar Git para usar esta carpeta de hooks
git config core.hooksPath .githooks

# Hacer el script ejecutable
chmod +x .githooks/pre-commit
```

## 🔧 Hooks Disponibles

### `pre-commit`

Se ejecuta **antes de cada commit** y verifica:

1. ✅ **Formato del código**: `flutter format`
2. ✅ **Análisis estático**: `flutter analyze --fatal-infos`
3. ✅ **Imports no usados**: Detecta imports innecesarios
4. ✅ **Archivos generados**: Verifica que estén actualizados

**Si alguna verificación falla, el commit se cancela.**

## 📝 Uso Diario

Una vez instalado, el hook se ejecuta automáticamente:

```bash
# Hacer cambios en el código
git add .
git commit -m "feat: nueva funcionalidad"

# ⬇️ El pre-commit hook se ejecuta automáticamente aquí
# 🔍 Verifica formato, linter, etc.
# ✅ Si todo OK → commit se completa
# ❌ Si hay errores → commit se cancela
```

## ⚙️ Configuración del Hook

El hook ejecuta:

```bash
# 1. Formatear código (auto-fix)
dart format lib/ --set-exit-if-changed

# 2. Analizar código (errores y warnings)
flutter analyze --fatal-infos

# 3. Verificar archivos generados
# (opcional, puede desactivarse)
```

## 🔕 Saltarse el Hook (Solo emergencias)

Si necesitas hacer un commit urgente sin verificaciones:

```bash
git commit -m "mensaje" --no-verify
```

**⚠️ Advertencia:** Solo usa `--no-verify` en casos excepcionales. Los hooks existen para proteger la calidad del código.

## 🛠️ Personalización

Para modificar las verificaciones, edita:

- **Windows**: `.githooks/pre-commit.bat`
- **Mac/Linux**: `.githooks/pre-commit`

## ❓ Troubleshooting

### El hook no se ejecuta

**Solución:** Verifica que esté configurado correctamente:

```bash
git config core.hooksPath
# Debe mostrar: .githooks
```

Si no aparece, ejecuta:

```bash
git config core.hooksPath .githooks
```

### Error de permisos (Mac/Linux)

**Solución:** Dale permisos de ejecución:

```bash
chmod +x .githooks/pre-commit
```

### El hook es muy lento

**Solución:** Puedes deshabilitar verificaciones opcionales editando el script y comentando las secciones que no necesites.

### Quiero desactivar los hooks temporalmente

**Solución:** Puedes desactivar todos los hooks con:

```bash
# Desactivar
git config core.hooksPath ""

# Reactivar
git config core.hooksPath .githooks
```

## 📊 Beneficios

| Beneficio | Descripción |
|-----------|-------------|
| 🛡️ **Calidad garantizada** | Previene commits con errores |
| ⚡ **Feedback inmediato** | Detecta problemas antes de push |
| 🤝 **Consistencia del equipo** | Todos siguen las mismas reglas |
| 🎯 **Menos bugs en producción** | Código más limpio y confiable |

## 🔗 Referencias

- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Flutter Analyze](https://docs.flutter.dev/testing/errors)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)

