"""
Test Python Environment Manager

Run this script to test the environment detection and management.
"""

import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from src.utils.environment import PythonEnvironment, get_environment


def test_environment():
    """Test environment detection and features."""
    
    print("=" * 70)
    print("Python Environment Manager - Test Suite")
    print("=" * 70)
    print()
    
    # Test 1: Auto-detection
    print("[Test 1] Auto-detecting Python environment...")
    env = PythonEnvironment(auto_detect=True)
    
    if env.python_exe:
        print("✓ Environment detected successfully")
        print(f"  Type: {env.env_type}")
        print(f"  Name: {env.env_name}")
        print(f"  Version: {env.version}")
        print(f"  Python: {env.python_exe}")
        print(f"  PythonW: {env.pythonw_exe or 'Not available'}")
    else:
        print("✗ Failed to detect environment")
        return False
    
    print()
    
    # Test 2: Get executable
    print("[Test 2] Getting executables...")
    python_exe = env.get_executable(gui=False)
    pythonw_exe = env.get_executable(gui=True)
    print(f"  python.exe: {python_exe}")
    print(f"  pythonw.exe: {pythonw_exe}")
    print()
    
    # Test 3: Check installed packages
    print("[Test 3] Checking installed packages...")
    test_packages = ['PySide6', 'numpy', 'matplotlib']
    for pkg in test_packages:
        installed = env.is_package_installed(pkg)
        status = "✓ installed" if installed else "✗ not installed"
        print(f"  {pkg}: {status}")
    print()
    
    # Test 4: Environment info
    print("[Test 4] Environment information...")
    info = env.get_info()
    for key, value in info.items():
        print(f"  {key}: {value}")
    print()
    
    # Test 5: Global environment
    print("[Test 5] Testing global environment access...")
    global_env = get_environment()
    print(f"  Global env: {global_env}")
    print(f"  Same as local: {global_env.python_exe == env.python_exe}")
    print()
    
    # Test 6: Embedded Python check
    print("[Test 6] Checking for embedded Python...")
    embedded_path = env.embedded_python_dir / "python.exe"
    if embedded_path.exists():
        print(f"  ✓ Embedded Python found at: {embedded_path}")
        embedded_env = PythonEnvironment(str(embedded_path))
        print(f"  Version: {embedded_env.version}")
        print(f"  Type: {embedded_env.env_type}")
    else:
        print(f"  ✗ Embedded Python not found")
        print(f"  Expected location: {embedded_path}")
        print(f"  To set up embedded Python, see: environments/README.md")
    print()
    
    print("=" * 70)
    print("Test completed successfully!")
    print("=" * 70)
    
    return True


if __name__ == "__main__":
    try:
        success = test_environment()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n✗ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
