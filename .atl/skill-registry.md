# Skill Registry — control_horario
Generated: 2026-03-30

## Project Conventions

| File | Description |
|------|-------------|
| `.cursorrules` | Reglas globales del proyecto: arquitectura, convenciones de código, sistema de diseño, reglas de Riverpod, prevención de errores comunes |

### Compact Rules (from .cursorrules)

- **State Management**: SOLO Riverpod para estado de app. `setState` permitido SOLO para UI local (TextField, hover, animaciones).
- **Widgets**: Solo presentación. Sin lógica de negocio, sin llamadas a Firebase directas.
- **APIs Flutter 3.18+**: `.withValues(alpha:)` en lugar de `.withOpacity()`. `WidgetStateProperty` en lugar de `MaterialStateProperty`.
- **Overflow**: Todo `Text` en `Row`/`Column` debe estar en `Flexible` o `Expanded`.
- **Estados**: Usar enums explícitos, nunca derivar estado de cálculos (ej: `duration == 0`).
- **Firestore**: Verificar que `toFirestore`/`fromFirestore` usen los mismos valores literales.
- **Nomenclatura**: archivos `snake_case`, clases `PascalCase`, variables `camelCase`.
- **Code gen**: `flutter pub run build_runner build --delete-conflicting-outputs`
- **Commit workflow**: `dart format` + `flutter analyze` antes de commit (hook automático).
- **Anti-sobreingeniería**: YAGNI. Estructura mínima viable, iterar progresivamente.

---

## User Skills

### SDD Phase Skills (`~/.cursor/skills/`)

| Skill | Trigger |
|-------|---------|
| `sdd-init` | Inicializar SDD en el proyecto |
| `sdd-explore` | Investigar codebase antes de proponer cambios |
| `sdd-propose` | Redactar propuesta de cambio |
| `sdd-spec` | Escribir especificaciones y escenarios |
| `sdd-design` | Diseño técnico y decisiones de arquitectura |
| `sdd-tasks` | Desglosar cambio en tareas de implementación |
| `sdd-apply` | Implementar tareas (ejecutor) |
| `sdd-verify` | Validar implementación contra specs |
| `sdd-archive` | Cerrar y archivar cambio completado |

### Workflow Skills (`~/.cursor/skills/`)

| Skill | Trigger |
|-------|---------|
| `branch-pr` | Crear pull request, preparar cambios para review |
| `issue-creation` | Crear GitHub issue, reportar bug, pedir feature |
| `judgment-day` | "judgment day", "juzgar", "que lo juzguen", "doble review" |
| `skill-creator` | Crear nueva skill, documentar patrones para IA |
| `go-testing` | Tests en Go, Bubbletea TUI testing (no aplica a este proyecto) |

### Cursor Skills (`~/.cursor/skills-cursor/`)

| Skill | Trigger |
|-------|---------|
| `canvas` | Visualizaciones interactivas, dashboards, diagramas en el IDE |
| `create-rule` | Crear Cursor rules, convenciones persistentes |
| `create-skill` | Crear nuevas skills de agente |
| `update-cursor-settings` | Modificar settings.json del editor |

---

## Context

- **Project**: control_horario
- **Stack**: Flutter Web + Firebase + Riverpod
- **Phase**: Fase 2 (integración Firebase)
- **SDD Persistence**: engram
- **Strict TDD**: enabled
- **Engram keys**:
  - Project context: `sdd-init/control_horario`
  - Testing capabilities: `sdd/control_horario/testing-capabilities`
