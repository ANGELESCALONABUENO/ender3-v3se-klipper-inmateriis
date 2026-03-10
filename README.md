# Ender 3 V3 SE - Klipper Config (Inmateriis)

Configuracion real de una Ender 3 V3 SE con:

- Klipper (fork con soporte `prtouch`)
- Macros separadas por modulos
- Integracion Spoolman + Moonraker
- Watchdog de filamento por gramos restantes (pausa automatica)

## Estructura

- `config/printer.cfg`: Config principal de Klipper
- `config/macros/`: Macros operativas (start/end, queue, spoolman bridge)
- `config/v3se-config/`: Configs de `prtouch` y sensor de filamento
- `sync_lane0/`: Script y docs para sincronizar lane0 desde Spoolman

## Nota importante

Este setup usa un fork de Klipper para soporte de `prtouch` en Ender 3 V3 SE.

## Automatizacion de sync

Ejemplo cron en `sync_lane0/cron_example.txt`.

## Licencia

Uso educativo y de referencia. Ajusta offsets, temperaturas y limites para tu maquina.
