"""
Simple test of startup flow
"""

import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from PySide6.QtWidgets import QApplication
from src.ui.startup_dialog import StartupDialog

def test_startup():
    print("Creating QApplication...")
    app = QApplication(sys.argv)
    
    print("Creating StartupDialog...")
    init_results = {
        'matlab_available': True,
        'python_simulation_available': True,
        'network_available': False,
        'file_integrity': True
    }
    
    dialog = StartupDialog(init_results)
    
    print("Showing dialog...")
    result = dialog.exec()
    
    if result:
        config = dialog.get_config()
        print(f"\nAccepted! Configuration:")
        print(f"  use_matlab: {config['use_matlab']}")
        print(f"  execution: {config['execution']}")
        print(f"  ui_only_mode: {config['ui_only_mode']}")
    else:
        print("\nCancelled!")
    
    sys.exit(0)

if __name__ == "__main__":
    test_startup()
