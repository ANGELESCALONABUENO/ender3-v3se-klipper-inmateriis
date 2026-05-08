# MA01 Host Integration Notes

Referencia operativa extraida de la impresora MA01 el 2026-05-08.

Este documento cubre piezas de integracion a nivel host que no viven dentro de `config/`, pero que forman parte del comportamiento real del equipo.

## Alcance

Estos puntos complementan lo ya documentado en `sync_lane0/README.md`:

- Moonraker con `spoolman`, `mmu_server` y `update_manager happy-hare`
- cron para `sync_lane0_from_spoolman.sh`
- cron adicional para `scripts/spoolman_sync.py`
- recordatorio de que el fork actual no usa `RUN_SHELL_COMMAND`

## Moonraker

Bloques relevantes observados en MA01:

```ini
[spoolman]
server: http://192.168.1.156:7912

[update_manager happy-hare]
type: git_repo
path: ~/Happy-Hare
origin: https://github.com/moggieuk/Happy-Hare.git
primary_branch: main
managed_services: klipper

[mmu_server]
enable_file_preprocessor: True
enable_toolchange_next_pos: True
update_spoolman_location: True
```

## Cron activo en MA01

MA01 usa dos rutas de automatizacion en paralelo:

1. `sync_lane0/sync_lane0_from_spoolman.sh`
2. `printer_data/scripts/spoolman_sync.py`

Ejemplo observado:

```cron
@reboot /home/pi/sync_lane0/sync_lane0_from_spoolman.sh >> /home/pi/printer_data/logs/lane0-sync-cron.log 2>&1
* * * * * /home/pi/sync_lane0/sync_lane0_from_spoolman.sh >> /home/pi/printer_data/logs/lane0-sync-cron.log 2>&1
@reboot python3 /home/pi/printer_data/scripts/spoolman_sync.py >> /home/pi/printer_data/logs/spoolman_sync.log 2>&1
*/5 * * * * python3 /home/pi/printer_data/scripts/spoolman_sync.py >> /home/pi/printer_data/logs/spoolman_sync.log 2>&1
```

## Relacion con el fork de Klipper

El host MA01 usa el fork de jpcurti para display:

- `https://github.com/jpcurti/ender3-v3-se-klipper-with-display`
- referencia observada en MA01: `72e925e5501429dd71bf53ad17c3a22559d2e1fb`

Implicacion operativa:

- `gcode_shell_command` no esta disponible en este fork
- `config/printer.cfg` debe mantener comentado `# [include shell_command.cfg]`
- la sincronizacion con Spoolman debe ejecutarse via cron o proceso externo

## Que si versionar

A partir de la auditoria MA01 vs repo, si quieres representar mejor el estado productivo del host, si conviene versionar:

- ejemplos de bloques Moonraker como los de arriba
- cron examples para `sync_lane0` y `spoolman_sync.py`
- notas de instalacion de Happy-Hare en modo compatible con `mmu_server`

## Que no subir tal cual

No versionar directamente desde MA01:

- `SAVE_CONFIG` especifico de maquina (`z_offset`, `bed_mesh current`, PID locales)
- backups `printer-*.cfg`, `.bak`, `.zip`, `klipper.bin`
- `.theme/`
- presets locales en `filaments/*.json`
- secretos o includes de terceros como OctoEverywhere

## Resumen

La auditoria del 2026-05-08 mostro que las macros activas del repo ya coinciden con MA01 en la parte funcional principal.

La mayor brecha estaba en la capa host/documentacion, no en `config/macros/`.
