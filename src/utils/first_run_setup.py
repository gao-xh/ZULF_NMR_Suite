"""
First-Run Setup Check

Detects if this is the first time running and offers to configure:
- Embedded Python
- Spinach + MATLAB
"""

import sys
from pathlib import Path


def check_first_run():
    """Check if this is the first run and needs setup."""
    
    # Get workspace root (src/utils -> root)
    workspace_root = Path(__file__).parent.parent.parent
    
    # Check markers
    python_ready = (workspace_root / "environments" / "python" / "python.exe").exists()
    spinach_ready = (workspace_root / "environments" / "spinach" / "kernel").exists()
    config_exists = (workspace_root / ".setup_complete").exists()
    
    # First run only if embedded Python is missing
    # (If Python exists but no config, just show startup dialog)
    needs_setup = not python_ready
    
    return {
        'first_run': needs_setup,
        'python_ready': python_ready,
        'spinach_ready': spinach_ready,
        'config_exists': config_exists,
    }


def show_first_run_dialog():
    """
    Show first-run setup dialog.
    
    Returns:
        str: 'setup' = run Python setup script (should not happen if Python exists)
             'skip' = skip setup (continue with current state)
    """
    
    try:
        from PySide6.QtWidgets import QApplication, QMessageBox, QPushButton
        from PySide6.QtCore import Qt
        
        app = QApplication.instance() or QApplication(sys.argv)
        
        msg = QMessageBox()
        msg.setWindowTitle("Setup Required")
        msg.setIcon(QMessageBox.Warning)
        
        msg.setText("<h3>Embedded Python Not Found</h3>")
        msg.setInformativeText(
            "<p>The embedded Python environment is missing.</p>"
            "<p>Please run the setup script to install it:</p>"
            "<p><code>environments\\python\\setup_embedded_python.ps1</code></p>"
            "<p><b>Or</b> continue with system Python (not recommended).</p>"
        )
        
        # Custom buttons
        setup_btn = msg.addButton("Exit to Run Setup", QMessageBox.AcceptRole)
        skip_btn = msg.addButton("Continue with System Python", QMessageBox.RejectRole)
        
        msg.setDefaultButton(setup_btn)
        msg.exec()
        
        clicked = msg.clickedButton()
        if clicked == setup_btn:
            return 'setup'
        else:
            return 'skip'
            
    except ImportError:
        # PySide6 not available, skip GUI
        print("=" * 60)
        print("WARNING: Embedded Python Not Found!")
        print("=" * 60)
        print()
        print("Please run: environments\\python\\setup_embedded_python.ps1")
        print("Or continue with system Python (not recommended)")
        print()
        return 'skip'


def apply_user_config(startup_config):
    """
    Apply user configuration from startup dialog.
    
    Args:
        startup_config: Dictionary from StartupDialog.get_config()
    """
    import subprocess
    from .user_config import get_user_config
    
    workspace_root = Path(__file__).parent.parent.parent
    user_config = get_user_config()
    
    # Mark first run as complete
    if user_config.is_first_run():
        user_config.mark_first_run_complete()
        print("First run setup completed")
    
    # Save user preferences
    user_config.set_preferences(
        use_matlab=startup_config.get('use_matlab', False) and not startup_config.get('skip_matlab', False),
        execution_mode=startup_config.get('execution', 'local')
    )
    
    # Configure embedded Spinach if requested
    if startup_config.get('configure_embedded_spinach'):
        spinach_script = workspace_root / "environments" / "spinach" / "setup_spinach.ps1"
        if spinach_script.exists():
            print("Configuring embedded Spinach...")
            subprocess.run(
                ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(spinach_script)],
                check=False
            )
            # Mark Spinach as configured
            spinach_path = workspace_root / "environments" / "spinach"
            if (spinach_path / "kernel").exists():
                user_config.set_spinach_config(spinach_path=spinach_path)
                print("[OK] Spinach configured successfully")
    
    # Configure MATLAB Engine if requested and a path provided
    if startup_config.get('configure_matlab_engine'):
        matlab_path = startup_config.get('matlab_path')
        if matlab_path:
            matlab_setup = Path(matlab_path) / "extern" / "engines" / "python" / "setup.py"
            embedded_python = workspace_root / "environments" / "python" / "python.exe"
            
            if matlab_setup.exists() and embedded_python.exists():
                # Install MATLAB Engine to embedded Python
                print(f"Installing MATLAB Engine from {matlab_path}...")
                print(f"Target: {embedded_python}")
                
                result = subprocess.run(
                    [str(embedded_python), str(matlab_setup), "install"],
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    print("[OK] MATLAB Engine installed successfully!")
                    
                    # Detect MATLAB version
                    matlab_version = None
                    parts = Path(matlab_path).parts
                    for part in parts:
                        if part.startswith('R20'):  # R2021a, R2025a, etc.
                            matlab_version = part
                            break
                    
                    # Save MATLAB configuration
                    user_config.set_matlab_config(
                        matlab_path=matlab_path,
                        version=matlab_version,
                        engine_installed=True
                    )
                    print(f"MATLAB configuration saved: {matlab_version} at {matlab_path}")
                else:
                    print(f"[!] MATLAB Engine installation failed:")
                    print(result.stderr)
            else:
                if not matlab_setup.exists():
                    print(f"[!] MATLAB setup.py not found at: {matlab_setup}")
                if not embedded_python.exists():
                    print(f"[!] Embedded Python not found at: {embedded_python}")
        else:
            print("[!] No MATLAB path provided, skipping MATLAB Engine installation")


def run_setup_wizard():
    """Run the setup wizard."""
    
    import subprocess
    from pathlib import Path
    
    workspace_root = Path(__file__).parent.parent.parent
    
    print("\n=== ZULF-NMR Suite Setup Wizard ===\n")
    
    # Step 1: Python
    print("[1] Setting up embedded Python...")
    python_script = workspace_root / "environments" / "python" / "setup_embedded_python.ps1"
    
    if python_script.exists():
        try:
            subprocess.run(
                ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(python_script)],
                check=False
            )
        except Exception as e:
            print(f"Warning: Python setup encountered an error: {e}")
    
    # Step 2: Spinach
    print("\n[2] Setting up Spinach + MATLAB...")
    spinach_script = workspace_root / "environments" / "spinach" / "setup_spinach.ps1"
    
    if spinach_script.exists():
        response = input("Do you have MATLAB installed? (y/n): ").lower()
        if response == 'y':
            try:
                subprocess.run(
                    ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(spinach_script)],
                    check=False
                )
            except Exception as e:
                print(f"Warning: Spinach setup encountered an error: {e}")
        else:
            print("Skipping MATLAB setup. You can use Pure Python backend.")
    
    # Mark setup complete
    (workspace_root / ".setup_complete").touch()
    
    print("\n[OK] Setup complete!")
    print("Restart the application to begin.\n")


if __name__ == "__main__":
    status = check_first_run()
    
    if status['first_run']:
        if show_first_run_dialog():
            run_setup_wizard()
        else:
            # User skipped, mark as complete anyway
            (Path(__file__).parent.parent.parent / ".setup_complete").touch()
