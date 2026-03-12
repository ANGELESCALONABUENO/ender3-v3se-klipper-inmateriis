# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

### Added
- Placeholder for upcoming changes.

## [1.2.0] - 2026-03-12

### Added
- `v3se-config/btt_sfs_2.0.cfg`: configuración para el sensor de filamento BTT Smart Filament Sensor 2.0 (switch + encoder), con macros `SFS_ENABLE` / `SFS_DISABLE`.
- `v3se-config/printer-creality-ender3-v3-se-2023.cfg`: archivo de referencia con el pin mapping oficial de la placa Creality 4.2.2 (STM32F103).

### Changed
- `material_z_offset.cfg`: ajuste del offset Z para PLA de `+0.20` a `+0.05` (primera capa más pegada).
- `printer.cfg`: malla de cama (BED_MESH) recalibrada con nueva pasada de `BED_MESH_CALIBRATE`.

### Fixed
- Instalado symlink `mmu_server.py` de Happy-Hare en Moonraker (`moonraker/components/`), resolviendo el error `ModuleNotFoundError: No module named 'moonraker.components.mmu_server'`.
- Resuelto crash de Klipper `TypeError: 'probe_result' object does not support item assignment` en `prtouch.py` (incompatibilidad con el objeto `ProbeResult` namedtuple de Klipper). Se realizó `FIRMWARE_RESTART` para sacar al MCU de estado de shutdown.

## [1.1.0] - 2026-03-10

### Added
- Improved `README.md` with architecture, quick-start, and maintenance notes.
- Added `LICENSE` (MIT).
- Added GitHub repository topics and project description.

## [1.0.0] - 2026-03-10

### Added
- Initial public release of Ender 3 V3 SE Klipper configuration.
- Modular macro layout (`start_print`, `queue_and_finish`, `tooling_macros`, `spoolman_bridge`).
- Spoolman lane0 sync script and cron examples.
- Filament watchdog documentation and low-stock pause flow.
