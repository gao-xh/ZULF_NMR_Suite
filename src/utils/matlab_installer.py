"""
MATLAB Engine Installer Module

Provides utilities for installing MATLAB Engine to Python environments.
"""

import subprocess
from pathlib import Path


def install_matlab_engine(matlab_path, python_executable):
    """
    Install MATLAB Engine to a specific Python environment.
    
    Args:
        matlab_path (Path or str): Path to MATLAB installation directory
        python_executable (Path or str): Path to Python executable
        
    Returns:
        dict: Installation result {
            'success': bool,
            'returncode': int,
            'stdout': str,
            'stderr': str,
            'error': str or None
        }
    """
    matlab_path = Path(matlab_path)
    python_executable = Path(python_executable)
    
    result = {
        'success': False,
        'returncode': -1,
        'stdout': '',
        'stderr': '',
        'error': None
    }
    
    # Verify MATLAB setup.py exists
    matlab_setup = matlab_path / "extern" / "engines" / "python" / "setup.py"
    if not matlab_setup.exists():
        result['error'] = f"MATLAB setup.py not found at: {matlab_setup}"
        return result
    
    # Verify Python executable exists
    if not python_executable.exists():
        result['error'] = f"Python executable not found at: {python_executable}"
        return result
    
    print(f"\nInstalling MATLAB Engine to: {python_executable}")
    print(f"Using MATLAB at: {matlab_path}")
    print(f"Setup script: {matlab_setup}")
    print("This may take a few minutes...")
    
    # Run setup.py install
    try:
        proc_result = subprocess.run(
            [str(python_executable), str(matlab_setup), "install"],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        result['returncode'] = proc_result.returncode
        result['stdout'] = proc_result.stdout
        result['stderr'] = proc_result.stderr
        
        if proc_result.returncode == 0:
            result['success'] = True
            print("\n[SUCCESS] MATLAB Engine installed successfully!")
        else:
            result['error'] = f"Installation failed with return code {proc_result.returncode}"
            print(f"\n[ERROR] {result['error']}")
            if proc_result.stderr:
                print(f"Error details:\n{proc_result.stderr}")
        
    except subprocess.TimeoutExpired:
        result['error'] = "Installation timed out after 5 minutes"
        print(f"\n[ERROR] {result['error']}")
    except Exception as e:
        result['error'] = f"Installation error: {str(e)}"
        print(f"\n[ERROR] {result['error']}")
    
    return result


def verify_matlab_engine_installation(python_executable):
    """
    Verify that MATLAB Engine is installed in a Python environment.
    
    Args:
        python_executable (Path or str): Path to Python executable
        
    Returns:
        dict: Verification result {
            'installed': bool,
            'version': str or None,
            'import_successful': bool,
            'error': str or None
        }
    """
    python_executable = Path(python_executable)
    
    result = {
        'installed': False,
        'version': None,
        'import_successful': False,
        'error': None
    }
    
    if not python_executable.exists():
        result['error'] = f"Python executable not found: {python_executable}"
        return result
    
    # Try to import matlab.engine
    test_script = "import matlab.engine; print(matlab.engine.__version__ if hasattr(matlab.engine, '__version__') else 'installed')"
    
    try:
        proc_result = subprocess.run(
            [str(python_executable), "-c", test_script],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if proc_result.returncode == 0:
            result['installed'] = True
            result['import_successful'] = True
            version_output = proc_result.stdout.strip()
            result['version'] = version_output if version_output else "unknown"
        else:
            result['error'] = proc_result.stderr.strip()
            if "No module named 'matlab'" in result['error']:
                result['error'] = "MATLAB Engine not installed"
        
    except subprocess.TimeoutExpired:
        result['error'] = "Verification timed out"
    except Exception as e:
        result['error'] = f"Verification error: {str(e)}"
    
    return result


def uninstall_matlab_engine(python_executable):
    """
    Uninstall MATLAB Engine from a Python environment.
    
    Args:
        python_executable (Path or str): Path to Python executable
        
    Returns:
        dict: Uninstallation result {
            'success': bool,
            'returncode': int,
            'stdout': str,
            'stderr': str,
            'error': str or None
        }
    """
    python_executable = Path(python_executable)
    
    result = {
        'success': False,
        'returncode': -1,
        'stdout': '',
        'stderr': '',
        'error': None
    }
    
    if not python_executable.exists():
        result['error'] = f"Python executable not found: {python_executable}"
        return result
    
    print(f"\nUninstalling MATLAB Engine from: {python_executable}")
    
    try:
        proc_result = subprocess.run(
            [str(python_executable), "-m", "pip", "uninstall", "-y", "matlabengine"],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        result['returncode'] = proc_result.returncode
        result['stdout'] = proc_result.stdout
        result['stderr'] = proc_result.stderr
        
        if proc_result.returncode == 0:
            result['success'] = True
            print("[SUCCESS] MATLAB Engine uninstalled successfully!")
        else:
            result['error'] = f"Uninstallation failed with return code {proc_result.returncode}"
            print(f"[ERROR] {result['error']}")
        
    except subprocess.TimeoutExpired:
        result['error'] = "Uninstallation timed out"
        print(f"[ERROR] {result['error']}")
    except Exception as e:
        result['error'] = f"Uninstallation error: {str(e)}"
        print(f"[ERROR] {result['error']}")
    
    return result


def get_matlab_engine_setup_path(matlab_path):
    """
    Get the path to MATLAB Engine setup.py.
    
    Args:
        matlab_path (Path or str): Path to MATLAB installation
        
    Returns:
        Path or None: Path to setup.py if it exists, None otherwise
    """
    matlab_path = Path(matlab_path)
    setup_py = matlab_path / "extern" / "engines" / "python" / "setup.py"
    return setup_py if setup_py.exists() else None
