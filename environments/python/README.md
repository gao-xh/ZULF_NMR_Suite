# Embedded Python Environment

This directory is reserved for an embedded Python distribution.

## Installation Steps

### 1. Download Python Embeddable Package

Visit Python official website and download the embeddable package:
- URL: https://www.python.org/downloads/windows/
- Look for "Windows embeddable package (64-bit)"
- Recommended: Python 3.12.7 or later
- File example: `python-3.12.7-embed-amd64.zip`

### 2. Extract Here

Extract the entire contents of the zip file to this directory:

```
environments/python/
├── python.exe                  # Python interpreter
├── python312.dll               # Python runtime DLL
├── python3.dll                 # Python 3 DLL
├── pythonw.exe                 # Windowless Python
├── python312.zip               # Standard library (compressed)
├── Lib/                        # Additional libraries
├── DLLs/                       # Extension modules
└── _pth file                   # Path configuration
```

### 3. Enable pip

The embeddable package does not include pip by default. Install it:

```powershell
cd environments\python

# Download get-pip.py
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

# Install pip
.\python.exe get-pip.py

# Verify installation
.\python.exe -m pip --version
```

### 4. Configure Path

Edit the `python312._pth` file (or similar name) in this directory:

```
python312.zip
.
Lib\site-packages

# Uncomment to enable importing from current directory
import site
```

Make sure `import site` is uncommented to enable pip functionality.

### 5. Install Dependencies

Install all required packages:

```powershell
# From this directory (environments/python/)
.\python.exe -m pip install -r ..\..\requirements.txt

# Or from project root
environments\python\python.exe -m pip install -r requirements.txt
```

### 6. Update Configuration

Edit `config.txt` in project root to use embedded Python:

```ini
# Use embedded Python
PYTHON_ENV_PATH = environments/python/python.exe
```

## Verification

Test the embedded Python installation:

```powershell
# Check Python version
.\python.exe --version

# Check installed packages
.\python.exe -m pip list

# Test PySide6 import
.\python.exe -c "from PySide6 import QtWidgets; print('PySide6 OK')"
```

## Auto-Detection

The application will automatically:
1. Check for Python in `environments/python/python.exe`
2. Use embedded Python if available
3. Fall back to system Python if not found
4. Use path from `config.txt` as override

## Benefits

- **Self-contained**: No system Python required
- **Portable**: Copy entire folder to deploy
- **Consistent**: Same Python version everywhere
- **Fast startup**: No conda activation needed

## Distribution

When distributing the application:
1. Include this entire `python/` directory with all packages installed
2. Total size: ~420 MB
3. Users can run immediately without setup
4. No Python installation required on target machine

## Troubleshooting

### Issue: "No module named pip"
- Solution: Uncomment `import site` in the `._pth` file
- Re-run `get-pip.py`

### Issue: "Cannot import PySide6"
- Solution: Ensure dependencies are installed
- Run: `.\python.exe -m pip install -r ..\..\requirements.txt`

### Issue: DLL load failed
- Solution: Install Visual C++ Redistributable
- Download from Microsoft website

## Size Optimization

To reduce distribution size:
1. Remove unnecessary packages after installation
2. Use `pip install --no-cache-dir`
3. Delete `.pyc` files in `__pycache__` directories
4. Compress `Lib\site-packages\` if needed

## More Information

- Python Embeddable Package: https://docs.python.org/3/using/windows.html#embedded-distribution
- Integration Guide: `../../docs/setup/ENVIRONMENT_INTEGRATION.md`
