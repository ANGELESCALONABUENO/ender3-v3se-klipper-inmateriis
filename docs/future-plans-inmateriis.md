# inMateriis - Planes futuros

## Produccion - Laboratorio de Prototipado

### Plan semanal de mejoras | Fecha: 2026-05-08

Plan semanal de mejoras para SE01, SE02 y MA01.

Enfoque actual: extraccion de material, `spoolman_active`, `calibrar_punta`, destrabar BLTouch y recuperacion controlada ante fallo de despliegue del probe.

#### Resumen de mejoras

| ID | Mejora | Prioridad | Estado |
| --- | --- | --- | --- |
| MJR-001 | Macro de extraccion y acceso en pantalla | Alta | Por iniciar |
| MJR-002 | Revision de `SPOOLMAN_ACTIVE` | Alta | Por iniciar |
| MJR-003 | Efectividad de `calibrar_punta` | Media | Por iniciar |
| MJR-004 | Mejora de `DESTRABAR_BLTOUCH` | Alta | Por iniciar |
| MJR-005 | Flujo para `BLTouch failed to deploy` | Alta | En analisis |

#### Semana 1

Macro de extraccion y acceso en pantalla:

- Definir macro base por material.
- Publicar acceso en display.
- Validar 3 ejecuciones exitosas por impresora.

#### Semana 2

Revision de `SPOOLMAN_ACTIVE`:

- Validar defaults y transiciones de synced.
- Verificar bloqueo de ventilador/temperatura.
- Completar 5 inicios de impresion consistentes.

#### Semana 3

Calibrar punta + destrabe:

- 3 corridas por impresora para `calibrar_punta`.
- Comparativo de primera capa.
- Ajustes de `DESTRABAR_BLTOUCH`.

#### Semana 4

Recuperacion semiautomatica BLTouch:

- Secuencia segura: destrabe, reintento, pausa confirmacion.
- Pruebas en pieza no critica.
- No continuar automatico sin validacion Z y probe.
