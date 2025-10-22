@echo off
REM ZULF-NMR Simulator Launcher
REM Reads configuration from config.txt and launches application

setlocal enabledelayedexpansion

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
