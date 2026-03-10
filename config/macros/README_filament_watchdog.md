# Filament Watchdog (Spoolman + Klipper)

## Objetivo
Pausar automaticamente la impresion cuando el carrete activo baje a un umbral minimo de gramos (por defecto `3.0g`).

## Fork de Klipper usado
- Esta impresora usa un fork de Klipper para soporte de `prtouch` (sensor de presion/load-cell de la punta en Ender 3 V3 SE).
- Repositorio en uso: `https://github.com/0xD34D/klipper_ender3_v3_se`
- Rama actual: `master`
- Commit verificado: `a4dc9078`

## Componentes
- `SPOOLMAN_ACTIVE`
  - Variables compartidas por macros: `nozzle_temp`, `bed_temp`, `remaining_g`, `synced`.
- `SYNC_SPOOLMAN_NOW`
  - Actualiza las variables anteriores desde el script `sync_lane0_from_spoolman.sh`.
- `FILAMENT_WATCHDOG`
  - Configuracion del monitor: `enabled`, `threshold_g`, `interval_s`, `tripped`.
- `FILAMENT_WATCHDOG_LOOP` (`delayed_gcode`)
  - Bucle que revisa periodicamente el stock y ejecuta `PAUSE` si `remaining_g <= threshold_g`.
- `RESUME` (wrapper)
  - Rearma el monitor para permitir una nueva pausa durante la misma impresion.

## Flujo de ejecucion
1. El script `/home/pi/sync_lane0/sync_lane0_from_spoolman.sh` obtiene datos de Spoolman.
2. El script ejecuta `SYNC_SPOOLMAN_NOW NOZZLE=... BED=... REMAINING_G=...`.
3. `START_PRINT` rearma el watchdog y programa una revision rapida.
4. `FILAMENT_WATCHDOG_LOOP` corre cada `interval_s` segundos.
5. Si hay impresion activa y `remaining_g <= threshold_g`, muestra aviso y hace `PAUSE`.
6. Al usar `RESUME`, el watchdog se rearma para detectar otra caida de material.

## Comandos utiles
- Ver estado del watchdog:
  - `FILAMENT_WATCHDOG`
- Ajustar umbral (gramos):
  - `FILAMENT_WATCHDOG THRESHOLD_G=3.0`
- Ajustar intervalo (segundos):
  - `FILAMENT_WATCHDOG INTERVAL_S=60`
- Activar/desactivar:
  - `FILAMENT_WATCHDOG ENABLED=1`
  - `FILAMENT_WATCHDOG ENABLED=0`
- Rearmar manualmente:
  - `FILAMENT_WATCHDOG RESET=1`

## Reinicio, corte de energia y arranque automatico
- Klipper recarga macros al iniciar, incluyendo `FILAMENT_WATCHDOG_LOOP`.
- Tu `crontab` ya contiene:
  - `@reboot /home/pi/sync_lane0/sync_lane0_from_spoolman.sh ...`
  - `* * * * * /home/pi/sync_lane0/sync_lane0_from_spoolman.sh ...`
- Eso significa que, tras reiniciar Raspberry o despues de un corte de energia, el script vuelve a ejecutarse y repuebla `remaining_g`.

## Notas para otros usuarios de Klipper
- La solucion es entendible y portable si se respetan estos requisitos:
  - Macro file incluido en `printer.cfg`.
  - Script de sincronizacion ejecutandose por `cron` o `systemd`.
  - Spoolman accesible por API desde el host Klipper.
- Si no usan Spoolman, pueden reemplazar `SYNC_SPOOLMAN_NOW` por otra fuente de `remaining_g`.
