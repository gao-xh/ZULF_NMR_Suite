# ZULF-NMR Suite v0.1.0 - October 2025 Update

## 🎉 Major Improvements

### Automatic First-Run Configuration
The suite now intelligently detects first-time usage and automatically configures the entire environment:

**What happens automatically:**
1. ✅ Detects embedded Python environment installation
2. ✅ Downloads and installs 15 core packages + 100+ dependencies
3. ✅ Detects MATLAB installation (5 paths + Windows Registry)
4. ✅ Configures Spinach toolbox integration
5. ✅ Creates all necessary configuration files

**User experience:**
```bash
# Just run the launcher - everything else is automatic!
start.bat

# Output:
============================================================
  FIRST RUN DETECTED - Auto-Configuration Starting
============================================================

[1/2] Configuring embedded Python environment...
      ✓ Downloaded Python 3.12.7 (24.8 MB)
      ✓ Installed 15 core packages
      ✓ Installed 100+ dependencies from requirements.txt

[2/2] Configuring Spinach/MATLAB environment...
      ✓ Found MATLAB R2024b
      ✓ Generated matlab_startup.m
      ✓ Updated config.txt

============================================================
  First-Run Configuration Complete!
============================================================
```

### Enhanced Setup Process

#### 1. **Expanded Package Coverage**
- **Before:** 4 core packages (PySide6, numpy, scipy, matplotlib)
- **After:** 15 core packages + complete requirements.txt (100+ packages)
- **Added packages:**
  - PySide6-Addons, PySide6-Essentials
  - python-dateutil, setuptools, wheel
  - pandas, pillow, matlabengine
  - requests, pyyaml, colorama, tqdm, psutil, pywin32

#### 2. **Intelligent MATLAB Detection**
- **Automatic detection:** Scans 5 common installation paths + Windows Registry
- **Manual fallback:** Interactive 3-option menu if auto-detection fails:
  1. Manually enter MATLAB path (with validation)
  2. Exit to install MATLAB first
  3. Use Python-only mode
- **Path validation:** Ensures `bin\matlab.exe` exists before accepting

#### 3. **Complete BAT Script Support**
- Both PowerShell (.ps1) and Batch (.bat) versions of all setup scripts
- Windows users can run setup without PowerShell
- Identical functionality across both script types

### New Features

#### Force Reconfiguration
Need to reconfigure after updating MATLAB or changing environment?

```bash
# Windows
start.bat --setup

# PowerShell
.\start.ps1 --setup
```

This removes the `.setup_complete` marker and runs the full configuration again.

#### Better Error Handling
- Clear error messages at each step
- Graceful fallback to Python-only mode if MATLAB setup fails
- Installation success/failure tracking
- Detailed progress indicators (Step 1/5, Step 2/5, etc.)

## 📋 Detailed Changes

### Launcher Scripts (`start.bat`, `start.ps1`)
- ✅ First-run detection using `.setup_complete` marker
- ✅ Automatic environment configuration on first launch
- ✅ `--setup` flag for manual reconfiguration
- ✅ Better error messages and user guidance

### Setup Scripts
**Python Setup** (`setup_embedded_python.ps1`, `setup_embedded_python.bat`):
- ✅ Modular function design (PowerShell)
- ✅ 15 core packages for reliable fallback
- ✅ Installation success counter
- ✅ File size display during download
- ✅ Better progress indication

**Spinach Setup** (`setup_spinach.ps1`, `setup_spinach.bat`):
- ✅ Enhanced MATLAB detection (5 paths + registry)
- ✅ Manual path input with validation
- ✅ Interactive 3-option menu for failures
- ✅ Version detection from VersionInfo.xml
- ✅ Improved color-coded output

### Documentation
- ✅ Updated README.md with first-run setup guide
- ✅ Added manual reconfiguration instructions
- ✅ Removed all emojis for professional appearance
- ✅ Enhanced CHANGELOG.md with latest updates

### Package Management
**requirements.txt** - Complete reorganization:
- 12 logical categories (UI Framework, Scientific Computing, etc.)
- 100+ packages with pinned versions
- Added missing dependencies
- Better comments and structure

### Bug Fixes
- ✅ Removed problematic lock file mechanism
- ✅ Fixed .gitignore to track both .ps1 and .bat setup scripts
- ✅ Corrected tqdm version (4.67.1)
- ✅ Added PySide6-Addons and PySide6-Essentials

## 🎯 User Benefits

### For First-Time Users
- **Zero manual configuration** - Just run `start.bat`
- **Clear progress feedback** - Know exactly what's happening
- **Intelligent fallbacks** - Graceful handling of missing components

### For Advanced Users
- **Manual reconfiguration** - Easy environment reset with `--setup`
- **Flexible MATLAB setup** - Manual path input for custom installations
- **Complete control** - Can still run individual setup scripts

### For Developers
- **Comprehensive packages** - All dependencies included
- **Professional structure** - Clean, well-documented code
- **Cross-platform support** - Both BAT and PowerShell scripts

## 📦 Installation Comparison

### Before (Manual Setup)
```bash
# Step 1: Clone repository
git clone https://github.com/gao-xh/ZULF_NMR_Suite.git
cd ZULF_NMR_Suite

# Step 2: Run Python setup
.\environments\python\setup_embedded_python.ps1

# Step 3: Run Spinach setup
.\environments\spinach\setup_spinach.ps1

# Step 4: Launch application
.\start.bat
```

### After (Automatic Setup)
```bash
# Step 1: Clone repository
git clone https://github.com/gao-xh/ZULF_NMR_Suite.git
cd ZULF_NMR_Suite

# Step 2: Launch application (auto-configures everything)
.\start.bat
```

**Time saved:** ~5-10 minutes per installation  
**User actions:** Reduced from 4 steps to 2 steps  
**Error potential:** Significantly reduced

## 🔧 Technical Details

### First-Run Detection
- **Marker file:** `.setup_complete` (ignored by Git)
- **Location:** Project root directory
- **Content:** Empty file serving as flag
- **Removal:** Automatic on `--setup` flag

### Package Installation Order
1. **Core packages (15)** - Essential for fallback
2. **requirements.txt** - Complete dependency set
3. **MATLAB Engine** - Only if MATLAB detected

### MATLAB Detection Paths
1. `C:\Program Files\MATLAB\`
2. `C:\Program Files (x86)\MATLAB\`
3. `D:\MATLAB\`
4. `E:\MATLAB\`
5. `C:\MATLAB\`
6. Windows Registry: `HKLM:\SOFTWARE\MathWorks\MATLAB`

## 📝 Notes

### Compatibility
- ✅ Windows 10/11
- ✅ PowerShell 5.1+
- ✅ Command Prompt (CMD)
- ✅ MATLAB R2021a+ (optional)

### Breaking Changes
- None - All changes are backward compatible
- Old manual setup process still works

### Known Issues
- None reported

## 🚀 Next Steps

Recommended actions after this update:

1. **Test automatic setup:**
   ```bash
   # Remove marker to test first-run
   del .setup_complete
   start.bat
   ```

2. **Update documentation:**
   - Review updated README.md
   - Check CHANGELOG.md for details

3. **Share feedback:**
   - Report any issues via GitHub Issues
   - Suggest improvements for future releases

## 📚 Related Documentation

- [README.md](../../README.md) - Quick Start with automatic setup
- [CHANGELOG.md](../../CHANGELOG.md) - Complete change history
- [CONFIGURATION_GUIDE.md](../setup/CONFIGURATION_GUIDE.md) - Manual configuration
- [QUICK_START.md](../QUICK_START.md) - Detailed usage guide

---

**Release Date:** October 22, 2025  
**Version:** 0.1.0 Update  
**Commits:** 10+ improvements since initial v0.1.0 release

---

<p align="center">
  <strong>Thank you for using ZULF-NMR Suite!</strong><br>
  Questions? Check our <a href="../QUICK_REF.md">Quick Reference</a> or open a GitHub Issue
</p>
