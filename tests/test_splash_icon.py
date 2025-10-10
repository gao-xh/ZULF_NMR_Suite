"""
Test script to verify splash screen taskbar icon display
"""

import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt

# Set App User Model ID for Windows (before creating QApplication)
if sys.platform.startswith('win'):
    try:
        import ctypes
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(
            'AjoyLab.ZULFNMRSuite.Application.3.0'
        )
    except Exception as e:
        print(f"Could not set App ID: {e}")

app = QApplication(sys.argv)

# Set application icon
from src.utils.icon_manager import icon_manager
app_icon = icon_manager.get_app_icon()
if not app_icon.isNull():
    app.setWindowIcon(app_icon)
    print("Application icon set")
else:
    print("WARNING: Application icon is null!")

# Create and show splash screen
from src.ui.splash_screen import SplashScreen
splash = SplashScreen()

print(f"Window flags: {splash.windowFlags()}")
print(f"Window icon null: {splash.windowIcon().isNull()}")
print(f"Window title: {splash.windowTitle()}")

splash.setWindowTitle("ZULF-NMR Suite - Loading")  # Set title for taskbar
splash.show()
splash.raise_()
splash.activateWindow()

print("\nSplash screen should now be visible with icon in taskbar")
print("Check Windows taskbar for the application icon")
print("Press Ctrl+C to exit")

sys.exit(app.exec())
