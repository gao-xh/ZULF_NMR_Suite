"""
First-Run Setup Check

Detects if this is the first time running and offers to configure:
- Embedded Python
- Spinach + MATLAB
"""

import sys
import subprocess
from pathlib import Path


def auto_detect_matlab():
    """
    Automatically detect MATLAB installation on Windows.
    
    Returns:
        Path or None: Path to MATLAB installation directory if found
    """
    import os
    
    # Common MATLAB installation paths
    common_paths = [
        r"C:\Program Files\MATLAB",
        r"C:\Program Files (x86)\MATLAB",
        r"D:\MATLAB",
        r"E:\MATLAB",
        r"F:\MATLAB",
        r"C:\MATLAB"
    ]
    
    matlab_installations = []
    
    # Method 1: Check common installation directories
    for base_path in common_paths:
        base = Path(base_path)
        if base.exists():
            # Check if it's a direct MATLAB installation (has bin/matlab.exe)
            if (base / "bin" / "matlab.exe").exists():
                matlab_installations.append(base)
            else:
                # Check subdirectories for version folders (R2024a, R2023b, etc.)
                try:
                    for subdir in base.iterdir():
                        if subdir.is_dir() and (subdir / "bin" / "matlab.exe").exists():
                            matlab_installations.append(subdir)
                except PermissionError:
                    continue
    
    # Method 2: Check Windows registry
    try:
        import winreg
        reg_key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\MathWorks\MATLAB", 0, winreg.KEY_READ)
        try:
            i = 0
            while True:
                try:
                    version_key_name = winreg.EnumKey(reg_key, i)
                    version_key = winreg.OpenKey(reg_key, version_key_name)
                    matlab_root, _ = winreg.QueryValueEx(version_key, "MATLABROOT")
                    winreg.CloseKey(version_key)
                    
                    matlab_path = Path(matlab_root)
                    if matlab_path.exists() and matlab_path not in matlab_installations:
                        matlab_installations.append(matlab_path)
                    i += 1
                except OSError:
                    break
        finally:
            winreg.CloseKey(reg_key)
    except (ImportError, FileNotFoundError, OSError):
        pass
    
    # Return the newest version (last in sorted list)
    if matlab_installations:
        # Sort by directory name (R2024a > R2023b > R2021a)
        matlab_installations.sort(key=lambda p: p.name, reverse=True)
        return matlab_installations[0]
    
    return None


def auto_configure_first_run():
    """
    Automatically configure everything on first run.
    
    Returns:
        dict: Configuration results {
            'python_ready': bool,
            'spinach_ready': bool,
            'matlab_detected': bool,
            'matlab_path': Path or None,
            'matlab_engine_installed': bool,
            'matlab_version': str or None
        }
    """
    workspace_root = Path(__file__).parent.parent.parent
    
    print("\n" + "="*70)
    print("ZULF-NMR Suite - First Run Auto-Configuration")
    print("="*70)
    
    results = {
        'python_ready': False,
        'spinach_ready': False,
        'matlab_detected': False,
        'matlab_path': None,
        'matlab_engine_installed': False,
        'matlab_version': None
    }
    
    # Step 1: Check embedded Python
    print("\n[1/4] Checking embedded Python environment...")
    python_exe = workspace_root / "environments" / "python" / "python.exe"
    if python_exe.exists():
        print(f"  ✓ Found: {python_exe}")
        results['python_ready'] = True
    else:
        print(f"  ✗ Not found: {python_exe}")
        print("  Please run: environments\\python\\setup_embedded_python.ps1")
        return results
    
    # Step 2: Check Spinach package
    print("\n[2/4] Checking Spinach package...")
    spinach_kernel = workspace_root / "environments" / "spinach" / "kernel"
    if spinach_kernel.exists():
        print(f"  ✓ Found: {spinach_kernel}")
        results['spinach_ready'] = True
    else:
        print(f"  ✗ Not found: {spinach_kernel}")
        print("  Spinach package not installed - MATLAB backend will not be available")
    
    # Step 3: Auto-detect MATLAB installation
    print("\n[3/4] Detecting MATLAB installation...")
    matlab_path = auto_detect_matlab()
    
    if matlab_path:
        print(f"  ✓ Found MATLAB: {matlab_path}")
        results['matlab_detected'] = True
        results['matlab_path'] = matlab_path
        
        # Detect MATLAB version
        version_info_file = matlab_path / "VersionInfo.xml"
        if version_info_file.exists():
            try:
                import xml.etree.ElementTree as ET
                tree = ET.parse(version_info_file)
                root = tree.getroot()
                release = root.find('.//release')
                if release is not None and release.text:
                    results['matlab_version'] = release.text.strip()
                    print(f"  ✓ Version: {results['matlab_version']}")
            except Exception:
                # Try to get version from path
                if matlab_path.name.startswith('R20'):
                    results['matlab_version'] = matlab_path.name
                else:
                    results['matlab_version'] = "Unknown"
        elif matlab_path.name.startswith('R20'):
            results['matlab_version'] = matlab_path.name
        else:
            results['matlab_version'] = "Unknown"
    else:
        print("  ✗ MATLAB not found")
        print("  Pure Python mode will be used")
        return results
    
    # Step 4: Install MATLAB Engine if not already installed
    print("\n[4/4] Configuring MATLAB Engine...")
    
    # Check if already installed
    check_result = subprocess.run(
        [str(python_exe), "-c", "import matlab.engine; print('OK')"],
        capture_output=True,
        text=True
    )
    
    if check_result.returncode == 0 and "OK" in check_result.stdout:
        print("  ✓ MATLAB Engine already installed")
        results['matlab_engine_installed'] = True
    else:
        # Install MATLAB Engine
        matlab_setup = matlab_path / "extern" / "engines" / "python" / "setup.py"
        
        if matlab_setup.exists():
            print(f"  Installing MATLAB Engine from: {matlab_setup}")
            print("  This may take a few minutes...")
            
            install_result = subprocess.run(
                [str(python_exe), str(matlab_setup), "install"],
                capture_output=True,
                text=True
            )
            
            if install_result.returncode == 0:
                print("  ✓ MATLAB Engine installed successfully!")
                results['matlab_engine_installed'] = True
            else:
                print("  ✗ MATLAB Engine installation failed:")
                print(install_result.stderr[:500])  # Show first 500 chars of error
        else:
            print(f"  ✗ MATLAB Engine setup.py not found: {matlab_setup}")
    
    # Save configuration
    if results['matlab_detected'] and results['matlab_engine_installed']:
        from .user_config import get_user_config
        user_config = get_user_config()
        
        user_config.set_matlab_config(
            matlab_path=str(matlab_path),
            version=results['matlab_version'],
            engine_installed=True
        )
        
        user_config.set_preferences(use_matlab=True, execution_mode='local')
        print(f"\n✓ Configuration saved to user_config.json")
    
    print("\n" + "="*70)
    print("Auto-Configuration Complete!")
    print("="*70)
    
    return results


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
            print("\n" + "="*60)
            print("CONFIGURING MATLAB ENGINE")
            print("="*60)
            print(f"MATLAB Path: {matlab_path}")
            
            matlab_setup = Path(matlab_path) / "extern" / "engines" / "python" / "setup.py"
            embedded_python = workspace_root / "environments" / "python" / "python.exe"
            
            print(f"Setup Script: {matlab_setup}")
            print(f"Target Python: {embedded_python}")
            print(f"Setup exists: {matlab_setup.exists()}")
            print(f"Python exists: {embedded_python.exists()}")
            
            if matlab_setup.exists() and embedded_python.exists():
                # Install MATLAB Engine to embedded Python
                print(f"\nInstalling MATLAB Engine to embedded Python...")
                print("This may take a few minutes...")
                
                result = subprocess.run(
                    [str(embedded_python), str(matlab_setup), "install"],
                    capture_output=True,
                    text=True
                )
                
                print(f"\nReturn code: {result.returncode}")
                if result.stdout:
                    print("STDOUT:")
                    print(result.stdout)
                if result.stderr:
                    print("STDERR:")
                    print(result.stderr)
                
                if result.returncode == 0:
                    print("\n" + "="*60)
                    print("[SUCCESS] MATLAB Engine installed successfully!")
                    print("="*60)
                    
                    # Detect MATLAB version from path
                    matlab_version = None
                    matlab_path_obj = Path(matlab_path)
                    
                    # Method 1: Look for version in path parts (e.g., R2021a, R2025b)
                    parts = matlab_path_obj.parts
                    for part in parts:
                        if part.startswith('R20'):  # R2021a, R2025a, etc.
                            matlab_version = part
                            break
                    
                    # Method 2: If no version in path, check VersionInfo.xml
                    if not matlab_version:
                        version_info_file = matlab_path_obj / "VersionInfo.xml"
                        if version_info_file.exists():
                            try:
                                import xml.etree.ElementTree as ET
                                tree = ET.parse(version_info_file)
                                root = tree.getroot()
                                release = root.find('.//release')
                                if release is not None and release.text:
                                    matlab_version = release.text.strip()
                                    print(f"Detected MATLAB version from VersionInfo.xml: {matlab_version}")
                            except Exception as e:
                                print(f"Could not read VersionInfo.xml: {e}")
                    
                    # Method 3: Fallback to generic version
                    if not matlab_version:
                        matlab_version = "Unknown"
                        print("Warning: Could not detect MATLAB version, using 'Unknown'")
                    
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
