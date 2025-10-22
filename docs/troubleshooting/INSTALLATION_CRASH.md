# Installation Crash/Failure Troubleshooting Guide

**Last Updated**: October 22, 2025  
**Issue**: Script crashes or closes unexpectedly during Python environment setup

---

## 🐛 Common Crash Points

### 1. Crash at "Installing build tools (setuptools, wheel)"

**Symptoms**:
- Window closes immediately after showing this message
- No error message displayed
- Installation incomplete

**Root Causes**:

#### A. Missing Visual C++ Redistributable
Embedded Python 3.12 requires Microsoft Visual C++ 2015-2022 Redistributable.

**Solution**:
1. Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
2. Install the redistributable
3. Restart computer
4. Run setup again

**Check if installed**:
```powershell
# PowerShell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
    Where-Object {$_.DisplayName -like "*Visual C++*"} | 
    Select-Object DisplayName, DisplayVersion
```

#### B. Python Installation Corrupted
The embedded Python download may be incomplete or corrupted.

**Solution**:
```batch
cd environments\python
del /s /q *
setup_embedded_python.bat
```

#### C. Disk Space or Permissions
Insufficient disk space or write permissions in the directory.

**Check disk space**:
```powershell
Get-PSDrive C | Select-Object Used,Free
```

**Check write permissions**:
```batch
cd environments\python
echo test > test.txt
del test.txt
```

If you get "Access denied", run as Administrator:
- Right-click `setup_embedded_python.bat`
- Select "Run as administrator"

---

### 2. Crash at "Running pip installer"

**Symptoms**:
- Crashes after downloading get-pip.py
- May show "pip installation failed"

**Root Causes**:

#### A. Antivirus Blocking
Antivirus software may block pip from running.

**Solution**:
1. Temporarily disable antivirus
2. Run setup script
3. Re-enable antivirus
4. Add exclusion for `environments\python\` folder

#### B. Corrupted get-pip.py
Download may have been interrupted.

**Solution**:
```batch
cd environments\python
del get-pip.py
setup_embedded_python.bat
```

#### C. Network/Proxy Issues
Corporate firewall or proxy blocking PyPI access.

**Solution - Configure proxy**:
```batch
set HTTP_PROXY=http://proxy.company.com:8080
set HTTPS_PROXY=http://proxy.company.com:8080
setup_embedded_python.bat
```

---

### 3. Silent Failure (No Error Message)

**Symptoms**:
- Script seems to complete but Python doesn't work
- No obvious error messages
- Window closes normally

**Diagnostic Steps**:

#### Step 1: Check Python Installation
```batch
cd environments\python
python.exe --version
```

If this fails, Python wasn't extracted correctly.

#### Step 2: Check pip Installation
```batch
cd environments\python
python.exe -m pip --version
```

If this fails, pip wasn't installed.

#### Step 3: Manual pip Installation
```batch
cd environments\python

REM Download get-pip.py manually
powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile 'get-pip.py'"

REM Install pip with verbose output
python.exe get-pip.py -v

REM Install build tools
python.exe -m pip install setuptools wheel -v
```

---

## 🔧 Manual Installation (If All Else Fails)

If the automated script keeps failing, you can install manually:

### Step 1: Download Python
Visit: https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip

### Step 2: Extract to Environment Folder
Extract all files to:
```
ZULF_NMR_Suite\environments\python\
```

### Step 3: Enable Site Packages
Edit `python312._pth` file, change:
```
#import site
```
to:
```
import site
```

### Step 4: Download and Run get-pip.py
```powershell
cd ZULF_NMR_Suite\environments\python

# Download get-pip.py
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "get-pip.py"

# Install pip
.\python.exe get-pip.py

# Install build tools
.\python.exe -m pip install setuptools wheel

# Install requirements
.\python.exe -m pip install -r ..\..\requirements.txt
```

---

## 🧪 Diagnostic Script

Use the diagnostic script to identify the exact failure point:

```batch
cd environments\python
test_pip_install.bat
```

This script will:
- Show detailed output at each step
- Display error messages
- Identify which step is failing
- Provide system information

---

## 📋 System Requirements

### Minimum Requirements:
- **OS**: Windows 10 (64-bit) or Windows 11
- **RAM**: 4 GB (8 GB recommended)
- **Disk Space**: 2 GB free space
- **Internet**: Required for downloading packages
- **Runtime**: Visual C++ 2015-2022 Redistributable

### Software Dependencies:
- ✅ PowerShell 5.1 or later (built into Windows)
- ✅ .NET Framework 4.7.2 or later (usually pre-installed)
- ⚠️ Visual C++ Redistributable (may need installation)

---

## 🆘 Getting Help

### Before Reporting Issues:

1. **Run diagnostic script**:
   ```batch
   cd environments\python
   test_pip_install.bat > debug_log.txt 2>&1
   ```

2. **Check error log**:
   ```batch
   notepad debug_log.txt
   ```

3. **Collect system info**:
   ```powershell
   systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
   Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
       Where-Object {$_.DisplayName -like "*Visual C++*"}
   ```

### Report to GitHub:

Include:
- Full error message from `debug_log.txt`
- System information (OS version, architecture)
- Visual C++ Redistributable version
- Screenshot of the error (if possible)

Create issue at: https://github.com/gao-xh/ZULF_NMR_Suite/issues

---

## 🔍 Specific Error Messages

### "python.exe not found after extraction"

**Cause**: ZIP extraction failed or incomplete download

**Solution**:
```batch
cd environments\python
del python-embed.zip
setup_embedded_python.bat
```

### "Access is denied"

**Cause**: Insufficient permissions

**Solution**:
- Run as Administrator
- Or move project to a folder where you have write access (e.g., Desktop, Documents)

### "pip installation failed with exit code X"

**Cause**: Various reasons depending on exit code

**Exit Code Meanings**:
- `1`: General error (check internet connection)
- `2`: Command line error (pip syntax issue)
- `120`: Timeout (network too slow)
- `128`: Fatal error (corrupted Python installation)

**Solution**: Re-run with verbose output:
```batch
cd environments\python
python.exe get-pip.py -v
```

---

## ✅ Verification

After successful installation, verify:

```batch
cd environments\python

REM 1. Python version
python.exe --version
Expected: Python 3.12.7

REM 2. pip version  
python.exe -m pip --version
Expected: pip XX.X.X from ... (python 3.12)

REM 3. Build tools
python.exe -m pip list | findstr "setuptools wheel"
Expected: setuptools X.X.X
          wheel     X.X.X

REM 4. Test import
python.exe -c "import sys; print('Python OK')"
Expected: Python OK
```

---

## 🎯 Quick Fixes Summary

| Symptom | Quick Fix |
|---------|-----------|
| Crashes at setuptools | Install VC++ Redistributable |
| Access denied | Run as Administrator |
| Network timeout | Use mirror sources or proxy |
| Corrupted files | Delete and re-download |
| Antivirus blocking | Add exclusion or disable temporarily |
| Slow progress | Be patient, pip downloads can take time |

---

**Last Updated**: October 22, 2025  
**Applies To**: ZULF-NMR Suite v0.1.0 and later
