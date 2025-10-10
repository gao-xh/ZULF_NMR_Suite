"""
Test Windows App User Model ID configuration
"""

import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

def test_app_id_reading():
    """Test reading APP_USER_MODEL_ID from config"""
    config_file = project_root / 'config.txt'
    app_id = None
    
    print(f"Reading config from: {config_file}")
    print(f"File exists: {config_file.exists()}")
    
    if config_file.exists():
        with open(config_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line.startswith('APP_USER_MODEL_ID'):
                    parts = line.split('=', 1)
                    if len(parts) == 2:
                        app_id = parts[1].strip()
                        break
    
    print(f"\nApp User Model ID: {app_id}")
    
    # Test on Windows
    if sys.platform.startswith('win'):
        print(f"\nPlatform: {sys.platform} (Windows detected)")
        print("Testing SetCurrentProcessExplicitAppUserModelID...")
        
        try:
            import ctypes
            if app_id:
                ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(app_id)
                print(f"✓ Successfully set App ID: {app_id}")
            else:
                print("✗ No App ID found in config")
        except Exception as e:
            print(f"✗ Error: {e}")
    else:
        print(f"\nPlatform: {sys.platform} (Not Windows, skipping test)")

if __name__ == "__main__":
    test_app_id_reading()
