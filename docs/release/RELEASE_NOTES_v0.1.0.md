# ZULF-NMR Suite v0.1.0 - Release Notes

**Release Date**: October 2025  
**Version Type**: Beta Release  
**Platform**: Windows 10/11 x64

---

## Welcome to ZULF-NMR Suite v0.1.0

This is the first public beta release of ZULF-NMR Suite, designed for internal testing and early user experience. This version includes complete simulation functionality and automated environment configuration.

---

## Key Features

### 1. Dual Simulation Backend
- **MATLAB + Spinach**: High-precision quantum spin dynamics simulation
- **Pure Python**: Fast prototyping and lightweight computation
- Runtime backend switching

### 2. Zero-Configuration First Run
- Automatic Python embedded environment detection and configuration
- Intelligent MATLAB installation detection (multi-version support)
- One-click Spinach toolbox path configuration
- No manual environment variable setup required

### 3. Modern User Interface
- Built on PySide6 (Qt 6.7.3)
- Startup animation with progress indicators
- Backend selection dialog
- Proper taskbar icon display

### 4. Convenient Launch Options
- `start.bat` - Windows CMD launcher
- `start.ps1` - PowerShell launcher
- Automatic pythonw.exe usage to avoid console windows

---

## Distribution Packages

Three distribution packages are available:

### Full Version (Recommended)
- **Filename**: `ZULF_NMR_Suite_v0.1.0_Windows_x64_Full.zip`
- **Size**: ~700MB
- **Includes**:
  - Application code
  - Embedded Python 3.12.7 environment
  - Spinach toolbox (pre-configured)
- **For**: Users with MATLAB, ready to use out-of-box

### Python Version
- **Filename**: `ZULF_NMR_Suite_v0.1.0_Windows_x64_Python.zip`
- **Size**: ~600MB
- **Includes**:
  - Application code
  - Embedded Python 3.12.7 environment
- **For**: Users only using Python backend

### Lite Version
- **Filename**: `ZULF_NMR_Suite_v0.1.0_Windows_x64_Lite.zip`
- **Size**: ~100MB
- **Includes**:
  - Application code
  - Configuration scripts
- **For**: Developers with existing Python environment

---

## Quick Start

### Prerequisites
- Windows 10 or Windows 11 (64-bit)
- (Optional) MATLAB R2021b or higher
- At least 2GB available disk space

### Installation Steps

#### Full Version Users
```
1. Extract ZULF_NMR_Suite_v0.1.0_Windows_x64_Full.zip
2. Double-click start.bat or start.ps1
3. First run will show welcome dialog
4. If you have MATLAB, run Spinach configuration once:
   environments\spinach\setup_spinach.ps1
5. Restart application
```

#### Python Version Users
```
1. Extract ZULF_NMR_Suite_v0.1.0_Windows_x64_Python.zip
2. Double-click start.bat or start.ps1
3. Application will automatically use embedded Python environment
4. Select "Python Backend" for simulation
```

#### Lite Version Users (Developers)
```
1. Extract ZULF_NMR_Suite_v0.1.0_Windows_x64_Lite.zip
2. Install Python 3.12+:
   pip install -r requirements.txt
3. Run start.ps1 or:
   python run.py
```

---

## Configuration

### Auto-Configure Python Environment
If you selected "Setup Now", or manually run:
```powershell
.\environments\python\setup_embedded_python.ps1
```
The script will automatically:
1. Download Python 3.12.7 embedded version (~100MB)
2. Configure pip
3. Install all dependencies: PySide6, numpy, matplotlib, scipy, etc.

### Auto-Configure MATLAB + Spinach
If you have MATLAB and Spinach:
```powershell
.\environments\spinach\setup_spinach.ps1
```
The script will automatically:
1. Scan system for MATLAB installations
2. Let you select version (if multiple found)
3. Detect Spinach path
4. Generate `matlab_startup.m` configuration file

After configuration, MATLAB backend will auto-load Spinach.

---

## Usage Guide

### Launch Application
- **Windows CMD**: Double-click `start.bat`
- **PowerShell**: Right-click `start.ps1` -> "Run with PowerShell"
- **Developer mode**: `python run.py`

### Select Simulation Backend
1. After startup, "Startup Configuration" dialog appears
2. Choose backend:
   - **MATLAB Backend**: Requires MATLAB + Spinach
   - **Python Backend**: Pure Python implementation
3. Choose execution mode:
   - **Local**: Local computation
   - **Workstation**: Connect to remote workstation (requires additional setup)

### Run Simulation
1. Enter simulation parameters in main interface
2. Select preset or custom configuration
3. Click "Run Simulation"
4. View result visualization

---

## Configuration Files

### config.txt
Main application configuration file, contains:
- Application version information
- Python environment path (optional)
- MATLAB minimum version requirement
- UI settings (window size, animation, etc.)

### Environment Configuration
- `.setup_complete` - First run completion marker
- `environments/python/` - Embedded Python environment
- `environments/spinach/` - Spinach toolbox
- `environments/spinach/matlab_startup.m` - MATLAB startup script

---

## Known Issues

1. **MATLAB Engine Initialization Slow**
   - First MATLAB engine startup may take 60+ seconds
   - This is normal; subsequent launches will be faster

2. **Spinach Path Detection**
   - If Spinach is installed in non-standard path, auto-detection may fail
   - Manually edit `environments/spinach/matlab_startup.m` to add path

3. **Taskbar Icon**
   - On some Windows configurations, icon may show as default Python icon
   - Does not affect functionality, visual issue only

4. **Network Connection**
   - `setup_embedded_python.ps1` first run needs to download from python.org
   - Ensure network connectivity or use full version distribution package

---

## Troubleshooting

### Application Launch Fails
```powershell
# Check Python environment
.\environments\python\python.exe --version

# Manually run application to see errors
.\environments\python\python.exe run.py
```

### MATLAB Backend Unavailable
```powershell
# Reconfigure Spinach
.\environments\spinach\setup_spinach.ps1

# Check MATLAB accessibility
matlab -batch "disp('MATLAB OK')"
```

### Dependency Package Issues
```powershell
# Reinstall dependencies
.\environments\python\python.exe -m pip install -r requirements.txt --force-reinstall
```

### View Detailed Logs
```powershell
# Enable verbose output
$env:ZULF_DEBUG = "1"
.\start.ps1
```

---

## Beta Feedback

Your feedback is very important to us! Please report:

### Feedback Content
- Success stories: Installation and running experience
- Errors and issues encountered
- Feature suggestions
- Bug reports
- Performance concerns

### Feedback Methods
- **Email**: [your-email@example.com]
- **GitHub Issues**: [repository-link] (if applicable)
- **Internal Survey**: [survey-link]

### Feedback Template
```
System Environment:
- Windows Version: _________
- MATLAB Installed: Yes / No
- MATLAB Version (if any): _________
- Distribution Package Used: Full / Python / Lite

Issue Description:


Steps to Reproduce:
1. 
2. 
3. 

Expected Behavior:


Actual Behavior:


Error Messages:


Additional Information:

```

---

## Roadmap

### v0.1.1 (Planned within 2 weeks)
- Fix critical bugs found in beta
- Optimize MATLAB engine initialization speed
- Improve error messaging

### v0.2.0 (Planned within 1 month)
- Add experimental data processing module
- Support more simulation parameters
- Batch simulation functionality
- Result export optimization

### v1.0.0 (Long-term goal)
- Complete data processing and analysis workflow
- Cloud simulation support
- Multi-language interface
- Complete user documentation

---

## License and Credits

### Development Team
- **Developer**: Xuehan Gao
- **Advisor**: Ajoy Lab
- **Version**: 0.1.0 Beta

### Dependencies
- Python 3.12.7
- PySide6 6.7.3 (Qt for Python)
- NumPy, SciPy, Matplotlib
- MATLAB (optional)
- Spinach toolbox (optional)

### License
This software is for internal research use by Ajoy Lab only. Distribution without permission is prohibited.

---

## Contact Information

For any questions, please contact:
- **Developer**: Xuehan Gao
- **Lab**: Ajoy Lab, UC Berkeley
- **Email**: [your-email@example.com]

---

**Thank you for participating in the ZULF-NMR Suite beta test! Your feedback is essential to us.**

---

*Last updated: October 2025*
