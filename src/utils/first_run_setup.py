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
    """Show first-run setup dialog."""
    
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
            "<p><b>Would you like to:</b></p>"
            "<ul>"
            "<li>Configure embedded Python environment?</li>"
            "<li>Link MATLAB and Spinach (optional)?</li>"
            "</ul>"
            "<p><i>You can also do this later from the settings.</i></p>"
        )
        
        # Custom buttons
        setup_btn = msg.addButton("Setup Now", QMessageBox.AcceptRole)
        skip_btn = msg.addButton("Skip (Use System Python)", QMessageBox.RejectRole)
        
        msg.setDefaultButton(setup_btn)
        msg.exec()
        
        if msg.clickedButton() == setup_btn:
            return True
        else:
            return False
            
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
        return False


def run_setup_wizard():
    """Run the setup wizard."""
    
    import subprocess
    from pathlib import Path
    
    workspace_root = Path(__file__).parent
    
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
