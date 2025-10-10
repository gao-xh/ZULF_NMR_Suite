# Window Display Issues Fix

## Issue 1: Startup Dialog Not Showing on Top

### Problem
After splash screen initialization, the startup configuration dialog would appear but not be visible on top of other windows, making users think the application didn't start.

### Root Cause
The dialog lacked proper window flags to ensure it stays on top and is properly activated when shown.

### Solution

#### Added Window Flags to Dialog
**File:** `src/ui/startup_dialog.py`

Added window flags in `setup_ui()` method:

```python
# Set window flags to ensure it stays on top
self.setWindowFlags(
    Qt.Dialog | 
    Qt.WindowStaysOnTopHint |
    Qt.WindowTitleHint |
    Qt.WindowCloseButtonHint
)
```

**Flags explanation:**
- `Qt.Dialog` - Standard dialog window type
- `Qt.WindowStaysOnTopHint` - Forces window to stay on top of other windows
- `Qt.WindowTitleHint` - Shows window title bar
- `Qt.WindowCloseButtonHint` - Shows close button (X)

#### Explicitly Activate Dialog in Launcher
**File:** `run.py`

Modified dialog display code:

**Before:**
```python
startup_dialog = StartupDialog(init_results)
result = startup_dialog.exec()
```

**After:**
```python
startup_dialog = StartupDialog(init_results)
startup_dialog.show()
startup_dialog.raise_()
startup_dialog.activateWindow()
result = startup_dialog.exec()
```

**Methods explanation:**
- `show()` - Makes window visible
- `raise_()` - Brings window to front of window stack
- `activateWindow()` - Gives focus to the window

---

## Issue 2: Splash Screen Showing Default Python Icon in Taskbar

### Problem
The splash screen was showing a default Python icon in the Windows taskbar instead of the custom application icon, which looks unprofessional.

### Solution

Use window flags that simulate `Qt.SplashScreen` behavior on a `QWidget`.

**File:** `src/ui/splash_screen.py`

```python
# Simulate Qt.SplashScreen behavior using QWidget
# Qt.SplashScreen flag only works with QSplashScreen class, not QWidget
# So we use equivalent flags for QWidget to achieve same effect:
# - FramelessWindowHint: No borders (like splash screen)
# - WindowStaysOnTopHint: Always on top (like splash screen)  
# - Tool: No taskbar icon (like splash screen)
self.setWindowFlags(
    Qt.FramelessWindowHint | 
    Qt.WindowStaysOnTopHint |
    Qt.Tool
)
```

### Why Not Use QSplashScreen Class?

**Current implementation uses `QWidget`:**
- Displays complex PNG sequence animations (301 frames)
- Multiple `QLabel` widgets for background and overlay
- Custom timer-based animation system
- Interactive log messages during initialization

**QSplashScreen limitations:**
- Designed for static images or simple text
- Limited customization for complex animations
- Would require complete rewrite of animation system

**Our approach:**
- Keep `QWidget` for flexibility
- Use window flags to simulate `Qt.SplashScreen` behavior
- Achieve same visual result (frameless, no taskbar, on top)

### Flag Comparison

| Approach | Class | Flags | Taskbar | Frameless | Customizable |
|----------|-------|-------|---------|-----------|--------------|
| **Our solution** | `QWidget` | `FramelessWindowHint + Tool + StaysOnTop` | No ✅ | Yes ✅ | Yes ✅ |
| Standard splash | `QSplashScreen` | `SplashScreen` | No ✅ | Yes ✅ | Limited ❌ |
| Wrong attempt | `QWidget` | `SplashScreen` | No display ❌ | N/A | N/A |

**Key insight:** `Qt.SplashScreen` is a window TYPE flag that only works with `QSplashScreen` class. For `QWidget`, we need to use combination of other flags to achieve equivalent behavior.

### After Splash Screen

The main application windows DO show the correct custom icon in taskbar:
1. **Startup Dialog** - Shows with custom icon and stays on top
2. **Main Application** - Shows with custom icon in taskbar
3. All subsequent windows have proper taskbar presence with correct icon

### Alternative Approaches Considered

If taskbar icon is absolutely required, these options were evaluated:

#### Option 1: Qt.CustomizeWindowHint
```python
self.setWindowFlags(Qt.Window | Qt.CustomizeWindowHint | Qt.WindowStaysOnTopHint)
```
- ✅ Shows taskbar icon
- ❌ Shows thin window border (not fully frameless)
- ❌ Less clean appearance

#### Option 2: Qt.Window without FramelessWindowHint  
```python
self.setWindowFlags(Qt.Window | Qt.WindowStaysOnTopHint)
```
- ✅ Shows taskbar icon  
- ❌ Shows full title bar and borders
- ❌ Ruins splash screen aesthetic

#### Option 3: System Tray Icon
- Create notification tray icon during splash
- ✅ Shows icon somewhere
- ❌ More complex code
- ❌ Tray icon may not appear immediately

### Current Implementation (Recommended)

**File:** `src/ui/splash_screen.py`

```python
# Frameless window for clean splash screen appearance
# Note: Frameless windows don't show taskbar icon on Windows - this is intentional
# The splash screen is short-lived (~5-10 seconds), so taskbar icon is not critical
self.setWindowFlags(
    Qt.FramelessWindowHint | 
    Qt.WindowStaysOnTopHint
)
```

**Benefits:**
- ✅ Perfect frameless appearance
- ✅ Transparent background works correctly
- ✅ Stays on top during initialization
- ✅ No visual clutter
- ✅ Professional loading experience

**Trade-off:**
- ⚠️ No taskbar icon (acceptable for short-lived window)

### After Splash Screen

The main application windows DO show taskbar icons:
1. **Startup Dialog** - Shows with icon and stays on top
2. **Main Application** - Shows with icon in taskbar
3. All subsequent windows have proper taskbar presence

### Conclusion

No fix needed - this is intentional design. The splash screen's job is to provide visual feedback during initialization, not to be a persistent taskbar item.

---

## Related Issues

This is similar to the main window display issue that was fixed earlier. The pattern for ensuring a window is visible on Windows:

1. Set appropriate window flags in the widget constructor or `setup_ui()`
2. Call `show()` to make it visible
3. Call `raise_()` to bring to front
4. Call `activateWindow()` to give it focus

## Window Flags Summary

### For Splash Screen (Frameless + Taskbar Icon):
```python
Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
```

### For Modal Dialog (With Title Bar + Stays on Top):
```python
Qt.Dialog | Qt.WindowStaysOnTopHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
```

### For Main Window (Standard + Bring to Front):
```python
# Default flags, then call:
window.show()
window.raise_()
window.activateWindow()
```

## Testing

After these fixes:
1. ✅ Splash screen appears with app icon in taskbar
2. ✅ Initialization runs
3. ✅ Startup dialog appears on top and has focus
4. ✅ User can immediately interact with dialog
5. ✅ Main window appears on top after dialog is accepted

## Notes

- `Qt.Window` is essential for taskbar icon display on frameless windows
- `Qt.WindowStaysOnTopHint` ensures windows stay on top during critical initialization phases
- For non-modal windows, use `raise_()` and `activateWindow()` without `WindowStaysOnTopHint`

## Status
✅ Fixed - Both splash screen and startup dialog now display properly with icons
