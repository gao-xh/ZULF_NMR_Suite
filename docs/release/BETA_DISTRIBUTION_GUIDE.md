# Beta Distribution Quick Guide

## Quick Start Packaging

### Option 1: Full Version (Recommended for users with MATLAB)

```powershell
# 1. Prepare Spinach (if providing full version)
# Copy your Spinach to environments/spinach/
Copy-Item "YourSpinachPath\*" -Destination ".\environments\spinach\" -Recurse

# 2. Run packaging script
.\scripts\build_distribution.ps1 -Version 0.1.0

# Generates: dist\ZULF_NMR_Suite_v0.1.0_Windows_x64.zip (~700MB)
```

### Option 2: Python Version (Python backend only)

```powershell
# Package without Spinach
.\scripts\build_distribution.ps1 -Version 0.1.0

# If you already have Spinach, skip it:
# .\scripts\build_distribution.ps1 -Version 0.1.0 -SkipSpinach

# Generates: dist\ZULF_NMR_Suite_v0.1.0_Windows_x64.zip (~600MB)
```

### Option 3: Lite Version (Users install Python themselves)

```powershell
.\scripts\build_distribution.ps1 -Version 0.1.0 -SkipPython

# Generates: dist\ZULF_NMR_Suite_v0.1.0_Windows_x64.zip (~100MB)
```

---

## Post-Package Verification

### 1. Quick Verification
```powershell
# Extract to test directory
Expand-Archive .\dist\ZULF_NMR_Suite_v0.1.0_Windows_x64.zip -DestinationPath C:\Test

# Enter and run
cd C:\Test\ZULF_NMR_Suite_v0.1.0_Windows_x64
.\start.ps1
```

### 2. Check Contents
Opening the zip file should contain:
- [x] `README.txt` - Auto-generated user guide
- [x] `start.bat` and `start.ps1` - Launch scripts
- [x] `config.txt` - Configuration file (version 0.1.0)
- [x] `src/` - Source code directory
- [x] `assets/` - Resource files (icons, animations)
- [x] `docs/` - Documentation
- [x] `requirements.txt` - Dependency list
- [x] `environments/python/setup_embedded_python.ps1` - Python install script
- [x] `environments/spinach/setup_spinach.ps1` - Spinach config script
- [x] (Optional) `environments/python/` - Embedded Python
- [x] (Optional) `environments/spinach/` - Spinach toolbox

### 3. Functionality Test Checklist
- [ ] Double-click `start.bat` or `start.ps1` launches successfully
- [ ] First run shows welcome dialog
- [ ] Taskbar icon displays correctly
- [ ] Splash screen animation is smooth
- [ ] Can select backend (MATLAB/Python)
- [ ] Simulation functionality works
- [ ] No console window flashing

---

## Distribute to Beta Users

### 1. Upload Files
Upload `dist\ZULF_NMR_Suite_v0.1.0_Windows_x64.zip` to:
- Internal file server
- OneDrive/Google Drive
- Or GitHub Releases

### 2. Prepare Documentation
Send to users:
- Download link
- `RELEASE_NOTES_v0.1.0.md` (usage instructions)
- Feedback form/email

### 3. User Quick Start Guide
```
Quick Start (for beta users):

1. Download and extract ZULF_NMR_Suite_v0.1.0_Windows_x64.zip

2. Double-click start.bat or start.ps1

3. First run will ask about environment configuration:
   - Click "Setup Now" for automatic configuration
   - Or click "Skip" to use system Python

4. If you have MATLAB, run once:
   environments\spinach\setup_spinach.ps1
   (Will auto-detect MATLAB and configure Spinach)

5. Restart application, select backend, and start using!

Problems? Contact [your-email@example.com]
```

---

## Common Issues Preparation

### Issue 1: "pythonw.exe not found"
**Reason**: Some Python environments lack pythonw.exe  
**Solution**: Launch scripts automatically fallback to python.exe, no user action needed

### Issue 2: "MATLAB detection failed"
**Reason**: MATLAB installed in non-standard path  
**Solution**: 
```powershell
# Manually specify MATLAB path
.\environments\spinach\setup_spinach.ps1
# Script will prompt for MATLAB path input
```

### Issue 3: "PySide6 import error"
**Reason**: Python environment configuration incomplete  
**Solution**:
```powershell
# Re-run Python setup
.\environments\python\setup_embedded_python.ps1
```

### Issue 4: "Taskbar icon incorrect"
**Reason**: Windows icon cache  
**Solution**: 
- Visual issue only, does not affect functionality
- Users can restart Windows Explorer to refresh icons

### Issue 5: "MATLAB engine initialization slow"
**Reason**: MATLAB engine first startup takes time  
**Solution**: 
- This is normal (~60 seconds)
- Subsequent launches will be faster
- Splash screen shows progress

---

## Collecting Feedback

### Key Metrics
- [x] Installation success rate
- [x] First-run experience
- [x] MATLAB auto-detection success rate
- [x] Functionality availability
- [x] Performance
- [x] Error frequency

### Feedback Template (send to users)
```
ZULF-NMR Suite v0.1.0 Beta Feedback

1. Basic Information
   - Windows Version: _________
   - MATLAB Installed: Yes / No
   - MATLAB Version: _________ (if any)
   - Distribution Package Used: Full / Python / Lite

2. Installation Experience (1-5 scale, 5 is best)
   - Download and extract: ___
   - First launch: ___
   - Environment configuration: ___

3. Functionality Test
   - [ ] Python backend simulation works
   - [ ] MATLAB backend simulation works
   - [ ] Interface responsive
   - [ ] Parameter save/load works

4. Issues Encountered
   Description:
   
   
   Steps to Reproduce:
   1. 
   2. 
   3. 

5. Suggestions and Comments
   
   

6. Overall Rating (1-5): ___

Thank you!
```

---

## Post-Release Checklist

### Day 1 (Release day)
- [ ] Upload distribution package
- [ ] Send notification email to beta users
- [ ] Monitor early feedback
- [ ] Prepare quick response for common issues

### Day 3 (3 days after release)
- [ ] Collect at least 5 feedbacks
- [ ] Document common issues to FAQ
- [ ] Assess if emergency fixes needed

### Day 7 (1 week after release)
- [ ] Analyze all feedback
- [ ] Create bug fix priority list
- [ ] Plan v0.1.1 fix version
- [ ] Update documentation (if needed)

### Day 14 (2 weeks after release)
- [ ] Prepare v0.1.1 fix version
- [ ] Or start planning v0.2.0 new features

---

## Success Criteria

### Minimum Requirements (Continue beta)
- [x] 70% users can install and launch successfully
- [x] 50% users complete at least one simulation
- [x] No critical crash bugs

### Ideal Goals (Prepare for public release)
- [x] 90% users install and launch successfully
- [x] 80% user satisfaction >= 4 points
- [x] Environment auto-config success rate >= 85%
- [x] MATLAB detection success rate >= 90% (among users with MATLAB)

---

## Support Channels

### During Beta
- **Email**: [your-email@example.com]
- **Response Time**: Within 24 hours
- **Support Methods**: 
  - Email technical support
  - Remote assistance (if needed)
  - Update documentation and FAQ

---

**Ready? Run the following command to start packaging:**

```powershell
# Final check
.\scripts\pre_release_check.ps1

# Start packaging (choose one option)
.\scripts\build_distribution.ps1 -Version 0.1.0
```

Good luck with the beta test!
