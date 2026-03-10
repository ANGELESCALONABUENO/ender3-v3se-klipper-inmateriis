# Integracion Orca + Moonraker + Spoolman (1 extrusor, 1 lane)

## Objetivo
Hacer que OrcaSlicer detecte color y tipo de material desde Klipper/Moonraker/Spoolman sin usar 4 lanes, solo un lane (`lane0`) para impresoras de 1 extrusor.

## Que se implemento
1. Se instalo soporte Happy Hare en modo seguro (`starter`) para habilitar `mmu_server` en Moonraker.
2. Se verifico conectividad Moonraker y Spoolman remoto.
3. Se publico `lane_data` en formato compatible con Orca (clave `lane0`).
4. Se forzo modo 1 extrusor/1 lane eliminando `lane1..lane15`.
5. Se dejo automatizado con cron al arranque y cada minuto.

## Por que funciona con 1 extrusor
Orca consume `lane_data` desde Moonraker para sincronizacion de filamentos.

Para impresora de 1 extrusor se fuerza:
- solo `lane0` con spool activo
- se borran `lane1+` en cada sync

Esto evita que Orca muestre o intente mapear 4 lanes virtuales por datos residuales.

## Archivos clave
- Script canonico: `/home/pi/sync_lane0/sync_lane0_from_spoolman.sh`
- Wrapper de compatibilidad: `/home/pi/sync_lane0_from_spoolman.sh`
- Config Moonraker: `/home/pi/printer_data/config/moonraker.conf`
- Log cron: `/home/pi/printer_data/logs/lane0-sync-cron.log`

## Por que hay dos rutas del script
Para no romper instalaciones viejas, puede mantenerse `/home/pi/sync_lane0_from_spoolman.sh`.
Sin embargo, se recomienda que el cron llame directo al script canonico en `/home/pi/sync_lane0/`.

En resumen:
- Editar siempre: `/home/pi/sync_lane0/sync_lane0_from_spoolman.sh`
- Mantener por compatibilidad: `/home/pi/sync_lane0_from_spoolman.sh`

## Configuracion Moonraker requerida
En `moonraker.conf` deben existir estas secciones:

```ini
[spoolman]
server: http://192.168.1.156:7912

[mmu_server]
enable_file_preprocessor: True
enable_toolchange_next_pos: True
update_spoolman_location: True
```

## Automatizacion persistente
Crontab del usuario `pi`:

```cron
@reboot /home/pi/sync_lane0/sync_lane0_from_spoolman.sh >> /home/pi/printer_data/logs/lane0-sync-cron.log 2>&1
* * * * * /home/pi/sync_lane0/sync_lane0_from_spoolman.sh >> /home/pi/printer_data/logs/lane0-sync-cron.log 2>&1
```

## Pasos de replicacion (para otras 4 impresoras)
1. Copiar carpeta `sync_lane0` al host Klipper (`/home/pi/sync_lane0`).
2. Crear wrapper en `/home/pi/sync_lane0_from_spoolman.sh` (opcional pero recomendado para compatibilidad).
3. Ajustar en script canonico:
- `MOONRAKER_URL` (normalmente `http://127.0.0.1:7125`)
- `SPOOLMAN_URL` (tu servidor Spoolman)
4. Dar permisos:
```bash
chmod +x /home/pi/sync_lane0/sync_lane0_from_spoolman.sh
chmod +x /home/pi/sync_lane0_from_spoolman.sh
```
5. Instalar cron:
```bash
( crontab -l 2>/dev/null | grep -v 'sync_lane0_from_spoolman.sh' || true
  echo '@reboot /home/pi/sync_lane0/sync_lane0_from_spoolman.sh >> /home/pi/printer_data/logs/lane0-sync-cron.log 2>&1'
  echo '* * * * * /home/pi/sync_lane0/sync_lane0_from_spoolman.sh >> /home/pi/printer_data/logs/lane0-sync-cron.log 2>&1'
) | crontab -
```
5. Verificar:
```bash
curl -s http://127.0.0.1:7125/server/spoolman/status
curl -s "http://127.0.0.1:7125/server/database/item?namespace=lane_data&key=lane0"
```

## Validaciones utiles
- Ver todo `lane_data`:
```bash
curl -s "http://127.0.0.1:7125/server/database/item?namespace=lane_data"
```
Debe existir solo `lane0`.

- Forzar sync manual (prueba):
```bash
/home/pi/sync_lane0_from_spoolman.sh
```

## Nota importante sobre Orca
Orca sincroniza bien tipo/color, pero suele mapear a perfiles `Generic` por diseno.
Tu perfil custom (ej. `ABS_B51101_UPFILA`) normalmente se vuelve a seleccionar manualmente en Orca.

Eso no rompe la deteccion; solo separa:
- deteccion del carrete (Moonraker/Spoolman)
- perfil de impresion (preset Orca)
