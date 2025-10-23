@echo off
REM Manual Python Setup (No Download - For Antivirus Issues)
REM Use this if antivirus blocks setup_embedded_python.bat
REM Author: Xuehan Gao, Ajoy Lab
REM Date: October 2025

echo.
echo ============================================================
echo   ZULF-NMR Suite - Manual Python Setup
echo   (Antivirus-Friendly Version - No Automatic Download)
echo ============================================================
echo.

set "EMBED_DIR=%~dp0"
set "PYTHON_VERSION=3.12.7"
set "PYTHON_EXE=%EMBED_DIR%python.exe"
set "REQUIREMENTS_FILE=%EMBED_DIR%..\..\requirements.txt"

REM Check if Python is already installed
if exist "%PYTHON_EXE%" (
    echo Python is already installed!
    echo.
    echo Location: %EMBED_DIR%
    "%PYTHON_EXE%" --version
    echo.
    goto :INSTALL_PACKAGES
)

echo.
echo ============================================================
echo   STEP 1: Manual Download Required
echo ============================================================
echo.
echo Python not found. Please download manually:
echo.
echo 1. Open your browser (Edge/Chrome/Firefox)
echo.
echo 2. Go to one of these URLs:
echo    - Official: https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
echo    - Mirror:   https://registry.npmmirror.com/-/binary/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
echo.
echo 3. Save the file to your Downloads folder
echo.
echo 4. Extract the ZIP file to this folder:
echo    %EMBED_DIR%
echo.
echo 5. Make sure you see python.exe in this folder
echo.
echo 6. Re-run this script
echo.
echo ============================================================
echo.
pause
exit /b 1

:INSTALL_PACKAGES
echo.
echo ============================================================
echo   STEP 2: Configure Python Environment
echo ============================================================
echo.

REM Enable site packages
set "PTH_FOUND=0"
for %%F in ("%EMBED_DIR%python3*._pth") do (
    set "PTH_FOUND=1"
    findstr /C:"import site" "%%F" >nul
    if errorlevel 1 (
        echo import site>> "%%F"
        echo   Enabled site packages: %%~nxF
    ) else (
        echo   Site packages already enabled: %%~nxF
    )
)

if !PTH_FOUND!==0 (
    echo   [WARNING] No ._pth file found
)
echo.

REM Install pip if not present
echo Checking pip...
"%PYTHON_EXE%" -m pip --version >nul 2>&1
if errorlevel 1 (
    echo   Installing pip...
    echo.
    
    REM Download get-pip.py
    echo   Downloading get-pip.py...
    curl -o "%EMBED_DIR%get-pip.py" https://bootstrap.pypa.io/get-pip.py
    
    if not exist "%EMBED_DIR%get-pip.py" (
        echo   [ERROR] Failed to download get-pip.py
        echo   Please download manually from: https://bootstrap.pypa.io/get-pip.py
        echo   Save to: %EMBED_DIR%get-pip.py
        echo   Then re-run this script
        pause
        exit /b 1
    )
    
    "%PYTHON_EXE%" "%EMBED_DIR%get-pip.py"
    del /q "%EMBED_DIR%get-pip.py"
    echo.
)

echo   [OK] pip is ready
echo.

REM Install setuptools and wheel
echo Installing build tools (setuptools, wheel)...
echo.
"%PYTHON_EXE%" -m pip install --upgrade setuptools wheel
echo.

REM Install packages
echo.
echo ============================================================
echo   STEP 3: Installing Python Packages
echo ============================================================
echo.

if exist "%REQUIREMENTS_FILE%" (
    echo Installing from requirements.txt...
    echo This may take several minutes...
    echo.
    
    "%PYTHON_EXE%" -m pip install -r "%REQUIREMENTS_FILE%"
    
    if errorlevel 1 (
        echo.
        echo [WARNING] Some packages failed to install
        echo Installing core packages only...
        echo.
        goto :INSTALL_CORE
    )
    
    echo.
    echo [OK] All packages installed successfully
    goto :SUCCESS
)

:INSTALL_CORE
echo Installing essential packages...
echo.

"%PYTHON_EXE%" -m pip install PySide6==6.7.3
"%PYTHON_EXE%" -m pip install numpy scipy matplotlib pandas
"%PYTHON_EXE%" -m pip install pillow requests pyyaml colorama tqdm pywin32

echo.
echo [OK] Core packages installed
echo.

:SUCCESS
echo.
echo ============================================================
echo   Installation Complete!
echo ============================================================
echo.
echo Python location: %EMBED_DIR%
echo.
echo Installed packages:
"%PYTHON_EXE%" -m pip list
echo.
echo Next steps:
echo   1. Update config.txt:
echo      PYTHON_ENV_PATH = environments/python/python.exe
echo   2. Run start.bat or start.ps1
echo.
pause
exit /b 0
