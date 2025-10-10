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
    
    needs_setup = not (python_ready and config_exists)
    
    return {
        'first_run': needs_setup,
        'python_ready': python_ready,
        'spinach_ready': spinach_ready,
        'config_exists': config_exists,
    }


def show_first_run_dialog():
    """
    Show first-run setup dialog with options.
    
    Returns:
        str: 'full' = setup Python+MATLAB+Spinach
             'python_only' = setup Python only (skip MATLAB)
             'skip' = skip all setup (use system Python)
    """
    
    try:
        from PySide6.QtWidgets import QApplication, QMessageBox, QPushButton
        from PySide6.QtCore import Qt
        
        app = QApplication.instance() or QApplication(sys.argv)
        
        msg = QMessageBox()
        msg.setWindowTitle("Welcome to ZULF-NMR Suite")
        msg.setIcon(QMessageBox.Information)
        
        msg.setText("<h3>Welcome to ZULF-NMR Suite v0.1.0!</h3>")
        msg.setInformativeText(
            "<p>This appears to be your first time running the application.</p>"
            "<p><b>Setup Options:</b></p>"
            "<ul>"
            "<li><b>Full Setup:</b> Configure Python + MATLAB + Spinach (recommended if you have MATLAB)</li>"
            "<li><b>Python Only:</b> Configure Python environment only (Pure Python mode - no MATLAB required)</li>"
            "<li><b>Skip Setup:</b> Use system Python (advanced users)</li>"
            "</ul>"
            "<p><i>💡 Tip: Python-only mode works great without any MATLAB installation!</i></p>"
        )
        
        # Custom buttons
        full_btn = msg.addButton("Full Setup (Python+MATLAB+Spinach)", QMessageBox.AcceptRole)
        python_only_btn = msg.addButton("Python Only (Skip MATLAB)", QMessageBox.ActionRole)
        skip_btn = msg.addButton("Skip All (Use System)", QMessageBox.RejectRole)
        
        msg.setDefaultButton(python_only_btn)  # Default to Python-only for easier setup
        msg.exec()
        
        clicked = msg.clickedButton()
        if clicked == full_btn:
            return 'full'
        elif clicked == python_only_btn:
            return 'python_only'
        else:
            return 'skip'
            
    except ImportError:
        # PySide6 not available, skip GUI
        print("=" * 60)
        print("Welcome to ZULF-NMR Suite v0.1.0!")
        print("=" * 60)
        print()
        print("This is your first run. For best experience:")
        print("  1. Run: environments\\python\\setup_embedded_python.ps1")
        print("  2. Run: environments\\spinach\\setup_spinach.ps1")
        print()
        print("Or run with Python-only mode (no MATLAB): just setup Python")
        return 'skip'


def apply_user_config(startup_config):
    """
    Apply user configuration from startup dialog.
    
    Args:
        startup_config: Dictionary from StartupDialog.get_config()
    """
    import subprocess
    
    workspace_root = Path(__file__).parent.parent.parent
    
    # Configure embedded Spinach if requested
    if startup_config.get('configure_embedded_spinach'):
        spinach_script = workspace_root / "environments" / "spinach" / "setup_spinach.ps1"
        if spinach_script.exists():
            print("Configuring embedded Spinach...")
            subprocess.run(
                ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(spinach_script)],
                check=False
            )
    
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
                    print("✓ MATLAB Engine installed successfully!")
                else:
                    print(f"✗ MATLAB Engine installation failed:")
                    print(result.stderr)
            else:
                if not matlab_setup.exists():
                    print(f"✗ MATLAB setup.py not found at: {matlab_setup}")
                if not embedded_python.exists():
                    print(f"✗ Embedded Python not found at: {embedded_python}")


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
