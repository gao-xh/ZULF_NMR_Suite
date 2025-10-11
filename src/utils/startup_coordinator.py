"""
Startup Coordination Module

This module coordinates the application startup flow after splash screen,
including MATLAB detection, dialog presentation, and main application launch.
"""

import sys
from pathlib import Path
from PySide6.QtWidgets import QMessageBox, QDialog


def detect_matlab_info(init_results):
    """
    Auto-detect MATLAB installation and add info to init_results.
    
    Args:
        init_results (dict): Initialization results from splash screen
        
    Returns:
        dict: Updated init_results with MATLAB detection info
    """
    from src.utils.first_run_setup import auto_detect_matlab
    
    detected_matlab = auto_detect_matlab()
    
    if detected_matlab:
        print(f"[INFO] Detected MATLAB at: {detected_matlab}")
        init_results['detected_matlab_path'] = str(detected_matlab)
        
        # Try to get version from VersionInfo.xml
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
    
    return init_results


def create_startup_dialog(init_results, matlab_has_issues=False):
    """
    Create and configure the startup dialog.
    
    Uses different dialogs based on MATLAB status:
    - StartupSelectionDialog: When MATLAB is working (simple mode selection)
    - MatlabConfigDialog: When MATLAB needs configuration
    
    Args:
        init_results (dict): Initialization results
        matlab_has_issues (bool): Whether MATLAB has problems
        
    Returns:
        QDialog: Configured dialog instance
    """
    matlab_available = init_results.get('matlab_available', False)
    
    if matlab_has_issues or not matlab_available:
        # MATLAB needs configuration - show config dialog
        from src.ui.matlab_config_dialog import MatlabConfigDialog
        
        detected_path = init_results.get('detected_matlab_path')
        matlab_version = init_results.get('detected_matlab_version')
        
        dialog = MatlabConfigDialog(
            detected_matlab_path=detected_path,
            matlab_version=matlab_version
        )
        print("[INFO] MATLAB has issues - showing configuration dialog")
        return dialog
    else:
        # MATLAB working - show simple selection dialog
        from src.ui.startup_selection_dialog import StartupSelectionDialog
        
        dialog = StartupSelectionDialog(matlab_available=matlab_available)
        print("[INFO] Showing startup selection dialog")
        return dialog


def handle_matlab_configuration(startup_config, matlab_available):
    """
    Handle MATLAB configuration if user selected MATLAB mode but it's not ready.
    
    Args:
        startup_config (dict): User's configuration choices
        matlab_available (bool): Whether MATLAB engine is available
        
    Returns:
        bool: True if restart is needed, False otherwise
    """
    use_matlab = startup_config.get('use_matlab', False)
    
    if not use_matlab:
        return False
    
    if matlab_available:
        # MATLAB already available, no configuration needed
        print("[INFO] Using MATLAB engine from initialization")
        return False
    
    # User wants MATLAB but it's not ready
    # If user explicitly requested configuration, do it now
    # Otherwise, show message that MATLAB will be configured on restart
    configure_matlab = startup_config.get('configure_matlab_engine', False)
    
    if configure_matlab:
        # User explicitly clicked "Configure MATLAB" - do configuration now
        print("[INFO] User chose MATLAB but engine not ready - applying configuration...")
        from src.utils.first_run_setup import apply_user_config
        
        config_results = apply_user_config(startup_config)
        
        # Check if restart is needed (e.g., MATLAB Engine was just installed)
        if config_results.get('needs_restart', False):
            show_restart_message()
            return True
    else:
        # User selected MATLAB but didn't configure - inform them to configure later
        print("[WARN] User selected MATLAB but engine not available and not configured")
        print("[WARN] Application will start in Pure Python mode")
        # Don't force configuration - let them use Pure Python for now
    
    return False


def show_restart_message():
    """
    Show restart required message after MATLAB Engine installation.
    """
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
    
    print("\n" + "="*60)
    print("CONFIGURATION COMPLETE - PLEASE RESTART APPLICATION")
    print("="*60)
    print("\nRun start.bat again to start with MATLAB Spinach engine.")


def cleanup_matlab_engine(splash_worker):
    """
    Clean up MATLAB engine if it was started but user chose Pure Python.
    
    Args:
        splash_worker: The InitializationWorker instance from splash screen
    """
    if not splash_worker or not hasattr(splash_worker, 'engine_cm'):
        return
    
    try:
        print("[INFO] Cleaning up MATLAB engine...")
        splash_worker.engine_cm.__exit__(None, None, None)
        print("[INFO] MATLAB engine cleaned up successfully")
    except Exception as e:
        print(f"[WARN] Failed to cleanup MATLAB engine: {e}")


def save_user_configuration(startup_config):
    """
    Save user's configuration choices to user_config.json.
    
    Args:
        startup_config (dict): User's configuration choices
    """
    from src.utils.user_config import get_user_config
    
    use_matlab = startup_config.get('use_matlab', False)
    execution_mode = startup_config.get('execution_mode', 'local')
    
    user_config = get_user_config()
    user_config.set_preferences(
        use_matlab=use_matlab,
        execution_mode=execution_mode
    )
    user_config.mark_first_run_complete()
    
    print(f"[INFO] Configuration saved: use_matlab={use_matlab}, execution_mode={execution_mode}")


def start_main_application(startup_config):
    """
    Start the main application window.
    
    Args:
        startup_config (dict): Startup configuration
        
    Returns:
        MainApplication: Main application window instance
    """
    from main_application import MainApplication
    
    print("[INFO] Starting main application...")
    main_window = MainApplication(startup_config=startup_config)
    main_window.show()
    main_window.raise_()
    main_window.activateWindow()
    
    print("[INFO] Main application started successfully")
    return main_window


def handle_splash_completion(splash, app):
    """
    Main coordination function called when splash screen closes.
    
    This is the entry point that coordinates all startup logic:
    1. Get initialization results
    2. Detect MATLAB installation
    3. Show appropriate dialog (configuration vs selection)
    4. Handle user's choices
    5. Start main application or exit
    
    Args:
        splash: SplashScreen instance
        app: QApplication instance
        
    Returns:
        MainApplication or None: Main window if started, None if exited
    """
    print("\n[DEBUG] handle_splash_completion() called")
    print(f"[DEBUG] init_success: {splash.init_success}")
    
    if not splash.init_success:
        # Initialization failed - show error and exit
        QMessageBox.critical(
            None,
            "Initialization Failed",
            "Failed to initialize application.\n"
            "Please check the error messages in the console."
        )
        app.quit()
        return None
    
    # Get initialization results from splash screen worker
    init_results = splash.worker.get_init_results() if splash.worker else {}
    print(f"[DEBUG] init_results: {init_results}")
    
    # Check MATLAB status
    matlab_available = init_results.get('matlab_available', False)
    matlab_has_issues = init_results.get('matlab_has_issues', False)
    
    if matlab_available:
        print("[INFO] MATLAB engine started successfully during initialization")
    else:
        print("[INFO] MATLAB engine not available")
        if matlab_has_issues:
            matlab_error = init_results.get('matlab_error', 'Unknown error')
            print(f"[WARN] MATLAB issues detected: {matlab_error}")
    
    # Auto-detect MATLAB installation path for display
    init_results = detect_matlab_info(init_results)
    
    # Create and show startup dialog
    startup_dialog = create_startup_dialog(init_results, matlab_has_issues)
    
    print(f"[DEBUG] StartupDialog created (type: {type(startup_dialog).__name__})")
    print(f"[DEBUG] Dialog ID: {id(startup_dialog)}")
    
    # Only use exec() for modal dialogs, not show()
    print(f"[DEBUG] Executing dialog (modal)...")
    result = startup_dialog.exec()
    print(f"[DEBUG] Dialog result: {result}")
    
    if result != QDialog.Accepted:
        # User cancelled - exit application
        print("[INFO] User cancelled startup configuration")
        app.quit()
        return None
    
    # User accepted - get configuration
    startup_config = startup_dialog.get_config()
    print(f"[DEBUG] User selected config: {startup_config}")
    
    # Handle MATLAB configuration if needed
    needs_restart = handle_matlab_configuration(startup_config, matlab_available)
    
    if needs_restart:
        # Exit for restart
        sys.exit(0)
        return None
    
    # Handle Pure Python mode - cleanup MATLAB engine if needed
    use_matlab = startup_config.get('use_matlab', False)
    if not use_matlab and matlab_available:
        cleanup_matlab_engine(splash.worker)
    
    # Save user's configuration
    save_user_configuration(startup_config)
    
    # Start main application
    main_window = start_main_application(startup_config)
    
    return main_window
