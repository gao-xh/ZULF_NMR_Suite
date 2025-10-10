# Root Directory Cleanup Guide

## Current Root Directory Status

### Core Application Files (Keep)
- `run.py` - Main launcher with splash screen
- `main_application.py` - Main application container (tab-based UI)
- `Multi_system_spinach_UI.py` - Backward compatibility wrapper
- `config.txt` - Application configuration

### Documentation (Keep)
- `README.md` - Main project documentation
- `CHANGELOG.md` - Version history
- `LICENSE` - License file
- `QUICK_REF.md` - Quick reference guide

### Dependency Files (Keep)
- `requirements.txt` - Python dependencies
- `.gitignore` - Git ignore rules

### Launch Scripts (Keep)
- `start.bat` - Windows batch launcher
- `start.ps1` - PowerShell launcher

### Directories (Keep)
- `src/` - Source code (modular architecture)
- `data/` - Data files (simulation + experimental)
- `docs/` - Documentation
- `assets/` - Icons, images, animations
- `tests/` - Test files
- `scripts/` - Utility scripts
- `environments/` - Python/MATLAB environment setup
- `network_interface/` - Cloud/network features

### Files to Remove

#### Python Cache (Auto-generated)
- `__pycache__/` - Delete (contains outdated cache from old file locations)
  - Contains: `Multi_system_spinach_UI.cpython-312.pyc`
  - Contains: `spinach_bridge.cpython-312.pyc`
  - Contains: `Save_Load.cpython-312.pyc`
  - Contains: `Dual_system_spinach_UI.cpython-312.pyc`
  - Contains: `test_matlab_init_timing.cpython-312.pyc`

These cache files reference old file locations before directory reorganization.

## Cleanup Commands

### Manual Cleanup (PowerShell)
```powershell
# Remove Python cache
Remove-Item -Path "__pycache__" -Recurse -Force -ErrorAction SilentlyContinue

# Verify cleanup
Get-ChildItem -Directory | Select-Object Name
```

### Verify Clean State
After cleanup, root directory should contain only:
```
ZULF_NMR_Suite/
├── .gitignore
├── CHANGELOG.md
├── config.txt
├── LICENSE
├── main_application.py
├── Multi_system_spinach_UI.py
├── QUICK_REF.md
├── README.md
├── requirements.txt
├── run.py
├── start.bat
├── start.ps1
├── assets/
├── data/
├── docs/
├── environments/
├── network_interface/
├── scripts/
├── src/
└── tests/
```

## Prevention

The `.gitignore` file is configured to prevent cache files from being tracked:
- `__pycache__/` is ignored
- `*.pyc`, `*.pyo`, `*.pyd` are ignored
- IDE and OS temporary files are ignored

Cache files will be regenerated automatically when running the application.

## Notes

1. **Don't commit cache**: Cache files are user/system-specific
2. **Safe to delete**: Cache files can always be regenerated
3. **Performance**: Deleting cache means first run will be slightly slower (Python recompiles)
4. **After reorganization**: Old cache files may reference wrong paths, so cleanup is needed

## Summary

The root directory is now clean and organized with:
- Clear separation of concerns (src/, data/, docs/)
- All core files in appropriate locations
- No temporary or cache files
- Modular architecture ready for expansion
