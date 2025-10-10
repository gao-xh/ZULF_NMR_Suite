"""
User Configuration Management

Handles saving and loading user-specific configuration including:
- MATLAB installation path and version
- Spinach configuration
- First-run status
- User preferences
"""

import json
from pathlib import Path
from datetime import datetime


class UserConfig:
    """User configuration manager"""
    
    def __init__(self):
        """Initialize configuration manager"""
        self.workspace_root = Path(__file__).parent.parent.parent
        self.config_file = self.workspace_root / "user_config.json"
        self.config = self._load_config()
    
    def _load_config(self):
        """Load configuration from file"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                print(f"Warning: Failed to load user config: {e}")
                return self._default_config()
        else:
            return self._default_config()
    
    def _default_config(self):
        """Get default configuration"""
        return {
            'first_run_completed': False,
            'matlab': {
                'configured': False,
                'installation_path': None,
                'version': None,
                'engine_installed': False
            },
            'spinach': {
                'configured': False,
                'path': None,
                'version': None
            },
            'preferences': {
                'use_matlab': False,
                'execution_mode': 'local'
            },
            'history': {
                'first_run_date': None,
                'last_matlab_config_date': None,
                'last_spinach_config_date': None
            }
        }
    
    def save(self):
        """Save configuration to file"""
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2)
            return True
        except Exception as e:
            print(f"Error: Failed to save user config: {e}")
            return False
    
    def is_first_run(self):
        """Check if this is the first run"""
        return not self.config.get('first_run_completed', False)
    
    def mark_first_run_complete(self):
        """Mark first run as completed"""
        self.config['first_run_completed'] = True
        if not self.config['history']['first_run_date']:
            self.config['history']['first_run_date'] = datetime.now().isoformat()
        self.save()
    
    def set_matlab_config(self, matlab_path, version=None, engine_installed=False):
        """
        Save MATLAB configuration
        
        Args:
            matlab_path: Path to MATLAB installation
            version: MATLAB version (e.g., "R2025a")
            engine_installed: Whether MATLAB Engine is installed
        """
        self.config['matlab']['configured'] = True
        self.config['matlab']['installation_path'] = str(matlab_path) if matlab_path else None
        self.config['matlab']['version'] = version
        self.config['matlab']['engine_installed'] = engine_installed
        self.config['history']['last_matlab_config_date'] = datetime.now().isoformat()
        self.save()
    
    def set_spinach_config(self, spinach_path=None, version=None):
        """
        Save Spinach configuration
        
        Args:
            spinach_path: Path to Spinach installation
            version: Spinach version
        """
        self.config['spinach']['configured'] = True
        self.config['spinach']['path'] = str(spinach_path) if spinach_path else None
        self.config['spinach']['version'] = version
        self.config['history']['last_spinach_config_date'] = datetime.now().isoformat()
        self.save()
    
    def set_preferences(self, use_matlab=None, execution_mode=None):
        """
        Save user preferences
        
        Args:
            use_matlab: Whether to use MATLAB (True) or pure Python (False)
            execution_mode: 'local' or 'workstation'
        """
        if use_matlab is not None:
            self.config['preferences']['use_matlab'] = use_matlab
        if execution_mode is not None:
            self.config['preferences']['execution_mode'] = execution_mode
        self.save()
    
    def get_matlab_path(self):
        """Get saved MATLAB installation path"""
        return self.config['matlab'].get('installation_path')
    
    def get_matlab_version(self):
        """Get saved MATLAB version"""
        return self.config['matlab'].get('version')
    
    def is_matlab_configured(self):
        """Check if MATLAB is configured"""
        return self.config['matlab'].get('configured', False)
    
    def is_matlab_engine_installed(self):
        """Check if MATLAB Engine is installed"""
        return self.config['matlab'].get('engine_installed', False)
    
    def is_spinach_configured(self):
        """Check if Spinach is configured"""
        return self.config['spinach'].get('configured', False)
    
    def get_preferences(self):
        """Get user preferences"""
        return self.config.get('preferences', {})
    
    def export_summary(self):
        """Export configuration summary for display"""
        return {
            'First Run': 'Completed' if self.config['first_run_completed'] else 'Not completed',
            'MATLAB Configured': 'Yes' if self.is_matlab_configured() else 'No',
            'MATLAB Path': self.get_matlab_path() or 'Not set',
            'MATLAB Version': self.get_matlab_version() or 'Unknown',
            'MATLAB Engine': 'Installed' if self.is_matlab_engine_installed() else 'Not installed',
            'Spinach Configured': 'Yes' if self.is_spinach_configured() else 'No',
            'Use MATLAB': 'Yes' if self.config['preferences']['use_matlab'] else 'No (Pure Python)',
            'Execution Mode': self.config['preferences']['execution_mode'].title()
        }


# Global instance
_user_config = None

def get_user_config():
    """Get global user configuration instance"""
    global _user_config
    if _user_config is None:
        _user_config = UserConfig()
    return _user_config
