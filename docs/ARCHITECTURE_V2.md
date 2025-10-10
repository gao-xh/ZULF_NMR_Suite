# New Architecture Overview

Date: October 10, 2025

## Purpose

This document describes the new modular architecture that separates simulation and data processing functionality.

## Directory Structure

```
ZULF_NMR_Suite/
├── run.py                              # Main launcher (UNCHANGED)
├── start.bat                           # Batch launcher (UNCHANGED)
├── start.ps1                           # PowerShell launcher (UNCHANGED)
├── config.txt                          # Configuration (UNCHANGED)
├── requirements.txt                    # Dependencies (UNCHANGED)
│
├── environments/                       # FUTURE: Self-contained environments
│   ├── python/                         # Embedded Python distribution
│   │   ├── python.exe
│   │   ├── Lib/
│   │   └── Scripts/
│   │
│   └── spinach/                        # MATLAB Spinach toolbox (optional)
│       ├── kernel/
│       ├── interfaces/
│       └── experiments/
│
├── src/
│   ├── simulation/                     # NEW: Simulation module
│   │   ├── ui/                         # Simulation UI components
│   │   ├── core/                       # Core simulation logic
│   │   ├── backends/                   # Backend abstraction layer
│   │   └── workers/                    # Worker threads
│   │
│   ├── processing/                     # NEW: Data processing module
│   │   ├── ui/                         # Processing UI components
│   │   ├── core/                       # Processing algorithms
│   │   ├── io/                         # Data I/O
│   │   └── workers/                    # Worker threads
│   │
│   ├── ui/                             # Shared UI components (EXISTING)
│   │   ├── splash_screen.py            # Splash screen
│   │   └── main_window.py              # NEW: Main window (to be created)
│   │
│   ├── utils/                          # Shared utilities (EXISTING)
│   │   ├── config.py
│   │   ├── icon_manager.py
│   │   └── Save_Load.py
│   │
│   └── core/                           # DEPRECATED (to be migrated)
│       ├── spinach_bridge.py           # → simulation/core/
│       └── TwoD_simulation.py          # → simulation/core/quantum_simulation.py
│
├── data/                               # NEW: Organized data storage
│   ├── experimental/                   # Experimental data (INDEPENDENT)
│   │   ├── raw/                        # Raw data from instruments
│   │   └── processed/                  # Processed experimental data
│   │
│   └── simulation/                     # Simulation data (ORGANIZED)
│       ├── presets/                    # Built-in simulation presets
│       │   ├── molecules/              # Preset molecule structures
│       │   └── parameters/             # Preset simulation parameters
│       ├── user_save/                  # User-saved simulation data
│       │   ├── molecules/              # User molecule definitions
│       │   └── parameters/             # User parameter sets
│       └── output/                     # Simulation output
│           └── spectrum/               # Exported spectra
│
├── Multi_system_spinach_UI.py          # DEPRECATED (to be moved to simulation/ui/)
│
├── presets/                            # LEGACY: To be deprecated
│   ├── molecules/                      # → data/simulation/presets/molecules/
│   └── parameters/                     # → data/simulation/presets/parameters/
│
├── user_save/                          # LEGACY: To be deprecated
│   ├── molecules/                      # → data/simulation/user_save/molecules/
│   └── parameters/                     # → data/simulation/user_save/parameters/
│
├── spectrum/                           # LEGACY: To be deprecated
│                                       # → data/simulation/output/spectrum/
│
├── docs/
├── tests/
├── assets/
└── network_interface/
```

## Design Principles

### 1. Separation of Concerns
- **Simulation**: All simulation-related code in `src/simulation/`
- **Processing**: All data processing code in `src/processing/`
- **Shared**: Common utilities in `src/utils/` and `src/ui/`

### 2. Backend Abstraction
Both simulation backends (MATLAB and Python) will implement a common interface,
allowing seamless switching between them.

### 3. Modular UI
The main window will contain tabs for:
- Simulation (existing functionality from Multi_system_spinach_UI)
- Data Processing (new experimental data processing)

### 4. Backward Compatibility
- Existing data directories preserved
- Current entry points (run.py, start.bat) unchanged
- Configuration system unchanged

## Migration Status

### Completed
- [x] Created new directory structure
- [x] Created __init__.py files
- [x] Created README documentation

### Pending
- [ ] Move Multi_system_spinach_UI.py → src/simulation/ui/simulation_panel.py
- [ ] Move src/core/spinach_bridge.py → src/simulation/core/
- [ ] Move src/core/TwoD_simulation.py → src/simulation/core/quantum_simulation.py
- [ ] Create backend abstraction layer
- [ ] Implement data processing module
- [ ] Create main_window.py to integrate both modules
- [ ] Update run.py to use new main window

## Next Steps

1. **Wait for reference code**: Need experimental data processing reference
2. **Create backend abstraction**: Unified interface for MATLAB and Python
3. **Migrate simulation code**: Move files without breaking functionality
4. **Implement processing**: Build data processing module
5. **Integrate UI**: Create main window with both tabs
6. **Test and validate**: Ensure all functionality works
7. **Clean up**: Remove deprecated files

## Notes

- All existing functionality remains unchanged during migration
- New structure coexists with old structure initially
- Gradual migration to ensure stability
- No code changes yet, only directory structure created
