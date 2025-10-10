# Modular Architecture Design - V3

## Architecture Decision

**Recommended Approach: Tab-based Modular Architecture**

Create new main program `main_application.py` as container, embedding functional modules as independent tabs.

## Directory Structure (Implemented)

```
ZULF_NMR_Suite/
├── main_application.py          # Main application container (new)
├── run.py                        # Launcher (with splash screen)
├── Multi_system_spinach_UI.py   # Backward compatibility wrapper
├── src/
│   ├── simulation/              # Simulation module
│   │   ├── __init__.py
│   │   ├── ui/
│   │   │   ├── __init__.py
│   │   │   └── simulation_window.py  # Main simulation UI (formerly Multi_system_spinach_UI.py)
│   │   ├── core/
│   │   │   ├── spinach_bridge.py     # MATLAB interface
│   │   │   └── TwoD_simulation.py    # Pure Python simulation
│   │   ├── backends/
│   │   └── workers/
│   ├── processing/              # Data processing module (to be developed)
│   │   ├── __init__.py
│   │   ├── ui/
│   │   └── core/
│   └── ui/                      # Common UI components
│       ├── __init__.py
│       ├── splash_screen.py
│       └── startup_dialog.py
```

## Why This Approach?

### Advantages:

1. **Clean Code Separation**
   - Simulation and data processing completely independent
   - Existing code unchanged
   - Easy to maintain and debug

2. **Easy to Extend**
   - Add new features by adding new tabs
   - No impact on existing modules
   - Support independent development and testing

3. **Good User Experience**
   - Unified window interface
   - Simple intuitive tab switching
   - Shared configuration and resources

## Architecture Diagram

```
MainApplication (main_application.py)
├── Tab 1: NMR Simulation
│   └── src/simulation/ui/simulation_window.py
│       └── MultiSystemSpinachUI (formerly Multi_system_spinach_UI.py)
├── Tab 2: Data Processing
│   └── src/processing/ui/processing_window.py (to be developed)
└── Tab N: Future modules...
```

## Implementation Status

Completed:
- `main_application.py` - Main container window
- `run.py` - Updated to launch new main program (switchable)
- **Directory reorganization** - Simulation module moved to `src/simulation/ui/simulation_window.py`
- **Backward compatibility** - Kept `Multi_system_spinach_UI.py` as wrapper
- Simulation module integrated as Tab 1

To be developed:
- Data processing module (Tab 2)
- Other extension features

## Migration Notes

### File Movement

- `Multi_system_spinach_UI.py` → `src/simulation/ui/simulation_window.py`
- Kept `Multi_system_spinach_UI.py` in root directory as backward compatibility wrapper

### Import Path Updates

**Old code:**
```python
from Multi_system_spinach_UI import MultiSystemSpinachUI, ENGINE
```

**New code:**
```python
from src.simulation.ui.simulation_window import MultiSystemSpinachUI, ENGINE
# or
from src.simulation import MultiSystemSpinachUI
```

**Backward compatible (still works):**
```python
from Multi_system_spinach_UI import MultiSystemSpinachUI, ENGINE
```

## How to Add New Module

1. Create new module (as QWidget)
2. Add new tab in `main_application.py`
3. No need to modify other existing code

See comments in `main_application.py` for details

## Summary

**Modifying existing program vs Creating new main program**

| Approach | Pros | Cons |
|----------|------|------|
| Modify existing | Simple and fast | Code messy, hard to maintain |
| **Create new main** | **Clear architecture, easy to extend** | Requires some additional work |

**Decision:** Adopt new main program approach, long-term benefits far outweigh short-term costs.
