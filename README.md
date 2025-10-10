# Multi-System ZULF-NMR Simulator

**Version 3.0** | **October 2025**  
Advanced ZULF-NMR simulation tool with multi-system support

[![Python Version](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/)
[![PySide6](https://img.shields.io/badge/PySide6-6.7.3-green.svg)](https://pypi.org/project/PySide6/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

---

## 📋 Overview

Multi-System ZULF-NMR Simulator is a professional scientific application for simulating Zero- to Ultra-Low Field Nuclear Magnetic Resonance (ZULF-NMR) experiments. It provides a powerful graphical interface for multi-system spectral simulation with advanced features.

### ✨ Key Features

- 🔬 **Multi-System Simulation**: Simulate up to 10 different molecular systems simultaneously
- 📊 **Real-time Visualization**: Interactive plots with matplotlib integration
- 💾 **Save/Load Projects**: Complete project state management
- 🎯 **Gaussian Broadening**: Adjustable spectral line broadening
- ⚖️ **Weighted Summation**: Combine spectra with custom weights
- 🔄 **MATLAB Integration**: Optional Spinach toolbox support
- 🎨 **Modern UI**: Professional PySide6-based interface with custom icons
- 🚀 **High Performance**: Optimized for large-scale simulations

---

## 🚀 Quick Start

### Prerequisites

- **Python**: 3.12 or later
- **MATLAB**: R2021b or later (optional, for Spinach integration)
- **Operating System**: Windows 10/11

### Installation

1. **Clone or download this repository**
   ```powershell
   cd C:\Users\YourName\Desktop
   git clone <repository-url> ZULF_NMR_Suite
   cd ZULF_NMR_Suite
   ```

2. **Install dependencies**
   ```powershell
   pip install -r requirements.txt
   ```

3. **Configure environment**
   
   Edit `config.txt` and set your Python environment path:
   ```
   PYTHON_ENV_PATH = C:/path/to/your/python.exe
   ```

4. **Launch the application**
   ```powershell
   .\start.bat
   ```
   
   Or use PowerShell launcher:
   ```powershell
   .\start.ps1
   ```
   
   Or run directly:
   ```powershell
   python run.py
   ```

---

## � Project Structure

```
ZULF_NMR_Suite/
├── run.py                        # Main launcher
├── Multi_system_spinach_UI.py    # Simulation UI (current)
├── config.txt                    # Configuration
├── requirements.txt              # Dependencies
│
├── src/                          # Source code
│   ├── simulation/               # Simulation module
│   │   ├── ui/                   # Simulation UI
│   │   ├── core/                 # Simulation engines
│   │   ├── backends/             # Backend abstraction
│   │   └── workers/              # Worker threads
│   │
│   ├── processing/               # Data processing module
│   │   ├── ui/                   # Processing UI
│   │   ├── core/                 # Processing algorithms
│   │   ├── io/                   # Data I/O
│   │   └── workers/              # Worker threads
│   │
│   ├── ui/                       # Shared UI components
│   ├── utils/                    # Utilities
│   └── core/                     # Legacy (being migrated)
│
├── data/                         # Data storage
│   ├── simulation/               # Simulation data
│   │   ├── presets/              # Built-in presets
│   │   ├── user_save/            # User-saved data
│   │   └── output/               # Simulation results
│   │
│   └── experimental/             # Experimental data
│       ├── raw/                  # Raw data from instruments
│       └── processed/            # Processed data
│
├── assets/                       # Application assets
├── docs/                         # Documentation
├── tests/                        # Test scripts
└── network_interface/            # Cloud interface (optional)
```

See [docs/ARCHITECTURE_V2.md](docs/ARCHITECTURE_V2.md) for detailed architecture.

---

## �📖 Usage

### Basic Workflow

1. **Define Molecular System**
   - Enter isotopes (e.g., `1H, 1H, 13C`)
   - Input chemical shifts
   - Specify J-coupling matrix
   - Set symmetry groups (optional)

2. **Configure Simulation**
   - Magnetic field strength
   - Sweep width
   - Number of points
   - Zero-fill factor

3. **Run Simulation**
   - Click "Run Simulation" for current system
   - View real-time progress
   - Examine spectral output

4. **Multi-System Analysis**
   - Add more systems (up to 10)
   - Adjust relative weights
   - Apply Gaussian broadening
   - View combined spectrum

5. **Save Your Work**
   - File → Save Project
   - Export spectra as CSV
   - Save presets for reuse

---

## �️ Development
│   ├── animations/               # Splash screen animations
│   └── icons/                    # Application icons
│
├── presets/                      # Preset data
│   ├── molecules/                # Molecular structures
│   ├── parameters/               # Parameter sets
│   └── spectrum/                 # Reference spectra
│
├── user_save/                    # User save files
│   ├── molecules/
│   └── parameters/
│
├── docs/                         # Documentation
│   ├── development/              # Development notes
│   └── troubleshooting/          # Troubleshooting guides
│
├── scripts/                      # Utility scripts
│   ├── png_to_ico.py            # Icon converter
│   ├── fix_qt_conflict.bat      # Qt conflict fixer
│   └── reinstall_pyside6.bat    # PySide6 reinstaller
│
└── tests/                        # Test scripts
    ├── diagnose_qt.py           # Qt diagnostic tool
    └── test_icon.py             # Icon loading test
```

---

## ⚙️ Configuration

All application settings are centralized in `config.txt`:

### Application Information
```ini
APP_NAME = ZULF-NMR Suite
APP_VERSION = 3.0
APP_DATE = October 2025
APP_AUTHOR = Xuehan Gao, Ajoy Lab
```

### Python Environment
```ini
PYTHON_ENV_PATH = D:/anaconda3/envs/matlab312/python.exe
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

## 🎨 Customization

### Adding Application Icons

1. Place your icon in `assets/icons/app_icon.png`
2. Optionally convert to ICO format:
   ```powershell
   pip install Pillow
   python scripts/png_to_ico.py assets/icons/app_icon.png
   ```
3. Restart the application

See [assets/icons/README.md](assets/icons/README.md) for icon guidelines.

### Modifying UI Settings

Edit `config.txt` to change:
- Window sizes
- Animation dimensions
- File paths
- Application metadata

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**Xuehan Gao**  
Ajoy Lab  
October 2025

---

## 🙏 Acknowledgments

- **Spinach Library** - MATLAB NMR simulation framework
- **PySide6 Team** - Qt for Python
- **Ajoy Lab** - Research support and guidance

---

## 📧 Support

For issues, questions, or contributions:
- Check the [troubleshooting guides](docs/troubleshooting/)
- Review the [QUICK_REF.md](QUICK_REF.md)
- See [CHANGELOG.md](CHANGELOG.md) for version history

---

## 🚀 Version History

### Version 3.0 (October 2025)
- ✅ Full configuration parameterization (18 parameters in config.txt)
- ✅ Universal Python environment support (conda/venv/system)
- ✅ Icon management system with PNG/ICO support
- ✅ Qt conflict resolution and troubleshooting guides
- ✅ Enhanced documentation and project structure
- ✅ Professional splash screen with animations
- ✅ Geometry warning fixes

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

---

**ZULF-NMR Suite v3.0** | Built with ❤️ by Ajoy Lab
