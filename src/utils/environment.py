"""
Python Environment Manager

Provides runtime information about the Python environment.
NOTE: Environment activation is handled by start.bat/start.ps1 BEFORE this runs.

Use cases:
- Detect current environment type (conda/venv/embedded/system)
- Get Python executable paths for subprocess launches
- Check if required packages are installed
- Support embedded Python for standalone distribution

This does NOT activate environments - that's done by the launcher scripts.
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Optional, Dict, List, Tuple


class PythonEnvironment:
    """
    Manages Python environment configuration and operations.
    
    Supports:
    - Embedded Python (environments/python/)
    - Conda environments
    - Virtual environments (venv)
    - System Python
    """
    
    def __init__(self, python_path: Optional[str] = None, auto_detect: bool = True):
        """
        Initialize Python environment.
        
        Args:
            python_path: Explicit path to python.exe. If None, will auto-detect.
            auto_detect: Whether to auto-detect environment if python_path is None.
        """
        self.workspace_root = Path(__file__).parent.parent.parent
        self.embedded_python_dir = self.workspace_root / "environments" / "python"
        
        # Environment info
        self.python_path: Optional[Path] = None
        self.python_exe: Optional[Path] = None
        self.pythonw_exe: Optional[Path] = None
        self.version: Optional[str] = None
        self.env_type: Optional[str] = None  # 'embedded', 'conda', 'venv', 'system'
        self.env_name: Optional[str] = None  # For conda/venv
        
        # Initialize
        if python_path:
            self.set_python_path(python_path)
        elif auto_detect:
            self.auto_detect()
    
    def auto_detect(self) -> bool:
        """
        Auto-detect Python environment.
        
        Priority order:
        1. Current Python interpreter (sys.executable) - already activated by start.bat
        2. Embedded Python (environments/python/) - for standalone distribution
        3. Config file (config.txt) - fallback
        
        Returns:
            True if environment detected successfully
        """
        # Priority 1: Use current interpreter (most common - already activated)
        if self._check_current_interpreter():
            return True
        
        # Priority 2: Check embedded Python (for standalone distribution)
        if self._check_embedded_python():
            return True
        
        # Priority 3: Read from config.txt (fallback)
        if self._check_config_file():
            return True
        
        return False
    
    def _check_embedded_python(self) -> bool:
        """Check if embedded Python exists and is valid."""
        python_exe = self.embedded_python_dir / "python.exe"
        if python_exe.exists():
            return self.set_python_path(str(python_exe))
        return False
    
    def _check_current_interpreter(self) -> bool:
        """Use the currently running Python interpreter."""
        return self.set_python_path(sys.executable)
    
    def _check_config_file(self) -> bool:
        """Read Python path from config.txt."""
        config_file = self.workspace_root / "config.txt"
        if not config_file.exists():
            return False
        
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('PYTHON_ENV_PATH'):
                        parts = line.split('=', 1)
                        if len(parts) == 2:
                            path = parts[1].strip().replace('/', '\\')
                            return self.set_python_path(path)
        except Exception:
            pass
        
        return False
    
    def set_python_path(self, python_path: str) -> bool:
        """
        Set and validate Python path.
        
        Args:
            python_path: Path to python.exe
            
        Returns:
            True if path is valid and environment detected successfully
        """
        python_path = Path(python_path)
        
        # Validate existence
        if not python_path.exists():
            return False
        
        # Resolve to python.exe if directory given
        if python_path.is_dir():
            python_exe = python_path / "python.exe"
            if not python_exe.exists():
                return False
            python_path = python_exe
        
        # Store paths
        self.python_exe = python_path
        self.python_path = python_path.parent
        
        # Check for pythonw.exe
        pythonw = self.python_path / "pythonw.exe"
        self.pythonw_exe = pythonw if pythonw.exists() else None
        
        # Detect version
        self.version = self._detect_version()
        if not self.version:
            return False
        
        # Detect environment type
        self._detect_env_type()
        
        return True
    
    def _detect_version(self) -> Optional[str]:
        """Detect Python version."""
        try:
            result = subprocess.run(
                [str(self.python_exe), "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                return result.stdout.strip() or result.stderr.strip()
        except Exception:
            pass
        return None
    
    def _detect_env_type(self):
        """Detect environment type (embedded, conda, venv, system)."""
        python_path_str = str(self.python_path).lower()
        
        # Check embedded
        if self.embedded_python_dir.exists() and \
           self.python_path.resolve() == self.embedded_python_dir.resolve():
            self.env_type = 'embedded'
            self.env_name = 'embedded'
            return
        
        # Check conda
        if 'anaconda' in python_path_str or 'conda' in python_path_str or 'miniconda' in python_path_str:
            self.env_type = 'conda'
            # Extract environment name
            parts = self.python_path.parts
            for i, part in enumerate(parts):
                if part.lower() in ('envs', 'environments'):
                    if i + 1 < len(parts):
                        self.env_name = parts[i + 1]
                        return
            self.env_name = 'base'
            return
        
        # Check venv
        if (self.python_path / 'pyvenv.cfg').exists():
            self.env_type = 'venv'
            self.env_name = self.python_path.name
            return
        
        # Default to system
        self.env_type = 'system'
        self.env_name = 'system'
    
    def get_executable(self, gui: bool = False) -> Optional[Path]:
        """
        Get Python executable path.
        
        Args:
            gui: If True, return pythonw.exe (for GUI apps without console).
                 Falls back to python.exe if pythonw.exe doesn't exist.
        
        Returns:
            Path to python.exe or pythonw.exe
        """
        if gui and self.pythonw_exe:
            return self.pythonw_exe
        return self.python_exe
    
    def run_command(self, *args, **kwargs) -> subprocess.CompletedProcess:
        """
        Run a command using this Python environment.
        
        Args:
            *args: Command arguments (don't include python.exe)
            **kwargs: Passed to subprocess.run()
        
        Returns:
            subprocess.CompletedProcess result
        """
        cmd = [str(self.python_exe)] + list(args)
        return subprocess.run(cmd, **kwargs)
    
    def is_package_installed(self, package: str) -> bool:
        """
        Check if a package is installed.
        
        Args:
            package: Package name (e.g., 'PySide6', 'numpy')
        
        Returns:
            True if package is installed
        """
        try:
            result = self.run_command(
                '-c', f'import {package}',
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except Exception:
            return False
    
    def install_package(self, package: str, upgrade: bool = False) -> Tuple[bool, str]:
        """
        Install a package using pip.
        
        Args:
            package: Package name or requirement specifier
            upgrade: Whether to upgrade if already installed
        
        Returns:
            (success, message) tuple
        """
        try:
            cmd = ['-m', 'pip', 'install']
            if upgrade:
                cmd.append('--upgrade')
            cmd.append(package)
            
            result = self.run_command(
                *cmd,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            if result.returncode == 0:
                return True, f"Successfully installed {package}"
            else:
                return False, result.stderr or result.stdout
        except Exception as e:
            return False, str(e)
    
    def install_requirements(self, requirements_file: Optional[Path] = None) -> Tuple[bool, str]:
        """
        Install packages from requirements.txt.
        
        Args:
            requirements_file: Path to requirements.txt. 
                             If None, uses workspace_root/requirements.txt
        
        Returns:
            (success, message) tuple
        """
        if requirements_file is None:
            requirements_file = self.workspace_root / "requirements.txt"
        
        if not requirements_file.exists():
            return False, f"Requirements file not found: {requirements_file}"
        
        try:
            result = self.run_command(
                '-m', 'pip', 'install', '-r', str(requirements_file),
                capture_output=True,
                text=True,
                timeout=600
            )
            
            if result.returncode == 0:
                return True, f"Successfully installed requirements from {requirements_file.name}"
            else:
                return False, result.stderr or result.stdout
        except Exception as e:
            return False, str(e)
    
    def get_info(self) -> Dict[str, any]:
        """
        Get environment information dictionary.
        
        Returns:
            Dictionary with environment details
        """
        return {
            'python_exe': str(self.python_exe) if self.python_exe else None,
            'pythonw_exe': str(self.pythonw_exe) if self.pythonw_exe else None,
            'python_path': str(self.python_path) if self.python_path else None,
            'version': self.version,
            'env_type': self.env_type,
            'env_name': self.env_name,
            'has_pythonw': self.pythonw_exe is not None,
        }
    
    def __repr__(self) -> str:
        return f"PythonEnvironment(type={self.env_type}, name={self.env_name}, version={self.version})"


# Global environment instance
_global_env: Optional[PythonEnvironment] = None


def get_environment() -> PythonEnvironment:
    """
    Get the global Python environment instance.
    Creates one if it doesn't exist.
    
    Returns:
        PythonEnvironment instance
    """
    global _global_env
    if _global_env is None:
        _global_env = PythonEnvironment(auto_detect=True)
    return _global_env


def set_environment(env: PythonEnvironment):
    """
    Set the global Python environment instance.
    
    Args:
        env: PythonEnvironment instance to use globally
    """
    global _global_env
    _global_env = env
