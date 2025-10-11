"""
Platform-specific setup utilities

This module handles platform-specific configurations including:
- Windows App User Model ID for taskbar icon
- Qt environment variable cleanup
- Hardware acceleration settings
"""

import sys
import os
from pathlib import Path


def setup_windows_app_id():
    """
    Setup Windows taskbar App User Model ID.
    
    This must be called BEFORE creating QApplication to ensure
    the taskbar icon displays correctly on Windows.
    
    Returns:
        bool: True if setup was successful, False otherwise
    """
    if not sys.platform.startswith('win'):
        return False
    
    try:
        import ctypes
        
        # Import config to get APP_USER_MODEL_ID
        # We need to do a minimal import before full Qt initialization
        config_file = Path(__file__).parent.parent.parent / 'config.txt'
        app_id = 'AjoyLab.ZULFNMRSuite.Application.0.1'  # Default fallback
        
        if config_file.exists():
            with open(config_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('APP_USER_MODEL_ID'):
                        parts = line.split('=', 1)
                        if len(parts) == 2:
                            app_id = parts[1].strip()
                            break
        
        # Set App User Model ID for Windows taskbar
        # This works on both win32 and win64
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(app_id)
        print(f"Windows App ID set: {app_id}")
        return True
        
    except Exception as e:
        print(f"Warning: Could not set App User Model ID: {e}")
        print("Taskbar icon may show default Python icon")
        return False


def clear_qt_environment():
    """
    Clear Qt plugin paths to prevent conflicts.
    
    This prevents conflicts between conda's PyQt5 and our PySide6
    by removing potentially conflicting environment variables.
    
    CRITICAL: Must be called BEFORE any Qt imports!
    """
    # Clear Qt plugin paths
    os.environ.pop('QT_PLUGIN_PATH', None)
    os.environ.pop('QT_QPA_PLATFORM_PLUGIN_PATH', None)
    os.environ.pop('QML_IMPORT_PATH', None)
    os.environ.pop('QML2_IMPORT_PATH', None)


def disable_hardware_acceleration():
    """
    Disable hardware video acceleration for Qt.
    
    This prevents buffer pool issues and forces software decoding
    for video playback, which is more stable on some systems.
    """
    os.environ['QT_OPENGL'] = 'software'
    os.environ['QT_D3D11_ADAPTER'] = '-1'
    os.environ['QT_ANGLE_PLATFORM'] = 'software'
    os.environ['LIBVA_DRIVER_NAME'] = 'i965'


def force_pyside6_plugins():
    """
    Force PySide6 to use its own Qt libraries.
    
    Gets PySide6 installation path and sets Qt plugin path explicitly
    to ensure we use PySide6's bundled Qt instead of system Qt.
    """
    try:
        import PySide6
        pyside6_path = Path(PySide6.__file__).parent
        plugins_path = pyside6_path / "Qt" / "plugins"
        
        if plugins_path.exists():
            os.environ['QT_PLUGIN_PATH'] = str(plugins_path)
            return True
        
    except Exception:
        pass  # If we can't set it, let PySide6 use defaults
    
    return False


def setup_platform_specific():
    """
    Setup all platform-specific configurations.
    
    This is the main entry point for platform setup.
    Call this BEFORE creating QApplication.
    
    Returns:
        dict: Status of each setup step
    """
    status = {}
    
    # Windows-specific: Set App User Model ID for taskbar icon
    status['windows_app_id'] = setup_windows_app_id()
    
    # Clear Qt environment variables to avoid conflicts
    clear_qt_environment()
    status['qt_environment_cleared'] = True
    
    # Disable hardware video acceleration
    disable_hardware_acceleration()
    status['hardware_acceleration_disabled'] = True
    
    # Force PySide6 to use its own Qt libraries
    status['pyside6_plugins_forced'] = force_pyside6_plugins()
    
    return status
