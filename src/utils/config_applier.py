"""
Configuration Applier Module

Handles application of user configuration choices from startup dialog.
"""

from pathlib import Path
from .matlab_detector import get_matlab_version
from .matlab_installer import install_matlab_engine


def apply_user_config(startup_config):
    """
    Apply user configuration from startup dialog.
    
    This function:
    1. Marks first run as complete
    2. Saves user preferences
    3. Configures Spinach if requested
    4. Installs MATLAB Engine if requested
    
    Args:
        startup_config (dict): Configuration from StartupDialog.get_config()
            Expected keys:
            - use_matlab: bool
            - skip_matlab: bool
            - execution: str ('local' or 'cloud')
            - configure_embedded_spinach: bool
            - configure_matlab_engine: bool
            - matlab_path: str or None
        
    Returns:
        dict: Configuration results {
            'needs_restart': bool,  # True if restart required
            'matlab_engine_installed': bool  # True if MATLAB Engine was installed
        }
    """
    from .user_config import get_user_config
    
    workspace_root = Path(__file__).parent.parent.parent
    user_config = get_user_config()
    
    results = {
        'needs_restart': False,
        'matlab_engine_installed': False
    }
    
    # Mark first run as complete
    if user_config.is_first_run():
        user_config.mark_first_run_complete()
        print("First run setup completed")
    
    # Save user preferences
    use_matlab = startup_config.get('use_matlab', False) and not startup_config.get('skip_matlab', False)
    execution_mode = startup_config.get('execution', 'local')
    
    user_config.set_preferences(
        use_matlab=use_matlab,
        execution_mode=execution_mode
    )
    
    print(f"User preferences saved: use_matlab={use_matlab}, execution_mode={execution_mode}")
    
    # Configure embedded Spinach if requested
    if startup_config.get('configure_embedded_spinach'):
        configure_embedded_spinach(workspace_root, user_config)
    
    # Configure MATLAB Engine if requested
    if startup_config.get('configure_matlab_engine'):
        matlab_result = configure_matlab_engine(
            startup_config.get('matlab_path'),
            workspace_root,
            user_config
        )
        results.update(matlab_result)
    
    return results


def configure_embedded_spinach(workspace_root, user_config):
    """
    Configure embedded Spinach package.
    
    Args:
        workspace_root (Path): Project root directory
        user_config: User configuration manager
    """
    import subprocess
    
    spinach_script = workspace_root / "environments" / "spinach" / "setup_spinach.ps1"
    
    if not spinach_script.exists():
        print(f"[WARN] Spinach setup script not found: {spinach_script}")
        return
    
    print("Configuring embedded Spinach...")
    
    try:
        subprocess.run(
            ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(spinach_script)],
            check=False
        )
        
        # Mark Spinach as configured if kernel directory exists
        spinach_path = workspace_root / "environments" / "spinach"
        if (spinach_path / "kernel").exists():
            user_config.set_spinach_config(spinach_path=spinach_path)
            print("[OK] Spinach configured successfully")
        else:
            print("[WARN] Spinach kernel directory not found after setup")
    except Exception as e:
        print(f"[ERROR] Failed to configure Spinach: {e}")


def configure_matlab_engine(matlab_path, workspace_root, user_config):
    """
    Configure MATLAB Engine installation.
    
    Args:
        matlab_path (str or None): Path to MATLAB installation
        workspace_root (Path): Project root directory
        user_config: User configuration manager
        
    Returns:
        dict: Configuration result {
            'needs_restart': bool,
            'matlab_engine_installed': bool
        }
    """
    result = {
        'needs_restart': False,
        'matlab_engine_installed': False
    }
    
    if not matlab_path:
        print("[INFO] No MATLAB path provided, skipping MATLAB Engine installation")
        return result
    
    matlab_path = Path(matlab_path)
    embedded_python = workspace_root / "environments" / "python" / "python.exe"
    
    print("\n" + "="*60)
    print("CONFIGURING MATLAB ENGINE")
    print("="*60)
    print(f"MATLAB Path: {matlab_path}")
    print(f"Target Python: {embedded_python}")
    
    # Verify paths exist
    if not matlab_path.exists():
        print(f"[ERROR] MATLAB directory not found: {matlab_path}")
        return result
    
    if not embedded_python.exists():
        print(f"[ERROR] Embedded Python not found: {embedded_python}")
        return result
    
    # Install MATLAB Engine
    install_result = install_matlab_engine(matlab_path, embedded_python)
    
    if install_result['success']:
        print("\n" + "="*60)
        print("[SUCCESS] MATLAB Engine installed successfully!")
        print("="*60)
        
        result['matlab_engine_installed'] = True
        result['needs_restart'] = True
        
        # Detect and save MATLAB version
        matlab_version = get_matlab_version(matlab_path)
        if not matlab_version:
            matlab_version = "Unknown"
            print("[WARN] Could not detect MATLAB version, using 'Unknown'")
        else:
            print(f"Detected MATLAB version: {matlab_version}")
        
        # Save MATLAB configuration
        user_config.set_matlab_config(
            matlab_path=str(matlab_path),
            version=matlab_version,
            engine_installed=True
        )
        print(f"MATLAB configuration saved: {matlab_version} at {matlab_path}")
    else:
        print(f"\n[ERROR] MATLAB Engine installation failed:")
        if install_result['error']:
            print(f"  {install_result['error']}")
        if install_result['stderr']:
            print(f"  Details: {install_result['stderr']}")
    
    return result
