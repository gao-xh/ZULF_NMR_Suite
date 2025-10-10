# Spinach Toolbox Integration

This directory is reserved for the MATLAB Spinach toolbox.

## Quick Setup (Recommended)

Run the auto-setup script to detect MATLAB and configure Spinach:

```powershell
.\setup_spinach.ps1
```

This will:
1. Detect your MATLAB installation
2. Configure Spinach path
3. Create MATLAB startup script
4. Test the connection

## Manual Installation

### Option 1: Copy Existing Spinach

If you have Spinach installed:
```matlab
% In MATLAB, find your Spinach installation
which spinach
% Copy that entire directory here
```

### Option 2: Download Fresh Copy

1. Download Spinach from: https://spindynamics.org/Spinach.php
2. Extract the archive
3. Copy all contents to this `environments/spinach/` directory

## Expected Structure

After installation, this directory should contain:

```
spinach/
├── kernel/                     # Core computation engine
│   ├── grids/
│   ├── operators/
│   ├── propagation/
│   └── utilities/
│
├── interfaces/                 # User interfaces
│   ├── nmr/
│   ├── esr/
│   └── general/
│
├── experiments/                # Experiment templates
│   ├── nmr_liquids/
│   ├── nmr_solids/
│   └── zeeman_zulf/
│
├── auxiliary/                  # Helper functions
├── etc/                        # Configuration files
└── VERSION                     # Version file
```

## Verification

To verify correct installation:
1. Launch the application
2. Check splash screen for "Spinach: Detected (embedded)"
3. If not detected, check MATLAB path and directory structure

## Auto-Detection

The application automatically:
- Detects Spinach in this location on startup
- Adds to MATLAB path if MATLAB is available
- Falls back to system Spinach if this is empty
- Uses pure Python simulation if MATLAB is unavailable

## License

Spinach is distributed under its own license terms.
Please ensure compliance with Spinach licensing when distributing.

## More Information

- Spinach Documentation: http://spindynamics.org/
- Integration Details: See `docs/setup/ENVIRONMENT_INTEGRATION.md`
