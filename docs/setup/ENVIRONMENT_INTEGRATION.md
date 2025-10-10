# Environment Integration Plan

Date: October 10, 2025

## Overview

This document describes the plan for integrating Python and MATLAB Spinach environments into the project for self-contained distribution.

## Goals

1. **Self-Contained Distribution**: No external installation required
2. **Version Control**: Ensure consistent environment across deployments
3. **Easy Deployment**: Single folder copy to deploy
4. **Dual Backend Support**: Both MATLAB Spinach and Pure Python

---

## Option 1: Embedded Python

### Structure
```
environments/
└── python/                          # Python embeddable package
    ├── python.exe                   # Python interpreter (~20 MB)
    ├── pythonXX.dll
    ├── python3.dll
    ├── Lib/                         # Standard library (~50 MB)
    │   ├── site-packages/           # Third-party packages
    │   │   ├── PySide6/             # ~150 MB
    │   │   ├── numpy/               # ~50 MB
    │   │   ├── matplotlib/          # ~40 MB
    │   │   └── scipy/               # ~80 MB
    │   └── ...
    └── Scripts/
        └── pip.exe
```

### Total Size
- Base Python: ~20 MB
- Standard Library: ~50 MB
- Dependencies: ~350 MB
- **Total: ~420 MB**

### Advantages
- No user installation required
- Consistent Python version across all deployments
- Portable, can be copied to any location
- Fast startup (no conda activation)

### Implementation Steps

1. **Download Python Embeddable Package**
   ```powershell
   # Download from python.org
   # Example: python-3.12.7-embed-amd64.zip
   ```

2. **Setup pip in Embedded Python**
   ```powershell
   # Download get-pip.py
   # Run: python.exe get-pip.py
   ```

3. **Install Dependencies**
   ```powershell
   .\python.exe -m pip install -r requirements.txt
   ```

4. **Update config.txt**
   ```ini
   PYTHON_ENV_PATH = environments/python/python.exe
   ```

5. **Update Launcher Scripts**
   ```batch
   REM start.bat
   set PYTHON_PATH=%~dp0environments\python\python.exe
   "%PYTHON_PATH%" run.py
   ```

---

## Option 2: MATLAB Spinach Integration

### Option 2A: Full MATLAB Runtime + Spinach

#### Structure
```
environments/
└── matlab_runtime/                  # MATLAB Runtime R2023b
    ├── bin/                         # ~1.5 GB
    ├── toolbox/                     # ~500 MB
    └── spinach/                     # Spinach toolbox (~50 MB)
        ├── kernel/
        ├── interfaces/
        └── experiments/
```

#### Total Size: ~2-3 GB

#### Advantages
- Full MATLAB functionality
- All Spinach features available
- No MATLAB license required on client machine

#### Disadvantages
- Very large distribution size
- Requires MATLAB Compiler license to create
- Slower startup time

---

### Option 2B: Standalone Spinach Toolbox

#### Structure
```
environments/
└── spinach/                         # Spinach source code
    ├── kernel/
    ├── interfaces/
    ├── experiments/
    └── VERSION
```

#### Total Size: ~50 MB

#### Advantages
- Small footprint
- Easy to update
- Users can use their own MATLAB installation

#### Disadvantages
- Requires user to have MATLAB installed
- Version compatibility issues possible

#### Implementation
1. Copy Spinach toolbox to `environments/spinach/`
2. Update `spinach_bridge.py` to add path:
   ```python
   import os
   import matlab.engine
   
   # Add embedded Spinach to MATLAB path
   spinach_path = os.path.join(os.path.dirname(__file__), 
                                '../../environments/spinach')
   eng.addpath(spinach_path, nargout=0)
   ```

---

## Recommended Approach

### Phase 1: Embedded Python (Immediate)
- Implement embedded Python distribution
- Size: ~420 MB (acceptable)
- Benefits: Self-contained, no user setup
- Improves user experience significantly

### Phase 2: Pure Python Simulation (Priority)
- Complete integration of `TwoD_simulation.py`
- No MATLAB required for basic simulations
- Faster execution for simple systems
- Size: No additional overhead

### Phase 3: Optional Spinach Integration (Future)
- Provide Spinach toolbox in `environments/spinach/`
- Auto-detect and add to MATLAB path
- Users install MATLAB separately if needed
- Keep distribution size reasonable

---

## Configuration Updates

### config.txt
```ini
# Environment Paths
PYTHON_ENV_PATH = environments/python/python.exe
MATLAB_SPINACH_PATH = environments/spinach
USE_EMBEDDED_PYTHON = true
USE_EMBEDDED_SPINACH = true

# Backend Selection
DEFAULT_BACKEND = python    # Options: python, matlab
MATLAB_AUTO_DETECT = true
```

### Environment Detection Logic
```python
def detect_environment():
    """Detect available simulation backends."""
    backends = {}
    
    # Check embedded Python
    embedded_python = os.path.join(BASE_DIR, 'environments/python/python.exe')
    if os.path.exists(embedded_python):
        backends['embedded_python'] = embedded_python
    
    # Check embedded Spinach
    embedded_spinach = os.path.join(BASE_DIR, 'environments/spinach')
    if os.path.exists(embedded_spinach):
        backends['embedded_spinach'] = embedded_spinach
    
    # Check system MATLAB
    try:
        import matlab.engine
        backends['system_matlab'] = True
    except:
        backends['system_matlab'] = False
    
    return backends
```

---

## Distribution Scenarios

### Scenario 1: Minimal Distribution (Current)
- Size: ~50 MB
- Includes: Source code, assets, documentation
- User provides: Python + dependencies, optionally MATLAB + Spinach
- Target: Developers, users with existing Python setup

### Scenario 2: Python-Bundled Distribution (Recommended)
- Size: ~470 MB
- Includes: Embedded Python + all dependencies + source code
- User provides: Optionally MATLAB + Spinach for advanced features
- Target: End users, easy deployment

### Scenario 3: Full-Bundled Distribution (Future)
- Size: ~2.5 GB
- Includes: Everything (Python + MATLAB Runtime + Spinach)
- User provides: Nothing
- Target: Users without any technical setup

---

## Implementation Priority

1. **High Priority**: Embedded Python integration
   - Immediate value
   - Reasonable size
   - Eliminates most user setup issues

2. **Medium Priority**: Pure Python simulation backend
   - Reduces MATLAB dependency
   - Better performance for simple cases
   - Already have `TwoD_simulation.py`

3. **Low Priority**: MATLAB Runtime bundling
   - Large size
   - License complexity
   - Most users can install MATLAB separately

---

## Next Steps

1. Create `environments/` directory structure
2. Set up embedded Python distribution
3. Update launchers to use embedded Python
4. Update documentation with distribution options
5. Test on clean machine without Python installed
6. Create installation guide for embedded version

---

## Considerations

### Licensing
- Python: Open source, freely distributable
- MATLAB Runtime: Free to distribute, requires Compiler license to create
- Spinach: Check license terms for redistribution

### Updates
- Embedded Python: Manual update process
- Spinach: Can be updated independently
- Dependencies: Include `update_dependencies.bat` script

### Platform Support
- Windows: Primary target (embed-amd64.zip)
- Linux: Also available (embed-linux-x86_64.tar.gz)
- macOS: Available but different structure

---

## File Size Summary

| Component | Size | Required |
|-----------|------|----------|
| Source Code | ~10 MB | Yes |
| Assets | ~20 MB | Yes |
| Embedded Python | ~70 MB | Optional |
| Python Dependencies | ~350 MB | If using embedded |
| Spinach Toolbox | ~50 MB | Optional |
| MATLAB Runtime | ~2 GB | Optional |

**Recommended Distribution: ~450 MB** (Source + Embedded Python + Dependencies)
