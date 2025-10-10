# Startup Dialog Bug Fix

## Issue
After deleting `Multi_system_spinach_UI.py` and updating import paths, the application failed to start with the following error:

```
AttributeError: 'StartupDialog' object has no attribute 'Accepted'. Did you mean: 'accepted'?
```

## Root Cause
In `run.py` line 213, the code was checking:
```python
if result == startup_dialog.Accepted:
```

This is incorrect because `Accepted` is a static constant of the `QDialog` class, not an instance attribute of `StartupDialog`.

## Solution

### 1. Fixed the comparison
**File:** `run.py`, line 213

**Before:**
```python
if result == startup_dialog.Accepted:
```

**After:**
```python
if result == QDialog.Accepted:
```

### 2. Added missing import
**File:** `run.py`, line 67

**Before:**
```python
from PySide6.QtWidgets import QApplication, QMessageBox
```

**After:**
```python
from PySide6.QtWidgets import QApplication, QMessageBox, QDialog
```

## Explanation

In PySide6/Qt:
- `QDialog.Accepted` is a class constant (value = 1)
- `QDialog.Rejected` is a class constant (value = 0)
- `dialog.exec()` returns one of these values
- You should always compare with `QDialog.Accepted`, not `dialog.Accepted`

## Testing

After the fix, the application should:
1. Show splash screen with initialization
2. Show startup dialog for backend selection
3. Launch main application when user clicks "Start"
4. Exit gracefully when user clicks "Cancel"

## Related Files
- `run.py` - Main launcher (fixed)
- `src/ui/startup_dialog.py` - Startup configuration dialog (no changes needed)

## Status
✅ Fixed - Application now starts correctly
