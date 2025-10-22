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
- **MATLAB**: R2021b+ (for Spinach backend)
- **OS**: Windows 10/11, macOS, Linux

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/gao-xh/ZULF_NMR_Suite.git
   cd ZULF_NMR_Suite
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Launch application**
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

Edit `config.txt` to customize settings:

```ini
# Application Info
APP_NAME = ZULF-NMR Suite
APP_VERSION = 0.1.0

# Python Environment
PYTHON_ENV_PATH = environments/python/python.exe

# MATLAB Settings (optional)
MATLAB_PATH = C:/Program Files/MATLAB/R2023b
SPINACH_PATH = C:/Spinach
```

### UI Settings
```ini
SPLASH_WINDOW_WIDTH = 700
SPLASH_WINDOW_HEIGHT = 550
ANIMATION_SIZE = 400
```

### Icon Assets
```ini
APP_ICON = assets/icons/app_icon.ico
APP_ICON_PNG = assets/icons/app_icon.png
SPLASH_LOGO = assets/icons/splash_logo.png
```

See `config.txt` for complete configuration options.

---

## �️ Development

### Current Status
- **Architecture Restructuring**: Modular separation in progress
- **Simulation Module**: src/simulation/ (engines, UI, backends)
- **Processing Module**: src/processing/ (data analysis, UI)
- **Data Organization**: data/simulation/ and data/experimental/

### Contributing
See [docs/ARCHITECTURE_V2.md](docs/ARCHITECTURE_V2.md) for architecture details.

---

## �🔧 Troubleshooting

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

Xuehan Gao  
Ajoy Lab, UC Berkeley  
October 2025

---

## Acknowledgments

- Spinach - MATLAB toolkit for spin dynamics simulation
- PySide6 - Qt bindings for Python
- Ajoy Lab - Research support and scientific guidance

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
  ZULF-NMR Suite v0.1.0<br>
  Advanced Zero- to Ultra-Low Field NMR Platform
</p>
