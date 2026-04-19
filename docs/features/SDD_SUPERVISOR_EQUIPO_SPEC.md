# Supervisor en Panel Empleado - Specification

## Purpose

Definir requisitos funcionales para que un supervisor opere como empleado con capacidades adicionales de supervision de equipo: revision, validacion de fichajes y cierre mensual.

---

## ADDED Requirements

### Requirement: Supervisor como empleado con permiso adicional
El sistema MUST modelar al supervisor como empleado con capacidad adicional de supervision, sin crear un panel separado.

#### Scenario: Usuario supervisor inicia sesion
- **Given** un usuario autenticado con `role = employee` e `isSupervisor = true`
- **When** accede al dashboard de empleado
- **Then** usa el mismo panel de empleado
- **And** ve la opcion `Equipo` en la navegacion.

#### Scenario: Usuario empleado no supervisor inicia sesion
- **Given** un usuario autenticado con `role = employee` e `isSupervisor = false`
- **When** accede al dashboard
- **Then** NO debe ver la opcion `Equipo`.

---

### Requirement: Asignacion de equipo por supervisor
El sistema MUST permitir asignar empleados a un supervisor y consultar el equipo de forma consistente.

#### Scenario: Admin crea o edita empleado asignando supervisor
- **Given** un admin en gestionar empleados
- **When** selecciona supervisor para un empleado
- **Then** el usuario guardado contiene `supervisorId` con el `userId` del supervisor.

#### Scenario: Supervisor consulta su equipo
- **Given** un supervisor autenticado
- **When** abre la vista `Equipo`
- **Then** solo se listan empleados cuyo `supervisorId` coincide con su `userId`.

---

### Requirement: Vista Equipo con foco mensual
El sistema MUST ofrecer una vista de equipo orientada al control del mes.

#### Scenario: Supervisor abre modulo Equipo
- **Given** un supervisor con miembros asignados
- **When** navega a `Equipo`
- **Then** visualiza:
  - selector de mes
  - listado de miembros
  - estado mensual por miembro (pendiente/validado/parcial)
  - resumen agregado del equipo.

#### Scenario: Supervisor sin equipo asignado
- **Given** un supervisor sin miembros
- **When** abre `Equipo`
- **Then** se muestra estado vacio con mensaje claro.

---

### Requirement: Validacion de fichajes por alcance de equipo
El sistema MUST permitir validar fichajes al supervisor solo dentro de su equipo.

#### Scenario: Supervisor valida registro de miembro de su equipo
- **Given** un registro editable de un empleado asignado al supervisor
- **When** el supervisor ejecuta validar
- **Then** el registro cambia a `validationStatus = validated`
- **And** se guarda `validatedBy` y `validatedAt`.

#### Scenario: Supervisor intenta validar registro fuera de su equipo
- **Given** un registro de un empleado no asignado al supervisor
- **When** intenta validar
- **Then** el sistema rechaza la accion por permisos.

#### Scenario: Admin valida cualquier registro
- **Given** un admin autenticado
- **When** valida un registro
- **Then** el sistema lo permite sin restriccion por `supervisorId`.

---

### Requirement: Cierre mensual de equipo
El sistema MUST permitir al supervisor cerrar el mes del equipo cuando no existan pendientes.

#### Scenario: Cierre mensual exitoso
- **Given** un supervisor y todos los registros del mes del equipo validados
- **When** confirma "Cerrar mes"
- **Then** se persiste un documento de cierre mensual con trazabilidad
- **And** el estado mensual pasa a `closed`.

#### Scenario: Cierre mensual bloqueado por pendientes
- **Given** un supervisor con al menos un registro pendiente de validacion
- **When** intenta cerrar el mes
- **Then** el sistema impide el cierre
- **And** muestra resumen de pendientes por empleado.

#### Scenario: Reintento de cierre de mes ya cerrado
- **Given** un mes ya cerrado para ese supervisor
- **When** intenta volver a cerrarlo
- **Then** el sistema muestra estado ya cerrado y no duplica cierre.

---

### Requirement: Trazabilidad y auditoria basica
El sistema MUST registrar quien valida y quien cierra, con fecha y contexto minimo.

#### Scenario: Auditoria de validacion
- **Given** un registro validado por supervisor o admin
- **When** se consulta detalle del registro
- **Then** existen `validatedBy` y `validatedAt`.

#### Scenario: Auditoria de cierre mensual
- **Given** un cierre mensual realizado
- **When** se consulta documento de cierre
- **Then** existen `closedBy`, `closedAt`, `month`, `supervisorId`, y estado.

---

## Assumptions

- Se mantiene la estrategia de rol base (`employee`, `rrhh`, `admin`) y se agrega capacidad por bandera.
- La asignacion de equipo es de un solo supervisor por empleado.
- El cierre mensual en esta fase es manual (sin automatizacion por Cloud Function).

## Open Questions

- Si RRHH tambien podra cerrar mes de equipos (ademas de supervisor/admin).
- Si un supervisor puede delegar cierre temporal a otro supervisor.
- Nivel de detalle requerido para `teamSnapshot` en auditoria.
