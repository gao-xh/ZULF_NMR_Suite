@echo off
REM ZULF-NMR Simulator Launcher
REM Reads configuration from config.txt and launches application
REM Auto-configures environment on first run
REM
REM Usage:
REM   start.bat           - Normal launch (auto-configure on first run)
REM   start.bat --setup   - Force reconfiguration of environment

setlocal enabledelayedexpansion

REM Check for --setup flag
if "%1"=="--setup" (
    echo ============================================================
    echo   MANUAL RECONFIGURATION REQUESTED
    echo ============================================================
    echo.
    echo Removing first-run marker and reconfiguring environment...
    if exist ".setup_complete" del ".setup_complete"
    echo.
)

REM ============================================================
REM First-Run Auto-Configuration
REM ============================================================

REM Check if this is the first run (marker file doesn't exist)
if not exist ".setup_complete" (
    echo ============================================================
    echo   FIRST RUN DETECTED - Auto-Configuration Starting
    echo ============================================================
    echo.
    echo This appears to be your first time running ZULF-NMR Suite.
    echo Setting up the environment automatically...
    echo.
    
    REM Step 1: Setup embedded Python
    echo [1/2] Configuring embedded Python environment...
    echo.
    if exist "environments\python\setup_embedded_python.bat" (
        set "CALLED_FROM_START=1"
        call environments\python\setup_embedded_python.bat
        set "EXIT_CODE=!ERRORLEVEL!"
        set "CALLED_FROM_START="
        
        if !EXIT_CODE! NEQ 0 (
            echo.
            echo ============================================================
            echo   ERROR: Python environment setup failed!
            echo ============================================================
            echo   Exit code: !EXIT_CODE!
            echo.
            echo Please run the setup script manually to see detailed errors:
            echo   environments\python\setup_embedded_python.bat
            echo.
            pause
            exit /b 1
        )
    ) else (
        echo WARNING: Python setup script not found!
        echo Expected: environments\python\setup_embedded_python.bat
        echo.
    )
    
    echo.
    echo [2/2] Configuring Spinach/MATLAB environment...
    echo.
    if exist "environments\spinach\setup_spinach.bat" (
        call environments\spinach\setup_spinach.bat
        if errorlevel 1 (
            echo.
            echo WARNING: Spinach/MATLAB setup failed or skipped.
            echo You can run this setup later if needed:
            echo   environments\spinach\setup_spinach.bat
            echo.
            echo Continuing with Python-only mode...
            echo.
        )
    ) else (
        echo WARNING: Spinach setup script not found!
        echo Expected: environments\spinach\setup_spinach.bat
        echo.
    )
    
    REM Create first-run completion marker
    echo. > .setup_complete
    echo ============================================================
    echo   First-Run Configuration Complete!
    echo ============================================================
    echo.
    echo Press any key to start the application...
    pause >nul
    echo.
)

echo ============================================================
echo.

REM Read APP_NAME from config.txt
for /f "usebackq tokens=1,* delims==" %%a in ("config.txt") do (
    set "key=%%a"
    set "value=%%b"
    set "key=!key: =!"
    set "value=!value: =!"
    if "!key!"=="APP_NAME" (
        for /f "tokens=* delims= " %%c in ("%%b") do set "APP_NAME=%%c"
    )
    if "!key!"=="APP_VERSION" (
        for /f "tokens=* delims= " %%c in ("%%b") do set "APP_VERSION=%%c"
    )
    if "!key!"=="PYTHON_ENV_PATH" (
        for /f "tokens=* delims= " %%c in ("%%b") do set "PYTHON_PATH=%%c"
    )
)

echo   !APP_NAME!
echo   Version !APP_VERSION!
echo.
echo ============================================================
echo.

REM Convert path format
set "PYTHON_PATH=!PYTHON_PATH:/=\!"

REM Check if Python path is relative (embedded environment)
echo !PYTHON_PATH! | findstr /C:":\" >nul
if errorlevel 1 (
    REM Relative path - convert to absolute
    set "PYTHON_PATH=%~dp0!PYTHON_PATH!"
)

REM Always check if embedded Python exists and prefer it
if exist "!PYTHON_PATH!" (
    echo Python Path: !PYTHON_PATH!
    echo Environment Type: Embedded Python
    echo.
) else (
    echo.
    echo ERROR: Embedded Python not found at: !PYTHON_PATH!
    echo Please ensure the embedded Python environment is properly installed.
    echo Expected path: environments\python\python.exe
    echo.
    pause
    exit /b 1
)

REM Clear Qt environment variables to avoid conflicts
set "QT_PLUGIN_PATH="
set "QT_QPA_PLATFORM_PLUGIN_PATH="
set "QML_IMPORT_PATH="
set "QML2_IMPORT_PATH="

REM Run the application
echo Starting application...
echo.

REM Use embedded pythonw.exe (GUI mode, no console)
set "PYTHON_DIR=!PYTHON_PATH:\python.exe=!"
set "PYTHONW_PATH=!PYTHON_DIR!\pythonw.exe"

if exist "!PYTHONW_PATH!" (
    echo Using pythonw.exe (GUI mode, no console window)
    start "" "!PYTHONW_PATH!" run.py
) else (
    echo pythonw.exe not found, using python.exe
    "!PYTHON_PATH!" run.py
)

REM Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo Application exited with errors
    pause
)

endlocal
