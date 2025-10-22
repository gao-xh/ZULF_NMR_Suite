# Optional Packages Installation Guide

**Date**: October 22, 2025  
**Version**: v0.1.0  
**Severity**: Informational

---

## Overview

Some Python packages in ZULF-NMR Suite are **optional** and may require additional system components to install. The setup scripts will automatically skip these packages if the required components are not available.

---

## Optional Packages

### 1. **matlabengine** (MATLAB Integration)

**Purpose**: Provides Python interface to MATLAB for advanced simulations

**Requirements**:
- MATLAB R2024a or later installed
- MATLAB must be registered in Windows Registry
- Python version must match MATLAB's supported Python versions

**Installation Error**:
```
RuntimeError: No compatible MATLAB installation found in Windows Registry.
```

**Impact if Skipped**:
- ✅ Core application still works
- ✅ Spinach simulations still available (via subprocess)
- ❌ MATLAB Engine API not available
- ❌ Direct MATLAB workspace integration disabled

**Automatic Installation**:
The `setup_spinach` scripts will automatically install `matlabengine` after detecting MATLAB installation. This ensures the package is only installed when MATLAB is confirmed to be present.

**Manual Installation** (if you install MATLAB later):
```powershell
# Run Spinach setup again to install matlabengine
cd environments\spinach
.\setup_spinach.ps1
```

---

### 2. **psutil** (System Monitoring)

**Purpose**: Provides cross-platform process and system monitoring utilities

**Requirements**:
- **Option A**: Pre-compiled binary wheel (recommended)
- **Option B**: Microsoft Visual C++ 14.0 or greater (Build Tools)

**Installation Error**:
```
error: Microsoft Visual C++ 14.0 or greater is required.
Get it with "Microsoft C++ Build Tools"
```

**Impact if Skipped**:
- ✅ Core application still works
- ✅ All simulation features available
- ❌ System resource monitoring disabled
- ❌ Process management features limited

**Solution Options**:

#### Option A: Install from Binary Wheel (Recommended)
```powershell
cd environments\python
.\python.exe -m pip install psutil==5.9.0 --only-binary :all:
```

#### Option B: Install Visual C++ Build Tools
1. Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Install "Desktop development with C++"
3. Restart computer
4. Run setup script again

---

## Setup Script Behavior

### Automatic Handling

#### Python Environment Setup (`setup_embedded_python`)

The setup scripts (`setup_embedded_python.bat` and `setup_embedded_python.ps1`) will:

1. **First Attempt**: Try installing all packages from `requirements.txt` using binary wheels only
   ```
   pip install -r requirements.txt --only-binary :all:
   ```

2. **Second Attempt**: If binary-only fails, try selective builds (skip packages that fail)
   ```
   pip install -r requirements.txt
   ```

3. **Fallback Mode**: If full installation fails, install core packages individually
   - Required packages: **must succeed**
   - Optional packages (`psutil`): **skipped if build fails**
   - `matlabengine` is NOT installed at this stage

#### Spinach/MATLAB Setup (`setup_spinach`)

After detecting MATLAB installation, the Spinach setup scripts will:

1. **Detect MATLAB**: Search common installation paths and Windows Registry
2. **Verify MATLAB**: Confirm MATLAB executable exists and is accessible
3. **Install matlabengine**: Automatically install MATLAB Engine for Python
   - Only after MATLAB is confirmed to be present
   - Ensures installation prerequisites are met
   - Gracefully skips if installation fails (still allows subprocess mode)

### Package Classification

| Package | Type | Requires Build Tools | Installation Stage | Can Skip |
|---------|------|---------------------|-------------------|----------|
| PySide6 | Required | No | Python Setup | ❌ |
| numpy | Required | No | Python Setup | ❌ |
| scipy | Required | No | Python Setup | ❌ |
| matplotlib | Required | No | Python Setup | ❌ |
| pandas | Required | No | Python Setup | ❌ |
| **matlabengine** | **Optional** | **Yes (MATLAB)** | **Spinach Setup** | **✅** |
| **psutil** | **Optional** | **Yes (C++)** | **Python Setup** | **✅** |
| pywin32 | Required | No | Python Setup | ❌ |

---

## Verification

Check which packages were successfully installed:

```powershell
cd environments\python
.\python.exe -m pip list | findstr "matlabengine psutil"
```

**Expected Output**:
- **Both installed**: `matlabengine 25.1.2` and `psutil 5.9.0`
- **Partial**: Only one package listed
- **None**: Neither package listed (both skipped)

---

## Recommendations

### For General Users
- **No action required** - Skip both optional packages
- Core functionality fully available
- Simpler setup without external dependencies

### For MATLAB Users
- Install MATLAB before running setup
- Ensures `matlabengine` package installs successfully
- Enables direct MATLAB workspace integration

### For Developers
- Install Visual C++ Build Tools for complete development environment
- Enables building packages from source
- Required for contributing to packages with C extensions

---

## Related Documentation

- [Setuptools Build Error](./SETUPTOOLS_BUILD_ERROR.md) - Build tools dependency issues
- [MATLAB Integration](../setup/MATLAB_INTEGRATION.md) - MATLAB configuration
- [Installation Guide](../setup/INSTALLATION.md) - Complete setup instructions

---

## Support

If you encounter issues not covered in this guide:

1. Check the [Troubleshooting Index](./README.md)
2. Review terminal output for specific error messages
3. Search for similar issues on GitHub
4. Create a new issue with full error details

---

**Last Updated**: October 22, 2025  
**Applies To**: ZULF-NMR Suite v0.1.0 and later
