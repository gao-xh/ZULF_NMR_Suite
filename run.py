"""
Main Launcher for Multi-System ZULF-NMR Simulator

This script configures the environment and launches the application
with a splash screen and initialization sequence.
"""

import sys
import os
import subprocess
from pathlib import Path
from PySide6.QtWidgets import QApplication, QMessageBox, QDialog

# Windows-specific: Set App User Model ID for taskbar icon
# This must be done BEFORE creating QApplication and importing Qt
# Works on both 32-bit and 64-bit Windows
if sys.platform.startswith('win'):
    try:
        import ctypes
        # Import config to get APP_USER_MODEL_ID
        # We need to do a minimal import before full Qt initialization
        config_file = Path(__file__).parent / 'config.txt'
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
    except Exception as e:
        print(f"Warning: Could not set App User Model ID: {e}")
        print("Taskbar icon may show default Python icon")

# CRITICAL: Clear Qt plugin paths BEFORE any Qt imports
# This prevents conflicts between conda's PyQt5 and our PySide6
os.environ.pop('QT_PLUGIN_PATH', None)
os.environ.pop('QT_QPA_PLATFORM_PLUGIN_PATH', None)
os.environ.pop('QML_IMPORT_PATH', None)
os.environ.pop('QML2_IMPORT_PATH', None)

# Disable hardware video acceleration to prevent buffer pool issues
# Force software decoding for video playback
os.environ['QT_OPENGL'] = 'software'
os.environ['QT_D3D11_ADAPTER'] = '-1'
os.environ['QT_ANGLE_PLATFORM'] = 'software'
os.environ['LIBVA_DRIVER_NAME'] = 'i965'

# Force PySide6 to use its own Qt libraries
# Get PySide6 installation path and set Qt plugin path explicitly
try:
    import PySide6
    pyside6_path = Path(PySide6.__file__).parent
    plugins_path = pyside6_path / "Qt" / "plugins"
    if plugins_path.exists():
        os.environ['QT_PLUGIN_PATH'] = str(plugins_path)
except Exception as e:
    pass  # If we can't set it, let PySide6 use defaults

from PySide6.QtWidgets import QApplication, QMessageBox, QDialog

# CRITICAL: Add project root to Python path BEFORE importing any src modules
# This is especially important for embedded Python which has different sys.path[0]
PROJECT_ROOT = Path(__file__).parent.absolute()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

# Import configuration
from src.utils.config import config

# Import icon manager
from src.utils.icon_manager import icon_manager


# Environment Configuration (loaded from config.txt)
PYTHON_ENV_PATH = config.get('PYTHON_ENV_PATH')


def check_environment():
    """Check Python environment and display information"""
    current_python = sys.executable
    print(f"Python interpreter: {current_python}")
    
    # Check if running expected environment
    if PYTHON_ENV_PATH is not None:
        expected_path = Path(PYTHON_ENV_PATH)
        
        # If expected path is relative, resolve it relative to project root
        if not expected_path.is_absolute():
            expected_path = (PROJECT_ROOT / expected_path).resolve()
        else:
            expected_path = expected_path.resolve()
        
        actual_path = Path(current_python).resolve()
        
        if expected_path != actual_path:
            print(f"\nInfo: Different Python environment detected")
            print(f"Expected: {expected_path}")
            print(f"Actual:   {actual_path}")
            
            # Check if the expected Python exists and offer to restart
            if expected_path.exists():
                print(f"\nNote: For best compatibility, use the configured environment:")
                print(f"  {expected_path} run.py")
                print(f"\nContinuing with current environment...")
            else:
                print(f"\nWarning: Configured Python not found at {expected_path}")
                print(f"Continuing with current environment...")
        else:
            print(f"Environment: OK (using configured Python)")
    else:
        print(f"Environment: Using current Python (no specific environment configured)")
    
    # Show conda environment if applicable
    conda_env = os.environ.get('CONDA_DEFAULT_ENV', '')
    if conda_env:
        print(f"Conda environment: {conda_env}")
    
    print(f"Python version: {sys.version.split()[0]}")
    
    return True


def setup_python_path():
    """Add project root to Python path"""
    if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))
    print(f"Project root: {PROJECT_ROOT}")


def verify_dependencies():
    """Verify critical dependencies are installed"""
    required_version = config.get('PYSIDE6_VERSION', '6.7.3')
    
    try:
        import PySide6
        print(f"PySide6: {PySide6.__version__} - OK")
        if PySide6.__version__ != required_version:
            print(f"  Note: Expected version {required_version}")
    except ImportError:
        print("Error: PySide6 not installed")
        print(f"Install with: pip install PySide6=={required_version}")
        sys.exit(1)
    
    if config.get('NUMPY_REQUIRED', True):
        try:
            import numpy
            print(f"NumPy: {numpy.__version__} - OK")
        except ImportError:
            print("Error: NumPy not installed")
            print("Install with: pip install numpy")
            sys.exit(1)
    
    if config.get('MATPLOTLIB_REQUIRED', True):
        try:
            import matplotlib
            print(f"Matplotlib: {matplotlib.__version__} - OK")
        except ImportError:
            print("Error: Matplotlib not installed")
            print("Install with: pip install matplotlib")
            sys.exit(1)
    
    print("All dependencies verified\n")


def main():
    """Main entry point with environment setup and splash screen"""
    
    print("=" * 60)
    print(config.app_name)
    print(config.app_full_version)
    print("=" * 60)
    print()
    
    # Check for first run
    from src.utils.first_run_setup import check_first_run, show_first_run_dialog
    
    setup_status = check_first_run()
    if setup_status['first_run']:
        # First run only triggered if embedded Python is missing
        print("\n" + "=" * 60)
        print("WARNING: Embedded Python Not Found")
        print("=" * 60)
        print(f"Python environment: {'Ready' if setup_status['python_ready'] else 'MISSING'}")
        print(f"Spinach/MATLAB:     {'Ready' if setup_status['spinach_ready'] else 'Not configured'}")
        print()
        
        # Show setup dialog
        setup_choice = show_first_run_dialog()
        
        if setup_choice == 'setup':
            print("\nPlease run the Python setup script:")
            print("  .\\environments\\python\\setup_embedded_python.ps1")
            print("\nThen restart the application.")
            sys.exit(0)
        else:  # skip
            print("WARNING: Continuing with system Python (not recommended)...")
            print("For best experience, please set up embedded Python.")


    
    # Environment setup
    print("Checking environment...")
    check_environment()
    setup_python_path()
    verify_dependencies()
    
    print("Starting application...\n")
    
    # Create Qt Application
    app = QApplication(sys.argv)
    
    # Set application-wide icon
    app_icon = icon_manager.get_app_icon()
    if not app_icon.isNull():
        app.setWindowIcon(app_icon)
    
    # Show splash screen
    from src.ui.splash_screen import SplashScreen
    splash = SplashScreen()
    splash.show()
    
    # Process events to show splash immediately
    app.processEvents()
    
    # Start initialization
    splash.start_initialization()
    
    # Variable to hold main window
    main_window = None
    startup_config = None
    
    def on_splash_closed():
        """Called when splash screen closes"""
        nonlocal main_window, startup_config
        
        print("\n[DEBUG] on_splash_closed() called")
        print(f"[DEBUG] init_success: {splash.init_success}")
        
        if splash.init_success:
            # Get initialization results from splash screen worker
            init_results = splash.worker.get_init_results() if splash.worker else {}
            
            print(f"[DEBUG] init_results: {init_results}")
            
            # Check MATLAB status from splash screen initialization
            matlab_available = init_results.get('matlab_available', False)
            
            if matlab_available:
                print("[INFO] MATLAB engine started successfully during initialization")
            else:
                print("[INFO] MATLAB engine not available - will offer Pure Python mode")
            
            # Auto-detect MATLAB installation path for display purposes
            from src.utils.first_run_setup import auto_detect_matlab
            detected_matlab = auto_detect_matlab()
            
            if detected_matlab:
                print(f"[INFO] Detected MATLAB at: {detected_matlab}")
                init_results['detected_matlab_path'] = str(detected_matlab)
                
                # Try to get version
                version_info_file = detected_matlab / "VersionInfo.xml"
                if version_info_file.exists():
                    try:
                        import xml.etree.ElementTree as ET
                        tree = ET.parse(version_info_file)
                        root = tree.getroot()
                        release = root.find('.//release')
                        if release is not None and release.text:
                            init_results['detected_matlab_version'] = release.text.strip()
                            print(f"[INFO] MATLAB Version: {init_results['detected_matlab_version']}")
                    except Exception:
                        pass
            
            # ALWAYS show startup configuration dialog
            # Let user choose: MATLAB vs Pure Python, Local vs Cloud
            from src.ui.startup_dialog import StartupDialog
            
            print(f"[DEBUG] Creating StartupDialog with init_results...")
            startup_dialog = StartupDialog(init_results)
            print(f"[DEBUG] StartupDialog created, showing...")
            startup_dialog.show()
            startup_dialog.raise_()
            startup_dialog.activateWindow()
            
            print(f"[DEBUG] Executing dialog...")
            result = startup_dialog.exec()
            print(f"[DEBUG] Dialog result: {result}")
            
            if result == QDialog.Accepted:
                # User accepted, get configuration
                startup_config = startup_dialog.get_config()
                
                print(f"[DEBUG] User selected config: {startup_config}")

                # Check if user chose MATLAB mode
                use_matlab = startup_config.get('use_matlab', False)
                
                if use_matlab and not matlab_available:
                    # User wants MATLAB but it wasn't started successfully
                    # Need to apply configuration (install MATLAB Engine, etc.)
                    print("[INFO] User chose MATLAB but engine not ready - applying configuration...")
                    from src.utils.first_run_setup import apply_user_config
                    config_results = apply_user_config(startup_config)
                    
                    # Check if restart is needed
                    if config_results.get('needs_restart', False):
                        from PySide6.QtWidgets import QMessageBox
                        
                        msg = QMessageBox()
                        msg.setIcon(QMessageBox.Information)
                        msg.setWindowTitle("Configuration Complete - Restart Required")
                        msg.setText("<h3>MATLAB Engine Configured Successfully!</h3>")
                        msg.setInformativeText(
                            "<p>MATLAB Engine has been installed to the embedded Python environment.</p>"
                            "<p><b>Please restart the application</b> to use MATLAB Spinach engine.</p>"
                            "<p>Configuration saved to: <code>user_config.json</code></p>"
                        )
                        msg.setStandardButtons(QMessageBox.Ok)
                        msg.setDefaultButton(QMessageBox.Ok)
                        msg.exec()
                        
                        # Exit the application
                        print("\n" + "="*60)
                        print("CONFIGURATION COMPLETE - PLEASE RESTART APPLICATION")
                        print("="*60)
                        print("\nRun start.bat again to start with MATLAB Spinach engine.")
                        sys.exit(0)
                
                elif use_matlab and matlab_available:
                    # User chose MATLAB and engine is already started
                    # Just use the existing engine from splash screen
                    print("[INFO] Using MATLAB engine from initialization")
                    # Engine is already stored in global ENGINE manager by splash screen
                    
                else:
                    # User chose Pure Python mode
                    print("[INFO] User chose Pure Python mode")
                    # If MATLAB engine was started, we should clean it up
                    if matlab_available and splash.worker and hasattr(splash.worker, 'engine_cm'):
                        try:
                            print("[INFO] Cleaning up MATLAB engine...")
                            splash.worker.engine_cm.__exit__(None, None, None)
                        except:
                            pass
                
                # Save user's choice to config
                from src.utils.user_config import get_user_config
                user_config = get_user_config()
                user_config.data['preferences'] = {
                    'use_matlab': use_matlab,
                    'execution_mode': startup_config.get('execution_mode', 'local')
                }
                user_config.data['first_run_completed'] = True
                user_config.save()
                print(f"[INFO] Configuration saved: use_matlab={use_matlab}")

                # Start main application (tab-based container)
                from main_application import MainApplication
                main_window = MainApplication(startup_config=startup_config)

                main_window.show()
                # Bring window to front and activate it
                main_window.raise_()
                main_window.activateWindow()
            else:
                # User cancelled, exit application
                print("User cancelled startup configuration")
                app.quit()
        else:
            # Show error and exit
            QMessageBox.critical(
                None,
                "Initialization Failed",
                "Failed to initialize application.\n"
                "Please check the error messages in the console."
            )
            app.quit()
    
    # Connect splash closed signal
    splash.closed.connect(on_splash_closed)
    print("[DEBUG] Connected splash.closed signal to on_splash_closed()")
    
    # Run application
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
