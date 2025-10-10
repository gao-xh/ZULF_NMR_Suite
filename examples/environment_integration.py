"""
Example: Using Python Environment Manager in run.py

This shows how to integrate the environment manager into your application.
"""

import sys
from pathlib import Path

# Add src to Python path
sys.path.insert(0, str(Path(__file__).parent))

from src.utils.environment import PythonEnvironment, get_environment


def main():
    """Main application entry point with environment management."""
    
    print("=" * 70)
    print("ZULF-NMR Suite - Environment Integration Example")
    print("=" * 70)
    print()
    
    # Initialize environment
    print("Initializing Python environment...")
    env = get_environment()
    
    if not env.python_exe:
        print("ERROR: Failed to detect Python environment!")
        print("Please check your installation.")
        return 1
    
    print(f"✓ Environment detected: {env.env_type} ({env.env_name})")
    print(f"  Python: {env.version}")
    print(f"  Executable: {env.python_exe}")
    print()
    
    # Check required packages
    print("Checking dependencies...")
    required_packages = ['PySide6', 'numpy', 'matplotlib']
    missing_packages = []
    
    for pkg in required_packages:
        if env.is_package_installed(pkg):
            print(f"  ✓ {pkg}")
        else:
            print(f"  ✗ {pkg} - NOT INSTALLED")
            missing_packages.append(pkg)
    
    if missing_packages:
        print()
        print("WARNING: Missing required packages!")
        print("To install: python -m pip install " + " ".join(missing_packages))
        
        # Optionally auto-install
        # response = input("\nInstall missing packages now? (y/n): ")
        # if response.lower() == 'y':
        #     for pkg in missing_packages:
        #         success, msg = env.install_package(pkg)
        #         print(f"  {pkg}: {msg}")
    
    print()
    
    # Now you can use the environment in your application
    # For example, when launching subprocesses:
    # subprocess.run([str(env.get_executable(gui=True)), 'script.py'])
    
    print("Environment setup complete!")
    print("=" * 70)
    
    # Continue with your normal application startup...
    # from PySide6.QtWidgets import QApplication
    # app = QApplication(sys.argv)
    # ...
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
