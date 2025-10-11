"""
MATLAB Detection Module

Provides utilities for detecting MATLAB installations on the system.
"""

import os
from pathlib import Path


def auto_detect_matlab():
    """
    Automatically detect MATLAB installation on Windows.
    
    Searches in common installation directories and Windows registry.
    
    Returns:
        Path or None: Path to MATLAB installation directory if found, None otherwise
    """
    matlab_installations = []
    
    # Method 1: Check common installation directories
    matlab_installations.extend(_check_common_paths())
    
    # Method 2: Check Windows registry
    matlab_installations.extend(_check_windows_registry())
    
    # Return the newest version (last in sorted list)
    if matlab_installations:
        # Sort by directory name (R2024a > R2023b > R2021a)
        matlab_installations.sort(key=lambda p: p.name, reverse=True)
        return matlab_installations[0]
    
    return None


def _check_common_paths():
    """
    Check common MATLAB installation paths.
    
    Returns:
        list[Path]: List of found MATLAB installation directories
    """
    common_paths = [
        r"C:\Program Files\MATLAB",
        r"C:\Program Files (x86)\MATLAB",
        r"D:\MATLAB",
        r"E:\MATLAB",
        r"F:\MATLAB",
        r"C:\MATLAB"
    ]
    
    matlab_installations = []
    
    for base_path in common_paths:
        base = Path(base_path)
        if not base.exists():
            continue
        
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
    
    return matlab_installations


def _check_windows_registry():
    """
    Check Windows registry for MATLAB installations.
    
    Returns:
        list[Path]: List of found MATLAB installation directories
    """
    matlab_installations = []
    
    try:
        import winreg
        reg_key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE, 
            r"SOFTWARE\MathWorks\MATLAB", 
            0, 
            winreg.KEY_READ
        )
        
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
    
    return matlab_installations


def get_matlab_version(matlab_path):
    """
    Get MATLAB version from VersionInfo.xml.
    
    Args:
        matlab_path (Path): Path to MATLAB installation directory
        
    Returns:
        str or None: MATLAB version string (e.g., "R2024a"), None if not found
    """
    version_info_file = Path(matlab_path) / "VersionInfo.xml"
    if not version_info_file.exists():
        return None
    
    try:
        import xml.etree.ElementTree as ET
        tree = ET.parse(version_info_file)
        root = tree.getroot()
        release = root.find('.//release')
        if release is not None and release.text:
            return release.text.strip()
    except Exception:
        pass
    
    return None


def verify_matlab_installation(matlab_path):
    """
    Verify that a MATLAB installation is valid.
    
    Args:
        matlab_path (Path or str): Path to MATLAB installation
        
    Returns:
        dict: Verification result {
            'valid': bool,
            'has_matlab_exe': bool,
            'has_setup_py': bool,
            'version': str or None,
            'error': str or None
        }
    """
    matlab_path = Path(matlab_path)
    
    result = {
        'valid': False,
        'has_matlab_exe': False,
        'has_setup_py': False,
        'version': None,
        'error': None
    }
    
    # Check if directory exists
    if not matlab_path.exists():
        result['error'] = f"Directory does not exist: {matlab_path}"
        return result
    
    # Check for matlab.exe
    matlab_exe = matlab_path / "bin" / "matlab.exe"
    result['has_matlab_exe'] = matlab_exe.exists()
    
    # Check for setup.py (required for MATLAB Engine installation)
    setup_py = matlab_path / "extern" / "engines" / "python" / "setup.py"
    result['has_setup_py'] = setup_py.exists()
    
    # Get version
    result['version'] = get_matlab_version(matlab_path)
    
    # Determine if valid
    if result['has_matlab_exe'] and result['has_setup_py']:
        result['valid'] = True
    else:
        missing = []
        if not result['has_matlab_exe']:
            missing.append("matlab.exe")
        if not result['has_setup_py']:
            missing.append("Python Engine setup.py")
        result['error'] = f"Missing required files: {', '.join(missing)}"
    
    return result
