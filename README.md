# ZULF-NMR Suite

**Version 0.1.0** | **October 2025**  
Advanced Zero- to Ultra-Low Field NMR simulation and data processing platform

[![Python Version](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/)
[![PySide6](https://img.shields.io/badge/PySide6-6.7.3-green.svg)](https://pypi.org/project/PySide6/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

---

## Overview

**ZULF-NMR Suite** is a professional scientific application designed for Zero- to Ultra-Low Field Nuclear Magnetic Resonance experiments. It provides an intuitive graphical interface for quantum spin simulation, spectral analysis, and data processing.

### Current Features (v0.1.0)

- **Quantum Spin Simulation** - High-precision spectral calculations using Spinach/MATLAB backend
- **Interactive Visualization** - Real-time spectrum plotting with matplotlib integration
- **Multi-System Analysis** - Weighted spectral summation for mixture analysis
- **Signal Processing** - Gaussian broadening, zero-filling, and baseline correction
- **Project Management** - Save/load complete simulation states and presets
- **Modern Interface** - Professional PySide6-based GUI with custom theming

### Planned Features

- **Experimental Data Processing** - Import and analyze real NMR data
- **Python Simulation Engine** - Native Python backend for faster prototyping
- **Cloud Integration** - Remote computation and collaborative workflows
- **Preset Library** - Extensive molecule and parameter database

---

## Quick Start

### System Requirements

- **Python**: 3.12+
- **MATLAB**: R2021b+ (for Spinach backend, optional)
- **OS**: Windows 10/11, macOS, Linux

### First-Time Setup (Automatic)

**ZULF-NMR Suite now features automatic environment configuration on first run!**

Simply run the launcher script, and the system will:
1. Detect first-time usage
2. Configure embedded Python environment
3. Setup Spinach/MATLAB integration (if MATLAB is installed)
4. Create all necessary configuration files

```bash
# Windows - Just run start.bat
start.bat

# PowerShell - Run start.ps1
.\start.ps1
```

The first run will display:
```
============================================================
  FIRST RUN DETECTED - Auto-Configuration Starting
============================================================

[1/2] Configuring embedded Python environment...
[2/2] Configuring Spinach/MATLAB environment...

============================================================
  First-Run Configuration Complete!
============================================================
```

### Manual Reconfiguration

If you need to reconfigure the environment later (e.g., after updating MATLAB):

```bash
# Windows
start.bat --setup

# PowerShell
.\start.ps1 --setup
```

### Manual Installation (Advanced Users)

If you prefer manual setup or need fine-grained control:

1. **Clone the repository**
   ```bash
   git clone https://github.com/gao-xh/ZULF_NMR_Suite.git
   cd ZULF_NMR_Suite
   ```

2. **Configure Python environment**
   ```bash
   # Windows
   environments\python\setup_embedded_python.bat
   
   # PowerShell
   .\environments\python\setup_embedded_python.ps1
   ```

3. **Configure Spinach/MATLAB (optional)**
   ```bash
   # Windows
   environments\spinach\setup_spinach.bat
   
   # PowerShell
   .\environments\spinach\setup_spinach.ps1
   ```

4. **Launch application**
   ```bash
   # Windows
   start.bat
   
   # PowerShell
   .\start.ps1
   
   # Direct Python
   python run.py
   ```

---

## Basic Usage

### 1. Define Your System
- Enter isotopes (e.g., `1H, 1H, 13C`)
- Input chemical shifts (in Hz)
- Specify J-coupling matrix
- Set symmetry groups (optional)

### 2. Configure Simulation
- Set magnetic field strength
- Define sweep width and resolution
- Choose zero-filling factor

### 3. Run & Analyze
- Click "Run Simulation"
- View real-time spectrum
- Apply broadening/weighting
- Save project or export data

---

## Project Structure

```
ZULF_NMR_Suite/
├── src/                    # Source code
│   ├── simulation/         # Simulation engine & UI
│   ├── processing/         # Data processing (planned)
│   ├── ui/                 # Shared UI components
│   └── utils/              # Helper functions
├── data/                   # Data storage
│   ├── simulation/         # Presets & simulation results
│   └── experimental/       # Raw & processed data (planned)
├── assets/                 # Icons, images, animations
├── docs/                   # Documentation
├── network_interface/      # Cloud integration (optional)
└── run.py                  # Main entry point
```

See [docs/ARCHITECTURE_V2.md](docs/ARCHITECTURE_V2.md) for detailed design.

---

## Configuration

The application is configured through `config.txt`. All settings use the format `KEY = VALUE`.

### Application Settings

```ini
# Basic Information
APP_NAME = ZULF-NMR Suite
APP_VERSION = 0.1.0
APP_DATE = October 2025
APP_AUTHOR = Xuehan Gao, Ajoy Lab
APP_DESCRIPTION = Advanced ZULF-NMR simulation and data processing suite

# Windows Taskbar Integration
APP_USER_MODEL_ID = AjoyLab.ZULFNMRSuite.Application.0.1
```

### Python Environment

The suite uses an embedded Python environment for better compatibility and portability:

```ini
# Python Interpreter Path
PYTHON_ENV_PATH = environments/python/python.exe

# Required Dependencies
PYSIDE6_VERSION = 6.7.3
NUMPY_REQUIRED = True
MATPLOTLIB_REQUIRED = True
```

**Note**: The embedded Python environment is pre-configured and located in `environments/python/`. You can also use your own Python installation by modifying `PYTHON_ENV_PATH`.

### MATLAB Integration (Optional)

For Spinach-based quantum spin simulations:

```ini
# MATLAB Configuration
MATLAB_REQUIRED = True
MATLAB_MIN_VERSION = R2025a
MATLAB_TOOLBOX = Spinach
```

**Setup Instructions**:
1. Install MATLAB R2021b or later
2. Install the Spinach toolbox from [spinach.uk](http://www.spinach.uk/)
3. Ensure MATLAB is in your system PATH, or the application will auto-detect it

### User Interface

Customize the splash screen and main window appearance:

```ini
# Window Dimensions
SPLASH_WINDOW_WIDTH = 700
SPLASH_WINDOW_HEIGHT = 550
ANIMATION_SIZE = 400

# Animation Assets
PNG_SEQUENCE_FOLDER = assets/animations/Starting_Animation
SPIN_SEQUENCE_FOLDER = assets/animations/Spin

# Application Icons
APP_ICON = assets/icons/app_icon.ico
APP_ICON_PNG = assets/icons/app_icon.png
SPLASH_LOGO = assets/icons/splash_logo.png
```

### File Compatibility

```ini
# Save/Load Format Version
FILE_FORMAT_VERSION = 2.0
```

Projects saved with the same `FILE_FORMAT_VERSION` are guaranteed to be compatible. See [docs/DATA_STRUCTURE.md](docs/DATA_STRUCTURE.md) for format details.

---

## Environment Setup

### Option 1: Use Embedded Python (Recommended)

The easiest way to get started is using the pre-configured embedded Python environment:

1. Download or clone the repository
2. The embedded Python is located at `environments/python/`
3. All dependencies are pre-installed
4. Simply run `start.bat` (Windows) or `start.ps1` (PowerShell)

### Option 2: Use Your Own Python

If you prefer to use your own Python installation:

1. **Install Python 3.12+**
   ```bash
   # Download from python.org or use a package manager
   ```

2. **Create a virtual environment (recommended)**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # Linux/macOS
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Update config.txt**
   ```ini
   # Point to your Python executable
   PYTHON_ENV_PATH = C:/path/to/your/python.exe
   # Or for virtual environment:
   PYTHON_ENV_PATH = venv/Scripts/python.exe
   ```

### Option 3: Use Conda Environment

For users with Anaconda or Miniconda:

1. **Create conda environment**
   ```bash
   conda create -n zulf-nmr python=3.12
   conda activate zulf-nmr
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Update config.txt**
   ```ini
   # Example path (adjust to your system)
   PYTHON_ENV_PATH = C:/Users/YourName/anaconda3/envs/zulf-nmr/python.exe
   ```

### Verify Installation

Run the test script to check your environment:

```bash
python tests/test_environment.py
```

This will verify:
- Python version compatibility
- Required package installations
- MATLAB integration (if enabled)
- Configuration file validity

---

## Development

### Current Status
- **Architecture Restructuring**: Modular separation in progress
- **Simulation Module**: src/simulation/ (engines, UI, backends)
- **Processing Module**: src/processing/ (data analysis, UI)
- **Data Organization**: data/simulation/ and data/experimental/

### Contributing
See [docs/ARCHITECTURE_V2.md](docs/ARCHITECTURE_V2.md) for architecture details.

---

## 🔧 Troubleshooting

### Antivirus/Windows Defender Blocking Downloads

If you see **"Virus detected"** during Python environment setup:
- This is a **false positive** - the script downloads official Python from python.org
- See [docs/troubleshooting/ANTIVIRUS_FALSE_POSITIVE.md](docs/troubleshooting/ANTIVIRUS_FALSE_POSITIVE.md) for solutions

Quick fix: Add `environments/python/` to Windows Defender exclusions

### Qt Plugin Errors

If you encounter Qt platform plugin errors:
```powershell
python scripts/fix_qt_conflict.bat
```

See [docs/troubleshooting/QT_PLUGIN_CONFLICT.md](docs/troubleshooting/QT_PLUGIN_CONFLICT.md) for details.

### Geometry Warnings

For geometry-related warnings, see [docs/troubleshooting/GEOMETRY_WARNING_FIX.md](docs/troubleshooting/GEOMETRY_WARNING_FIX.md).

### MATLAB Not Found

The application runs in UI-only mode if MATLAB is unavailable:
- All UI features work normally
- Simulation requires MATLAB + Spinach toolbox
- See splash screen messages for MATLAB status

---

## 📦 Dependencies

### Required
- **PySide6** 6.7.3 - Qt-based GUI framework
- **NumPy** - Numerical computing
- **Matplotlib** - Plotting and visualization

### Optional
- **MATLAB** R2021b+ - For Spinach simulations
- **Pillow** - For icon format conversion

Install all dependencies:
```powershell
pip install -r requirements.txt
```


---

## Development

### For Developers

See detailed documentation:
- [ARCHITECTURE_V2.md](docs/ARCHITECTURE_V2.md) - System design
- [PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) - Code organization
- [DEV_LOG.txt](docs/development/DEV_LOG.txt) - Development notes

### Contributing

Contributions are welcome! Future development priorities:
1. Experimental data processing module
2. Native Python simulation engine
3. Cloud integration for remote computation
4. Enhanced preset library

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## Author

**Xuehan Gao**  
Ajoy Lab, UC Berkeley  
October 2025

---

## Acknowledgments

- **Spinach** - MATLAB toolkit for spin dynamics simulation
- **PySide6** - Qt bindings for Python
- **Ajoy Lab** - Research support and scientific guidance

---

## Documentation

- [Quick Start Guide](docs/QUICK_START.md)
- [Configuration Guide](docs/setup/CONFIGURATION_GUIDE.md)
- [Troubleshooting](docs/troubleshooting/)
- [Feature Documentation](docs/features/)
- [Release Notes](docs/release/)

---

## Support

For questions or issues:
- Check [QUICK_REF.md](docs/QUICK_REF.md)
- Report bugs via GitHub Issues
- See [CHANGELOG.md](CHANGELOG.md) for updates

---

<p align="center">
  <strong>ZULF-NMR Suite v0.1.0</strong><br>
  Advanced Zero- to Ultra-Low Field NMR Platform
</p>
