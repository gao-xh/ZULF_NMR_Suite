"""
Main Launcher for Multi-System ZULF-NMR Simulator

This script configures the environment and launches the application
with a splash screen and initialization sequence.
"""

import sys
import os
import subprocess
from pathlib import Path

# CRITICAL: Setup platform-specific environment BEFORE any imports
# This must be done before importing PySide6 to avoid Qt conflicts
PROJECT_ROOT = Path(__file__).parent.absolute()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

# Import platform setup utilities
from src.utils.platform_setup import setup_platform_specific

# Configure Windows App ID, Qt environment, hardware acceleration
setup_platform_specific()

# NOW safe to import Qt
from PySide6.QtWidgets import QApplication, QMessageBox, QDialog

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
    
    import os
    print(f"[DEBUG] Process ID: {os.getpid()}")
    
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
    splash_closed_handled = False  # Prevent duplicate handling
    
    def on_splash_closed():
        """Called when splash screen closes - delegate to startup coordinator"""
        nonlocal main_window, splash_closed_handled
        
        import traceback
        print(f"\n{'='*60}")
        print(f"[TRACE] on_splash_closed() ENTRY in run.py")
        print(f"[TRACE] splash_closed_handled={splash_closed_handled}")
        print(f"[TRACE] Stack trace:")
        for line in traceback.format_stack()[:-1]:
            print(line.strip())
        print(f"{'='*60}\n")
        
        # Prevent duplicate calls
        if splash_closed_handled:
            print("[CRITICAL] on_splash_closed() already handled, BLOCKING duplicate!")
            return
        splash_closed_handled = True
        print("[OK] First call to on_splash_closed(), proceeding...")
        
        from src.utils.startup_coordinator import handle_splash_completion
        main_window = handle_splash_completion(splash, app)
    
    # Connect splash closed signal
    splash.closed.connect(on_splash_closed)
    print("[DEBUG] Connected splash.closed signal to on_splash_closed()")
    
    # Run application
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
