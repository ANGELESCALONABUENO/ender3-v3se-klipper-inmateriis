# OrcaSlicer Machine G-code (recomendado)

## Machine start G-code

Usa una sola linea:

```gcode
START_PRINT BED_TEMP=[bed_temperature_initial_layer_single] EXTRUDER_TEMP=[nozzle_temperature_initial_layer] FILAMENT_PROFILE="[filament_settings_id]"
```

## Machine end G-code

```gcode
PRINT_FINISHED
END_PRINT
```

## Notas

- Mantener el end g-code en Orca simple.
- La logica real de park/presentacion y apagado esta en macros de Klipper (`END_PRINT`).
- `PRINT_FINISHED` se conserva para compatibilidad con flujo de Moonraker Job Queue.
