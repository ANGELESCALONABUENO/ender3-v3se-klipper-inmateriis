# Ender 3 V3 SE - Klipper Config (Inmateriis)

Configuracion productiva para Ender 3 V3 SE con enfoque en operacion diaria:

- Fork de Klipper con soporte `prtouch` (load-cell/sensor de presion de punta)
- Macros modulares (`start`, `end`, `queue`, utilidades)
- Integracion Moonraker + Spoolman
- Filament watchdog por gramos restantes (pausa automatica por stock bajo)

## Stack

- Printer: Creality Ender 3 V3 SE
- Host: MainsailOS + Moonraker
- Slicer: OrcaSlicer
- Material backend: Spoolman

## Estructura del repo

- `config/printer.cfg`
	- Config core de Klipper (hardware, limites, includes)
- `config/macros/`
	- Macros operativas y de automatizacion
- `config/v3se-config/`
	- Bloques especificos V3 SE (`prtouch`, sensor de filamento)
- `sync_lane0/`
	- Script de sincronizacion lane0 + docs + cron example
- `HOSTS.md`
	- Mapeo de impresoras/hosts de este repo (SE01, SE02, MA01) y sus IPs Tailscale

## Caracteristicas clave

1. Start/End print simplificado y mantenible.
2. Integracion con Job Queue de Moonraker.
3. Sync de carrete activo desde Spoolman a Moonraker/Klipper.
4. Watchdog: pausa impresion cuando `remaining_g` cae por debajo del umbral.
5. Macro de destrabe CR/BLTouch integrada: `DESTRABAR_BLTOUCH`.
6. En ABS, el ventilador de capa queda bloqueado en 0 (se ignora `M106` del slicer).

## Extrusor CAD y referencia visual

- Link Cults (modelo CAD del extrusor): https://cults3d.com/es/modelo-3d/herramientas/ender-3v3-se-head-cad

### Galeria

![Extrusor CAD 1](docs/images/extruder-cad-01.png)
![Extrusor CAD 2](docs/images/extruder-cad-02.png)
![Extrusor real](docs/images/extruder-real-01.jpeg)

## Fork de Klipper en uso

Este setup usa actualmente el fork de jpcurti para Ender 3 V3 SE con soporte de display:

- `https://github.com/jpcurti/ender3-v3-se-klipper-with-display`

Nota: este fork no incluye `gcode_shell_command`, por eso la sincronizacion de Spoolman se ejecuta via cron (`spoolman_sync.py`) y no con `RUN_SHELL_COMMAND`.

## Macro DESTRABAR_BLTOUCH

- Archivo: `config/macros/DESTRABAR_BLTOUCH.cfg`
- Origen: `https://github.com/ANGELESCALONABUENO/ender3-v3se-crtouch-destrabe-macro`
- Uso rapido:

```gcode
DESTRABAR_BLTOUCH
```

Con parametros:

```gcode
DESTRABAR_BLTOUCH TARGET=200 CYCLES=40 AMP=8 FEED=900
```

## Instalacion rapida (referencia)

1. Copiar `config/` a tu carpeta de configuracion de Klipper.
2. Verificar includes en `printer.cfg`.
3. Ajustar offsets, malla y limites segun tu maquina.
4. Configurar `sync_lane0/` y cron para refresco de datos Spoolman.
5. Reiniciar Klipper y validar macros en consola.

## Automatizacion de sync

Ver `sync_lane0/cron_example.txt`.

## Seguridad y ajustes

- Revisa `position_min/max`, `max_temp`, `max_velocity` y valores PID antes de usar en otra impresora.
- No aplicar este perfil sin recalibrar `z_offset`, mesh y temperaturas para tu hardware.

## Hotfix: PRTOUCH_PROBE_ZOFFSET (probe_result inmutable)

Si al ejecutar `calibrar_punta` / `PRTOUCH_PROBE_ZOFFSET` Klipper entra en shutdown con:

- `TypeError: 'probe_result' object does not support item assignment`

Aplica el hotfix documentado (se parchea `prtouch.py` dentro de Klipper en la Raspberry):

- Ver [docs/patch-prtouch-probe-result.md](docs/patch-prtouch-probe-result.md)

## Proyecto y colaboracion

- Changelog: `CHANGELOG.md`
- Guia de contribucion: `CONTRIBUTING.md`
- Planes futuros inMateriis: `docs/future-plans-inmateriis.md`
- Plantilla de PR: `.github/pull_request_template.md`
- Plantillas de issues: `.github/ISSUE_TEMPLATE/`
- Orca machine g-code recomendado: `docs/orca-machine-gcode.md`

## Licencia

MIT. Ver archivo `LICENSE`.
