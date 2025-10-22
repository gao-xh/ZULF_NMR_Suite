# Setuptools Build Error Fix

## Problem Description

When running the embedded Python setup script on a fresh system, you may encounter this error:

```
ERROR: Exception:
pip._vendor.pyproject_hooks._impl.BackendUnavailable: 
Cannot import 'setuptools.build_meta'
```

This error occurs during package installation when pip tries to build packages from source but cannot find the required build tools.

## Root Cause

The embedded Python distribution does not include `setuptools` by default. When pip tries to install packages that require compilation or building (like numpy, scipy, etc.), it needs setuptools to prepare the package metadata and build the package.

**Build process flow:**
1. pip downloads package source
2. pip calls `setuptools.build_meta` to prepare package
3. **ERROR**: setuptools not found
4. Installation fails

## Solution

The setup scripts have been updated to install build tools immediately after pip:

### Automatic Fix (Latest Version)

The current setup scripts automatically handle this:

```batch
# After installing pip:
python -m pip install --upgrade setuptools wheel
```

**Why this works:**
- `setuptools`: Provides package building and metadata tools
- `wheel`: Enables binary wheel installation (faster, no compilation needed)
- Installed BEFORE other packages ensures they can build correctly

### Manual Fix (If Using Older Scripts)

If you're using older setup scripts or encounter this error:

**Windows (BAT):**
```batch
cd environments\python
python.exe -m pip install --upgrade setuptools wheel
python.exe -m pip install -r ..\..\requirements.txt
```

**PowerShell:**
```powershell
cd environments\python
.\python.exe -m pip install --upgrade setuptools wheel
.\python.exe -m pip install -r ..\..\requirements.txt
```

## Prevention

To avoid this issue in future installations:

1. **Use Latest Setup Scripts**: Always pull the latest version
   ```bash
   git pull origin main
   ```

2. **Update First-Run Setup**: If `.setup_complete` exists, force reconfiguration
   ```batch
   start.bat --setup
   ```

3. **Verify Build Tools**: Check if setuptools is installed
   ```batch
   python -m pip show setuptools
   ```

## Fallback Mechanism

If `requirements.txt` installation fails, the setup scripts now:

1. **Show clear error message**:
   ```
   [ERROR] Full requirements.txt installation failed
   
   This may be due to:
     - Network connection issues
     - Package compatibility problems
     - Missing build dependencies
   
   Attempting to install core packages only...
   ```

2. **Install 15 essential packages individually**:
   - PySide6 (UI framework)
   - NumPy, SciPy, Matplotlib (scientific computing)
   - Pandas, Pillow (data processing, imaging)
   - And 8 more core packages

3. **Report success count**:
   ```
   Installed 14/15 packages successfully
   [OK] Essential packages installation complete
   ```

This ensures you get a working environment even if some packages fail.

## Related Issues

### Similar Errors

You may see variations of this error:

**Missing wheel:**
```
ERROR: Failed building wheel for <package>
```
**Solution:** Install wheel first
```batch
python -m pip install wheel
```

**Missing compiler:**
```
error: Microsoft Visual C++ 14.0 or greater is required
```
**Solution:** Install pre-built wheels or Visual C++ Build Tools

**Network timeout:**
```
ERROR: Could not find a version that satisfies the requirement
```
**Solution:** Check internet connection, try again later, or use --timeout flag

### Package-Specific Issues

**NumPy/SciPy compilation errors:**
- Use pre-built wheels (automatically done with wheel installed)
- Or install from conda-forge if using conda

**MATLAB Engine installation:**
- Requires MATLAB installation
- Uses MATLAB's own setup.py (not affected by this setuptools issue)

## Technical Details

### Why Embedded Python?

The ZULF-NMR Suite uses embedded Python for:
- **Portability**: Self-contained environment
- **Isolation**: No system Python conflicts
- **Control**: Exact version and dependencies
- **Distribution**: Easy deployment to users

### Build Tools Explained

**setuptools:**
- Builds Python packages from source
- Handles package metadata and dependencies
- Required for packages without pre-built wheels

**wheel:**
- Binary package format (.whl files)
- Pre-compiled, no build needed
- Faster installation and more reliable

**pip:**
- Package installer
- Coordinates setuptools and wheel
- Downloads from PyPI

### Installation Order Matters

```
1. Python embedded     (base interpreter)
2. Enable site-packages (allow package installation)
3. Install pip         (package manager)
4. Install setuptools + wheel (build tools) ← CRITICAL
5. Install packages    (application dependencies)
```

If step 4 is skipped, packages requiring building will fail at step 5.

## Verification

After running the setup, verify build tools are installed:

```batch
cd environments\python

# Check setuptools
python.exe -m pip show setuptools

# Expected output:
# Name: setuptools
# Version: 75.x.x
# Location: ...

# Check wheel
python.exe -m pip show wheel

# Expected output:
# Name: wheel
# Version: 0.45.x
# Location: ...
```

## Support

If you still encounter issues after applying this fix:

1. **Delete and reinstall**:
   ```batch
   # Remove .setup_complete marker
   del .setup_complete
   
   # Run setup again
   start.bat --setup
   ```

2. **Check Python version**:
   ```batch
   environments\python\python.exe --version
   ```
   Should be Python 3.12.7

3. **Check pip version**:
   ```batch
   environments\python\python.exe -m pip --version
   ```
   Should be pip 24.x or later

4. **Report on GitHub**:
   - Open an issue with error log
   - Include Python and pip versions
   - Mention operating system

## References

- [Python Packaging Guide](https://packaging.python.org/)
- [setuptools Documentation](https://setuptools.pypa.io/)
- [pip Documentation](https://pip.pypa.io/)
- [PEP 517 - Build System](https://peps.python.org/pep-0517/)

---

**Last Updated:** October 22, 2025  
**Applies To:** ZULF-NMR Suite v0.1.0 and later  
**Fixed In:** Commit 58097a8
