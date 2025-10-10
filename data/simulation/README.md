# Simulation Data Directory

This directory contains all simulation-related data, organized into three main categories.

## Directory Structure

```
simulation/
├── presets/                    # Built-in simulation presets (system-provided)
│   ├── molecules/             # Preset molecule structures
│   └── parameters/            # Preset simulation parameters
│
├── user_save/                 # User-saved simulation data (user-created)
│   ├── molecules/             # User molecule definitions
│   └── parameters/            # User parameter sets
│
└── output/                    # Simulation output (generated)
    └── spectrum/              # Exported spectra
```

## Presets

**Path:** `data/simulation/presets/`

Contains built-in molecule structures and simulation parameters provided with the software.

### Molecules
- Common molecule structures (glucose, pyruvate, alanine, etc.)
- Format: JSON files with isotopes, J-coupling matrices, symmetry information
- Read-only (not modified by users)

### Parameters
- Standard simulation parameter sets
- Format: JSON files with magnetic field, sweep width, points, etc.
- Examples for different experiment types

## User Save

**Path:** `data/simulation/user_save/`

Contains user-created and user-saved data.

### Molecules
- User-defined molecule structures
- Custom J-coupling matrices
- Modified versions of preset molecules

### Parameters
- User-saved simulation configurations
- Project-specific parameter sets
- Optimized settings for particular experiments

## Output

**Path:** `data/simulation/output/spectrum/`

Contains exported simulation results.

### Spectrum Files
- Each export creates a folder named by user
- Contents per export:
  - `setting.json` - Simulation settings used
  - `spectrum.csv` - Spectral data (frequency, real, imaginary, magnitude)
  - `information.txt` - Human-readable metadata

## Migration from Legacy Directories

Legacy data in root directories will be gradually migrated:

**Old Location** → **New Location**
- `presets/molecules/` → `data/simulation/presets/molecules/`
- `presets/parameters/` → `data/simulation/presets/parameters/`
- `user_save/molecules/` → `data/simulation/user_save/molecules/`
- `user_save/parameters/` → `data/simulation/user_save/parameters/`
- `spectrum/` → `data/simulation/output/spectrum/`

Code will support reading from both locations during transition period.
