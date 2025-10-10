"""
Test Startup Dialog

Quick test script for the startup configuration dialog.
"""

import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from PySide6.QtWidgets import QApplication
from src.ui.startup_dialog import StartupDialog


def main():
    app = QApplication(sys.argv)
    
    # Test with different initialization scenarios
    
    print("Test 1: All capabilities available")
    init_results_all = {
        'matlab_available': True,
        'python_simulation_available': True,
        'network_available': True,
        'file_integrity': True
    }
    
    dialog1 = StartupDialog(init_results_all)
    
    def on_config_selected(config):
        print(f"\nSelected configuration:")
        print(f"  Use MATLAB: {config['use_matlab']}")
        print(f"  Execution: {config['execution']}")
        print(f"  UI-only mode: {config['ui_only_mode']}")
        
        # Show which engine will actually be used
        if config['ui_only_mode']:
            print(f"  Actual engine: None (UI-only)")
        elif config['use_matlab']:
            print(f"  Actual engine: MATLAB Spinach")
        else:
            print(f"  Actual engine: Pure Python")
    
    dialog1.config_selected.connect(on_config_selected)
    
    result = dialog1.exec()
    
    if result == dialog1.Accepted:
        print("\nUser accepted configuration")
    else:
        print("\nUser cancelled")
    
    # Test 2: Only Python available (MATLAB failed)
    print("\n" + "="*60)
    print("Test 2: MATLAB unavailable, Python only")
    
    init_results_python = {
        'matlab_available': False,
        'python_simulation_available': True,
        'network_available': False,
        'file_integrity': True
    }
    
    dialog2 = StartupDialog(init_results_python)
    dialog2.config_selected.connect(on_config_selected)
    
    result2 = dialog2.exec()
    
    if result2 == dialog2.Accepted:
        print("\nUser accepted configuration")
    else:
        print("\nUser cancelled")


if __name__ == "__main__":
    main()
