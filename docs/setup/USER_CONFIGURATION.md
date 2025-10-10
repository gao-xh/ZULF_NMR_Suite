# User Configuration System

## Overview

The application now includes a persistent user configuration system that saves MATLAB settings, Spinach configuration, and user preferences.

## Configuration File

**Location**: `user_config.json` (in project root)
**Format**: JSON
**Version Control**: Excluded from Git (user-specific)

## What Gets Saved

### MATLAB Configuration
```json
"matlab": {
  "configured": true,
  "installation_path": "C:\\Program Files\\MATLAB\\R2025a",
  "version": "R2025a",
  "engine_installed": true
}
```

### Spinach Configuration
```json
"spinach": {
  "configured": true,
  "path": "C:\\Users\\..\\environments\\spinach",
  "version": "2.8"
}
```

### User Preferences
```json
"preferences": {
  "use_matlab": false,
  "execution_mode": "local"
}
```

### History Tracking
```json
"history": {
  "first_run_date": "2025-10-10T16:30:00",
  "last_matlab_config_date": "2025-10-10T16:30:00",
  "last_spinach_config_date": null
}
```

## First Run Detection

The system tracks whether the first run has been completed:
- `first_run_completed`: Boolean flag
- `first_run_date`: ISO 8601 timestamp

This replaces the old `.setup_complete` file approach.

## Usage in Code

### Get Configuration Instance
```python
from src.utils.user_config import get_user_config

config = get_user_config()
```

### Check First Run
```python
if config.is_first_run():
    # Show setup wizard
    config.mark_first_run_complete()
```

### Save MATLAB Configuration
```python
config.set_matlab_config(
    matlab_path="C:\\Program Files\\MATLAB\\R2025a",
    version="R2025a",
    engine_installed=True
)
```

### Save Spinach Configuration
```python
config.set_spinach_config(
    spinach_path="C:\\...\\environments\\spinach",
    version="2.8"
)
```

### Save User Preferences
```python
config.set_preferences(
    use_matlab=False,  # Pure Python mode
    execution_mode="local"
)
```

### Get Saved Settings
```python
matlab_path = config.get_matlab_path()
matlab_version = config.get_matlab_version()
is_configured = config.is_matlab_configured()
is_engine_installed = config.is_matlab_engine_installed()
```

### Export Configuration Summary
```python
summary = config.export_summary()
# Returns:
# {
#   'First Run': 'Completed',
#   'MATLAB Configured': 'Yes',
#   'MATLAB Path': 'C:\\Program Files\\MATLAB\\R2025a',
#   'MATLAB Version': 'R2025a',
#   'MATLAB Engine': 'Installed',
#   'Spinach Configured': 'No',
#   'Use MATLAB': 'No (Pure Python)',
#   'Execution Mode': 'Local'
# }
```

## Version Detection

MATLAB version is automatically detected from the installation path:
```
C:\Program Files\MATLAB\R2025a  → version: "R2025a"
C:\Program Files\MATLAB\R2023a  → version: "R2023a"
```

## Status Indicators (No Emojis)

All status messages now use ASCII-compatible indicators:

| Indicator | Meaning | Color |
|-----------|---------|-------|
| `[OK]` | Success/Ready | Green |
| `[!]` | Warning/Not available | Red/Orange |
| `[i]` | Information | Gray |
| `[CONFIG]` | Configuration in progress | Orange |

## Integration Points

### 1. First Run Setup (`first_run_setup.py`)
```python
def apply_user_config(startup_config):
    user_config = get_user_config()
    
    # Mark first run complete
    if user_config.is_first_run():
        user_config.mark_first_run_complete()
    
    # Save preferences
    user_config.set_preferences(
        use_matlab=not startup_config.get('skip_matlab'),
        execution_mode=startup_config.get('execution')
    )
    
    # Save MATLAB config after successful installation
    if matlab_engine_installed:
        user_config.set_matlab_config(
            matlab_path=matlab_path,
            version=detected_version,
            engine_installed=True
        )
```

### 2. Startup Dialog (`startup_dialog.py`)
Can pre-fill MATLAB path from saved configuration:
```python
from src.utils.user_config import get_user_config

config = get_user_config()
if config.is_matlab_configured():
    self.matlab_path_input.setText(config.get_matlab_path())
```

### 3. Main Application (`main_application.py`)
Can load preferences on startup:
```python
config = get_user_config()
prefs = config.get_preferences()
use_matlab = prefs.get('use_matlab', False)
```

## File Structure

```
ZULF_NMR_Suite/
├── user_config.json         # User-specific configuration (not in Git)
├── .gitignore               # Excludes user_config.json
└── src/
    └── utils/
        ├── user_config.py   # Configuration management module
        └── first_run_setup.py  # Integrates with user_config
```

## Benefits

1. **Persistent Settings**: MATLAB path and preferences saved across runs
2. **No Re-configuration**: Settings remembered between sessions
3. **Version Tracking**: Automatically detects MATLAB version
4. **History**: Timestamps when settings were last changed
5. **Export/Import**: Configuration can be exported for backup
6. **Cross-Platform**: JSON format works everywhere
7. **No Emojis**: ASCII-only status indicators for compatibility

## Migration from Old System

Old system used:
- `.setup_complete` file (no information stored)
- No persistent MATLAB path
- Users had to re-enter settings

New system:
- `user_config.json` (full configuration)
- MATLAB path saved
- First run automatically detected
- Settings persist

## Example Configuration File

```json
{
  "first_run_completed": true,
  "matlab": {
    "configured": true,
    "installation_path": "C:\\Program Files\\MATLAB\\R2025a",
    "version": "R2025a",
    "engine_installed": true
  },
  "spinach": {
    "configured": false,
    "path": null,
    "version": null
  },
  "preferences": {
    "use_matlab": false,
    "execution_mode": "local"
  },
  "history": {
    "first_run_date": "2025-10-10T16:30:00.123456",
    "last_matlab_config_date": "2025-10-10T16:30:05.789012",
    "last_spinach_config_date": null
  }
}
```

## Future Enhancements

Potential additions:
- Import/export configuration to file
- Reset to defaults option
- Configuration validation
- Multiple MATLAB version support
- Configuration migration on version upgrades
- User-specific simulation presets
