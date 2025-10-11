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
if !errorlevel! NEQ 0 (
    REM Relative path - convert to absolute
    set "PYTHON_PATH=%~dp0!PYTHON_PATH!"
)

REM Always check if embedded Python exists and prefer it
if exist "!PYTHON_PATH!" (
    echo Python Path: !PYTHON_PATH!
    echo Environment Type: Embedded/Local Python
    echo.
    set "USE_DIRECT_PATH=1"
    set "USE_EMBEDDED=1"
) else (
    REM Embedded Python not found, check if this is a conda environment
    echo !PYTHON_PATH! | findstr /C:"anaconda" /C:"conda" /C:"miniconda" >nul
    if !errorlevel!==0 (
        REM Extract conda environment name
        for %%i in ("!PYTHON_PATH!") do set "ENV_DIR=%%~dpi"
        set "ENV_DIR=!ENV_DIR:~0,-1!"
        for %%i in ("!ENV_DIR!") do set "ENV_NAME=%%~nxi"
        
        echo Python Environment: !ENV_NAME! (conda)
        echo.
        echo Activating conda environment...
        
        call D:\anaconda3\Scripts\activate.bat !ENV_NAME!
        
        if !errorlevel! NEQ 0 (
            echo.
            echo ERROR: Failed to activate conda environment: !ENV_NAME!
            echo Trying direct Python path instead...
            set "USE_DIRECT_PATH=1"
        ) else (
            echo Environment activated successfully
            echo.
            set "USE_DIRECT_PATH=0"
        )
        set "USE_EMBEDDED=0"
    ) else (
        REM Not a conda environment, use direct Python path
        echo Python Path: !PYTHON_PATH!
        echo Environment Type: venv/system Python
        echo.
        set "USE_DIRECT_PATH=1"
        set "USE_EMBEDDED=0"
    )
)

REM Clear Qt environment variables to avoid conflicts
set "QT_PLUGIN_PATH="
set "QT_QPA_PLATFORM_PLUGIN_PATH="
set "QML_IMPORT_PATH="
set "QML2_IMPORT_PATH="

REM Run the application
echo Starting application...
echo.

if "!USE_DIRECT_PATH!"=="1" (
    REM Use direct Python path
    REM Try pythonw.exe first (GUI mode, no console), fallback to python.exe
    set "PYTHON_DIR=!PYTHON_PATH:\python.exe=!"
    set "PYTHONW_PATH=!PYTHON_DIR!\pythonw.exe"
    
    if exist "!PYTHONW_PATH!" (
        echo Using pythonw.exe (GUI mode, no console window)
        start "" "!PYTHONW_PATH!" run.py
    ) else (
        echo pythonw.exe not found, using python.exe
        "!PYTHON_PATH!" run.py
    )
) else (
    REM Use activated environment
    REM Try to find pythonw.exe in the activated environment
    where pythonw.exe >nul 2>&1
    if !errorlevel!==0 (
        echo Using pythonw.exe (GUI mode, no console window)
        start "" pythonw.exe run.py
    ) else (
        echo pythonw.exe not found, using python.exe
        python run.py
    )
)

REM Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo Application exited with errors
    pause
)

endlocal
