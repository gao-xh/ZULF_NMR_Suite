# Changelog

All notable changes to the ZULF-NMR Suite will be documented in this file.

## [Unreleased]

### Fixed - 2025-10-22 (Critical)
- **Setuptools Dependency Error**: Fixed "Cannot import 'setuptools.build_meta'" error
  - Install setuptools and wheel immediately after pip installation
  - Prevents package build failures on fresh installations
  - Affects embedded Python setup on systems without pre-installed build tools
- **Optional Package Handling**: Smart handling of packages requiring build tools
  - `matlabengine`: Marked as optional (requires MATLAB installation)
  - `psutil`: Marked as optional (may require Visual C++ Build Tools)
  - Setup scripts automatically skip these packages if requirements not met
  - Core functionality preserved even if optional packages fail to install
  - Added clear user feedback about skipped optional packages
- **Robust Package Installation**: Multi-tier fallback mechanism
  - Tier 1: Try binary wheels only (fastest, no build tools needed)
  - Tier 2: Allow selective builds (skip packages that fail)
  - Tier 3: Install core packages individually
  - Better error messages indicating cause (network, compatibility, build deps, MATLAB)
  - Ensures minimum viable environment even with partial failures

### Added - 2025-10-22
- **Automatic First-Run Configuration**: Smart environment setup on first launch
  - Auto-detection using `.setup_complete` marker file
  - Automatic Python environment configuration
  - Automatic Spinach/MATLAB setup (if MATLAB installed)
  - `--setup` flag to force reconfiguration
  - Both BAT and PowerShell launcher support
- **Manual MATLAB Path Input**: Fallback option for non-standard installations
  - Interactive 3-option menu if auto-detection fails
  - Path validation before accepting
  - Both setup_spinach.ps1 and setup_spinach.bat support
- **Enhanced Setup Scripts**:
  - Expanded core package list from 4 to 15 packages
  - Added Spinach BAT setup script for Windows users
  - Improved error handling and user feedback
  - Better progress indication (Step 1/5, etc.)
- **Comprehensive Package Management**:
  - requirements.txt expanded to 100+ packages
  - Organized into 12 logical categories
  - Added missing dependencies (PySide6-Addons, python-dateutil, etc.)

### Changed - 2025-10-22
- **Launcher Scripts**: Major improvements to start.bat and start.ps1
  - First-run detection and auto-configuration
  - Cleaner startup flow
  - Better error messages
- **README.md**: Updated Quick Start section
  - Documented automatic first-run setup
  - Added manual reconfiguration instructions
  - Clearer installation steps
- **Setup Scripts**: Optimized for better user experience
  - Modular function design (PowerShell)
  - Enhanced MATLAB detection (5 paths + registry)
  - Installation success tracking
- **Documentation**: Removed emojis for professional appearance
- **MATLAB Requirements**: Reverted to R2021a for broader compatibility

### Fixed - 2025-10-22
- Removed problematic lock file mechanism from launcher
- Fixed .gitignore to track both PS1 and BAT setup scripts
- Corrected package versions in requirements.txt

### Changed - 2025-10-10
- **Architecture Restructuring**: Modular separation of simulation and data processing
  - Created `src/simulation/` module structure (ui/, core/, backends/, workers/)
  - Created `src/processing/` module structure (ui/, core/, io/, workers/)
  - Migrated data to organized structure:
    - `presets/` → `data/simulation/presets/`
    - `user_save/` → `data/simulation/user_save/`
    - `spectrum/` → `data/simulation/output/spectrum/`
  - Created `data/experimental/` for experimental data processing
- **Documentation Update**: Reflected new structure in README, PROJECT_STATUS, and INDEX
- **Cleanup**: Removed redundant temporary documentation files

### In Progress - 2025-10-10
- Code migration to new data paths with fallback support
- Pure Python simulation backend integration (TwoD_simulation.py)
- Experimental data processing module implementation
- Unified UI with simulation and processing tabs

---

## [3.0.0] - 2025-10-09

### Added
- **Configuration System**: Centralized `config.txt` for all application settings
  - Application information (name, version, date, author, description)
  - Python environment path configuration
  - Dependency version management
  - UI settings (window size, animation size)
  - Asset path configuration
- **Configuration Manager**: `src/utils/config.py` module for loading and accessing configuration
- **Environment Verification**: Automatic check of Python environment and dependencies on startup
- **Path-Based Environment Setup**: Support for conda, venv, and system Python via absolute paths
- **Comprehensive Documentation**:
  - Quick Start Guide
  - Configuration Guide
  - Optimization Summary
  - Development documentation
- **Test Scripts**:
  - `test_config.py` - Configuration system test
  - `test_system.py` - Comprehensive system integrity test
- **Professional Project Structure**: Organized into src/, docs/, tests/, examples/

### Changed
- **Parameterized Application Information**: All hardcoded values moved to config.txt
  - Application name and version
  - Window dimensions
  - Asset paths
  - File format version
- **Improved Launcher** (`run.py`):
  - Environment path verification
  - Dependency checking with version validation
  - Better error messages
  - Professional console output
- **Updated UI Components**:
  - Splash screen now uses config for sizes and paths
  - Main window title from config
  - About dialog uses config values
- **Code Quality Improvements**:
  - All Chinese comments translated to English
  - All emoji removed
  - Professional code structure
  - Comprehensive docstrings
  - PEP 8 compliant

### Fixed
- Import path errors in `src/ui/splash_screen.py`
- Corrected module imports to use `src.` prefix
- Fixed configuration loading issues

### Removed
- Hardcoded application name and version strings
- Hardcoded environment configuration
- Chinese text and emoji from core codebase
- Duplicate and outdated documentation files

## [2.0.0] - Previous Release

### Added
- Multi-system parallel simulation support
- System tabs for independent system management
- Weight control for spectrum combination
- Line broadening controls (Gaussian and Lorentzian)
- Enhanced save/load system with multi-system support
- Detailed logging window
- J-Coupling editor improvements

### Changed
- Complete UI refactoring for multi-system architecture
- Save file format updated to version 2.0
- Improved molecule preset system
- Enhanced spectrum visualization

## [1.0.0] - Initial Release

### Added
- Basic ZULF-NMR simulation interface
- MATLAB Spinach integration
- Single system simulation
- Molecule structure editor
- Basic parameter controls
- Spectrum visualization
- Save/load functionality

---

## Version History Summary

| Version | Date | Key Features |
|---------|------|--------------|
| 3.0.0 | 2025-10-09 | Configuration system, parameterization, code cleanup |
| 2.0.0 | Previous | Multi-system support, weight controls, enhanced UI |
| 1.0.0 | Initial | Basic simulation, MATLAB integration, single system |

## Upgrade Notes

### Upgrading to 3.0.0

**New Configuration File**
- Create or update `config.txt` in project root
- Set `PYTHON_ENV_PATH` to your Python interpreter
- Customize other settings as needed

**No Code Changes Required**
- Existing save files compatible
- All functionality preserved
- New features are optional

**Environment Setup**
- Update to path-based environment configuration
- Verify dependencies with `python test_system.py`
- Check configuration with `python test_config.py`

### Upgrading to 2.0.0

**Save File Format**
- Old format automatically detected
- Multi-system data structure
- Backward compatible loading

**UI Changes**
- New multi-system interface
- System tabs for organization
- Weight and broadening controls

## Known Issues

- MATLAB engine first-time startup can take 10-30 seconds
- Large molecular systems may require significant RAM
- File paths with spaces may need quotes in command line

## Future Plans

### Version 3.1 (Planned)
- Configuration profiles (dev/test/prod)
- GUI configuration editor
- Extended logging system
- Performance optimizations

### Version 3.2 (Planned)
- Batch processing automation
- Advanced spectrum analysis tools
- Export improvements
- Internationalization support

## Contributing

See development documentation in `docs/development/` for:
- Code style guidelines
- Testing procedures
- Documentation standards
- Contribution workflow

## Links

- Documentation: `docs/`
- Quick Start: `docs/QUICK_START.md`
- Configuration Guide: `docs/setup/CONFIGURATION_GUIDE.md`
- Development Docs: `docs/development/`

---

*For detailed Chinese changelog, see `docs/development/CHANGELOG_CN.md`*
