# Environments Directory

This directory contains embedded environments for self-contained distribution.

## Quick Start

### Option 1: Automatic Setup (Recommended)

Run the setup script to automatically download and configure embedded Python:

**Windows (PowerShell)**:
```powershell
cd environments\python
.\setup_embedded_python.ps1
```

**Windows (CMD)**:
```batch
cd environments\python
setup_embedded_python.bat
```

This will:
1. Download Python 3.12.x embeddable package
2. Extract to `environments/python/`
3. Install pip
4. Install all dependencies from `requirements.txt`

### Option 2: Manual Setup

See `python/SETUP_GUIDE.md` for detailed manual setup instructions.

---

## Directory Structure

```
environments/
├── python/                     # Embedded Python distribution
│   ├── python.exe              # Python interpreter
│   ├── pythonXX.dll            # Python DLL
│   ├── Lib/                    # Standard library
│   │   └── site-packages/      # Third-party packages
│   └── Scripts/                # Scripts directory
│
└── spinach/                    # MATLAB Spinach toolbox
    ├── kernel/                 # Core Spinach kernel
    ├── interfaces/             # Interface modules
    ├── experiments/            # Experiment templates
    └── VERSION                 # Version information
```

## Python Integration

### Setup Instructions

1. **Download Python Embeddable Package**
   - Visit: https://www.python.org/downloads/windows/
   - Download "Windows embeddable package (64-bit)"
   - Example: `python-3.12.7-embed-amd64.zip`
   - Recommended version: Python 3.12.x

2. **Extract to this directory**
   ```powershell
   # Extract python-3.12.x-embed-amd64.zip to environments/python/
   ```

3. **Install pip**
   ```powershell
   cd environments\python
   # Download get-pip.py
   curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
   # Install pip
   .\python.exe get-pip.py
   ```

4. **Install dependencies**
   ```powershell
   .\python.exe -m pip install -r ..\..\requirements.txt
   ```

5. **Update config.txt**
   ```ini
   PYTHON_ENV_PATH = environments/python/python.exe
   ```

### Automatic Integration

When embedded Python is detected:
- Application uses embedded Python automatically
- No external Python installation required
- Fully portable distribution

### Distribution Size

- Python core: ~20 MB
- Standard library: ~50 MB
- Dependencies (PySide6, numpy, matplotlib, scipy): ~350 MB
- **Total: ~420 MB**

## Spinach Integration

### Setup Instructions

1. **Copy Spinach toolbox to this directory**
   - Download Spinach from official repository
   - Extract to `environments/spinach/`
   - Ensure all subdirectories are present

2. **Verify Structure**
   - `spinach/kernel/` should contain core functions
   - `spinach/interfaces/` should contain interface modules
   - `spinach/experiments/` should contain experiment templates

3. **Automatic Integration**
   - The application will automatically detect Spinach in this location
   - MATLAB path will be updated to include this directory
   - No manual configuration required

### Usage

When MATLAB is available, the application will:
1. Check for Spinach in `environments/spinach/`
2. Add to MATLAB path automatically
3. Fall back to system Spinach if not found
4. Use pure Python simulation if MATLAB is unavailable

### Version Compatibility

- MATLAB: R2021b or later
- Spinach: Version 2.8 or later recommended

### Distribution

This embedded Spinach is optional:
- **With Spinach**: Full MATLAB simulation capabilities
- **Without Spinach**: User must install Spinach or use Python simulation

### Size

- Spinach toolbox: ~50 MB
- No MATLAB Runtime included (user provides MATLAB)

---

For detailed integration information, see:
- [docs/setup/ENVIRONMENT_INTEGRATION.md](../docs/setup/ENVIRONMENT_INTEGRATION.md)
- [docs/ARCHITECTURE_V2.md](../docs/ARCHITECTURE_V2.md)
