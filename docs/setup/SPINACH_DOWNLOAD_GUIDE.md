# Spinach Toolbox Download and Installation Guide

**Last Updated**: October 22, 2025  
**For**: ZULF-NMR Suite v0.1.0

---

## Overview

Spinach is a powerful MATLAB toolbox for spin dynamics simulations. It is **required** for using the MATLAB backend in ZULF-NMR Suite.

**Automatic Download**: The setup scripts will automatically download and install Spinach from GitHub Releases. The version is configured in `config.txt`.

---

## Configuration

The Spinach version and download URL are configured in `config.txt`:

```ini
# Spinach Toolbox Configuration
SPINACH_VERSION = 2.9.2
SPINACH_GITHUB_URL = https://github.com/IlyaKuprov/Spinach
SPINACH_OFFICIAL_URL = https://spindynamics.org/Spinach.php
```

**To update to a newer version**: Simply change `SPINACH_VERSION` in `config.txt` and re-run the setup script.

---

## Automatic Installation

Simply run the setup script and it will automatically download Spinach:

**PowerShell**:
```powershell
.\environments\spinach\setup_spinach.ps1
```

**Command Prompt**:
```cmd
.\environments\spinach\setup_spinach.bat
```

The script will:
1. Check if Spinach is already installed
2. Read the version from `config.txt`
3. Download from GitHub Releases
4. Extract and install automatically
5. Configure MATLAB integration

---

## Download Options

### ✅ Option 1: GitHub Releases (Recommended - No Registration!)

**Direct download from GitHub - fastest and easiest method**

#### Step 1: Visit GitHub Releases

Go to Spinach GitHub releases page:
```
https://github.com/IlyaKuprov/Spinach/releases
```

**Latest stable version**: [Spinach 2.9.2](https://github.com/IlyaKuprov/Spinach/releases/tag/2.9.2)

#### Step 2: Download ZIP

Click on **"Source code (zip)"** to download

**Advantages**:
- ✅ No registration required
- ✅ Direct download
- ✅ Always up to date
- ✅ Open source - can review code

#### Step 3: Extract Files

Extract the downloaded ZIP to a temporary location:

**Windows**:
```
Right-click → Extract All... → Choose a folder
```

**PowerShell**:
```powershell
Expand-Archive -Path "Spinach-2.9.2.zip" -DestinationPath "C:\Temp\Spinach"
```

#### Step 4: Copy to ZULF-NMR Suite

Copy the **contents** of the extracted `Spinach-2.9.2` folder to:
```
ZULF_NMR_Suite/environments/spinach/
```

**Important**: Copy the **contents**, not the folder itself!

**Correct structure**:
```
ZULF_NMR_Suite/
└── environments/
    └── spinach/
        ├── kernel/          ← Core Spinach files
        ├── examples/        ← Example scripts
        ├── experiments/     ← Experiment modules
        └── README.md        ← Spinach documentation
```

**Incorrect** (don't do this):
```
ZULF_NMR_Suite/
└── environments/
    └── spinach/
        └── Spinach-2.9.2/   ← Extra folder layer (wrong!)
            ├── kernel/
            └── ...
```

---

### Option 2: Official Website (Requires Registration)

If you prefer the official distribution or need support:

#### Step 1: Visit Official Website

Go to the official Spinach website:
```
https://spindynamics.org/Spinach.php
```

#### Step 2: Register (First Time Only)

Fill in the registration form with:
- **Name**: Your full name
- **Institution**: Your university/research institute
- **Email**: Academic email address (recommended)
- **Research Area**: Brief description of your work

**Note**: Registration is free for academic use.

#### Step 3: Download Spinach

1. After registration, you'll receive a download link
2. Choose the **latest stable version** (recommended)
3. Download the ZIP or TAR.GZ file to your computer

#### Step 4: Extract and Copy

Same as Option 1, steps 3-4.

---

## Quick Start (PowerShell One-Liner)

For advanced users, download and extract directly:

```powershell
# Download latest release
$url = "https://github.com/IlyaKuprov/Spinach/archive/refs/tags/2.9.2.zip"
$zipFile = "$env:TEMP\Spinach-2.9.2.zip"
$extractPath = "$env:TEMP\Spinach-2.9.2"
$targetPath = ".\environments\spinach"

# Download
Invoke-WebRequest -Uri $url -OutFile $zipFile

# Extract
Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force

# Copy contents (not the folder itself)
Copy-Item -Path "$extractPath\Spinach-2.9.2\*" -Destination $targetPath -Recurse -Force

# Cleanup
Remove-Item $zipFile, $extractPath -Recurse -Force

Write-Host "Spinach installed successfully!" -ForegroundColor Green
```

---

## Verification

### Check Installation

After copying, verify the installation:

**PowerShell**:
```powershell
cd environments\spinach
.\setup_spinach.ps1
```

**Batch**:
```batch
cd environments\spinach
setup_spinach.bat
```

You should see:
```
Step 1/6: Checking Spinach installation...
  Spinach found in:
    [your path]
  [OK] Spinach toolbox detected
```

---

## Alternative: Use Existing Installation

If you already have Spinach installed elsewhere (e.g., in your MATLAB path):

### Option A: Copy During Setup

When running `setup_spinach`, choose **Y** when asked:
```
Do you have Spinach installed elsewhere? (y/N): y
Enter Spinach installation path: C:\MATLAB\Spinach
```

The script will automatically copy Spinach to the correct location.

### Option B: Create Symbolic Link

**PowerShell (Run as Administrator)**:
```powershell
$source = "C:\Your\Existing\Spinach\Path"
$target = "C:\Path\To\ZULF_NMR_Suite\environments\spinach"

New-Item -ItemType SymbolicLink -Path $target -Target $source
```

**Note**: This avoids duplicating files but requires admin privileges.

---

## Troubleshooting

### "Spinach not found" Error

**Problem**: Setup script cannot find Spinach  
**Solution**: 
1. Check that files are in `environments/spinach/` (not in a subfolder)
2. Verify `kernel` folder exists
3. Ensure you copied the **contents** of Spinach folder, not the folder itself

**Correct**:
```
environments/spinach/kernel/...
```

**Incorrect**:
```
environments/spinach/Spinach-2.8/kernel/...
```

### "Permission Denied" When Copying

**Problem**: Cannot copy files to `environments/spinach/`  
**Solution**:
1. Run PowerShell/Command Prompt as Administrator
2. Check folder permissions
3. Use manual copy (drag and drop in File Explorer)

### MATLAB Cannot Find Spinach

**Problem**: MATLAB shows "Spinach not found in path"  
**Solution**:
1. Re-run `setup_spinach.ps1` or `setup_spinach.bat`
2. Check `config.txt` has correct `SPINACH_PATH`
3. Manually add in MATLAB:
   ```matlab
   addpath('C:\Path\To\ZULF_NMR_Suite\environments\spinach\kernel')
   ```

---

## License Information

Spinach is distributed under its own license:
- **Free for academic use**
- **Commercial use may require license**
- See Spinach documentation for full terms

**Citation**: If you use Spinach in your research, please cite:
```
Hogben, H.J., et al. "Spinach - A software library for 
simulation of spin dynamics in large spin systems."
Journal of Magnetic Resonance 208.2 (2011): 179-194.
```

---

## Alternative: Python Backend

If you cannot obtain Spinach or prefer not to use MATLAB:

### Use Python Backend Instead

ZULF-NMR Suite includes a Python-based simulation backend that doesn't require Spinach:

1. Skip Spinach setup
2. Use Python backend in the application
3. Most features work without MATLAB

**Limitations**:
- Some advanced Spinach-specific features unavailable
- Different simulation engines and algorithms

**Advantages**:
- No MATLAB license required
- Easier to install
- Cross-platform compatibility

---

## Additional Resources

### Official Documentation
- **Spinach Website**: https://spindynamics.org/
- **Spinach Manual**: Included in download (PDF)
- **Examples**: `environments/spinach/examples/`

### ZULF-NMR Suite Documentation
- [MATLAB Integration](./MATLAB_INTEGRATION.md)
- [Spinach Setup Scripts](./SPINACH_SETUP.md)
- [Troubleshooting](../troubleshooting/README.md)

### Support
- **Spinach Issues**: Contact Spinach developers
- **ZULF-NMR Suite Issues**: GitHub Issues
- **General Help**: Check docs/troubleshooting/

---

## Summary

| Step | Action | Time |
|------|--------|------|
| 1 | Visit Spinach website | 1 min |
| 2 | Register (first time only) | 2 min |
| 3 | Download Spinach | 5 min |
| 4 | Extract files | 1 min |
| 5 | Copy to `environments/spinach/` | 2 min |
| 6 | Run `setup_spinach.ps1` | 1 min |
| **Total** | **First-time setup** | **~12 min** |

**After first setup**: Configuration takes < 1 minute

---

**Last Updated**: October 22, 2025  
**Applies To**: ZULF-NMR Suite v0.1.0 and later
