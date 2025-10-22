@echo off
REM Spinach Auto-Setup Script
REM Automatically detects MATLAB installation and configures Spinach toolbox
REM Author: Xuehan Gao, Ajoy Lab
REM Date: October 2025

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo   ZULF-NMR Suite - Spinach Toolbox Setup
echo   MATLAB Backend Configuration
echo ============================================================
echo.

set "ROOT_DIR=%~dp0..\.."
set "SPINACH_DIR=%ROOT_DIR%\environments\spinach"
set "CONFIG_FILE=%ROOT_DIR%\config.txt"

REM Step 1: Check if Spinach is already installed
echo Step 1/6: Checking Spinach installation...

if exist "%SPINACH_DIR%\kernel" (
    echo   Spinach found in:
    echo     %SPINACH_DIR%
    echo   [OK] Spinach toolbox detected
    echo.
    
    choice /C YN /M "  Reconfigure MATLAB settings"
    if errorlevel 2 (
        echo   Keeping existing configuration
        echo.
        goto :END
    )
    echo.
) else (
    echo   [WARNING] Spinach not found in environments/spinach/
    echo.
    echo   Spinach toolbox is required for MATLAB backend.
    echo   Please download Spinach from:
    echo     https://spindynamics.org/Spinach.php
    echo.
    echo   Then copy the Spinach folder to:
    echo     %SPINACH_DIR%
    echo.
    
    choice /C YN /M "  Do you have Spinach installed elsewhere"
    if errorlevel 2 (
        echo.
        echo   Alternative: Use Python backend instead (no MATLAB required)
        echo.
        goto :END
    )
    
    echo.
    set /p "SOURCE_PATH=  Enter Spinach installation path: "
    
    if exist "!SOURCE_PATH!" (
        echo   Copying Spinach...
        xcopy /E /I /Q "!SOURCE_PATH!" "%SPINACH_DIR%"
        echo   [OK] Spinach copied successfully
        echo.
    ) else (
        echo   [ERROR] Path not found: !SOURCE_PATH!
        echo.
        goto :ERROR
    )
)

REM Step 2: Detect MATLAB installation
REM Step 2: Detect MATLAB installation
echo Step 2/6: Detecting MATLAB installation...

set "MATLAB_COUNT=0"
set "MATLAB_SELECTED="

REM Check common installation paths
set "COMMON_PATHS=C:\Program Files\MATLAB;C:\Program Files (x86)\MATLAB;D:\MATLAB;E:\MATLAB;C:\MATLAB"

for %%P in (%COMMON_PATHS%) do (
    if exist "%%P" (
        for /d %%V in ("%%P\*") do (
            if exist "%%V\bin\matlab.exe" (
                set /a MATLAB_COUNT+=1
                set "MATLAB_!MATLAB_COUNT!_VERSION=%%~nxV"
                set "MATLAB_!MATLAB_COUNT!_PATH=%%V"
                set "MATLAB_!MATLAB_COUNT!_EXE=%%V\bin\matlab.exe"
                echo   Found: %%~nxV at %%V
            )
        )
    )
)

REM Check registry
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\MathWorks\MATLAB" 2^>nul') do (
    set "REG_VERSION=%%a"
    for /f "skip=2 tokens=2*" %%c in ('reg query "HKLM\SOFTWARE\MathWorks\MATLAB\!REG_VERSION!" /v MATLABROOT 2^>nul') do (
        set "REG_PATH=%%d"
        if exist "!REG_PATH!\bin\matlab.exe" (
            REM Check if not already found
            set "FOUND=0"
            for /l %%i in (1,1,!MATLAB_COUNT!) do (
                if "!MATLAB_%%i_PATH!"=="!REG_PATH!" set "FOUND=1"
            )
            if !FOUND!==0 (
                set /a MATLAB_COUNT+=1
                set "MATLAB_!MATLAB_COUNT!_VERSION=!REG_VERSION!"
                set "MATLAB_!MATLAB_COUNT!_PATH=!REG_PATH!"
                set "MATLAB_!MATLAB_COUNT!_EXE=!REG_PATH!\bin\matlab.exe"
                echo   Found: !REG_VERSION! at !REG_PATH!
            )
        )
    )
)

if !MATLAB_COUNT!==0 (
    echo   [WARNING] No MATLAB installation found automatically
    echo.
    echo   Would you like to:
    echo     1. Manually enter MATLAB installation path
    echo     2. Exit and install MATLAB
    echo     3. Use Python backend instead
    echo.
    
    choice /C 123 /M "  Select option"
    
    if errorlevel 3 (
        echo.
        echo   You can use Python backend instead (no MATLAB required)
        echo.
        goto :END
    )
    
    if errorlevel 2 (
        echo.
        echo   Please install MATLAB R2021b or later, then run this script again.
        echo.
        goto :END
    )
    
    REM Option 1: Manual input
    echo.
    set /p "MANUAL_PATH=  Enter MATLAB installation path (e.g., C:\Program Files\MATLAB\R2023b): "
    
    if exist "!MANUAL_PATH!\bin\matlab.exe" (
        set /a MATLAB_COUNT=1
        for %%F in ("!MANUAL_PATH!") do set "MATLAB_1_VERSION=%%~nxF"
        set "MATLAB_1_PATH=!MANUAL_PATH!"
        set "MATLAB_1_EXE=!MANUAL_PATH!\bin\matlab.exe"
        echo   [OK] MATLAB found at: !MANUAL_PATH!
        echo.
    ) else (
        if exist "!MANUAL_PATH!" (
            echo   [ERROR] matlab.exe not found in: !MANUAL_PATH!\bin\
        ) else (
            echo   [ERROR] Path not found: !MANUAL_PATH!
        )
        echo.
        goto :ERROR
    )
)

if !MATLAB_COUNT! GTR 0 (
    echo   [OK] Found !MATLAB_COUNT! MATLAB installation(s)
    echo.
    
    for /l %%i in (1,1,!MATLAB_COUNT!) do (
        echo     [%%i] !MATLAB_%%i_VERSION!
        echo         !MATLAB_%%i_PATH!
    )
    
    echo.
)

REM Continue only if we have MATLAB
if !MATLAB_COUNT!==0 goto :ERROR

REM Step 3: Select MATLAB version
REM Step 3: Select MATLAB version
echo Step 3/6: Selecting MATLAB version...

if !MATLAB_COUNT!==1 (
    set "SELECTED_IDX=1"
    echo   Auto-selected: !MATLAB_1_VERSION!
    echo   [OK] MATLAB selected
) else (
    set /p "SELECTED_IDX=  Select MATLAB version (1-%MATLAB_COUNT%): "
    
    if !SELECTED_IDX! LSS 1 (
        echo   [ERROR] Invalid selection
        goto :ERROR
    )
    if !SELECTED_IDX! GTR !MATLAB_COUNT! (
        echo   [ERROR] Invalid selection
        goto :ERROR
    )
    
    call :GetMatlabVar !SELECTED_IDX!
    echo   Selected: !MATLAB_VERSION!
    echo   [OK] MATLAB selected
)

call :GetMatlabVar !SELECTED_IDX!

echo.

REM Step 4: Configure startup script
REM Step 4: Configure MATLAB startup script
echo Step 4/6: Configuring MATLAB startup script...

set "STARTUP_FILE=%ROOT_DIR%\matlab_startup.m"
set "SPINACH_PATH_MATLAB=%SPINACH_DIR:\=\\%"

(
echo %% ZULF-NMR Suite - MATLAB Startup Script
echo %% Auto-generated by Spinach Auto-Setup
echo.
echo %% Add Spinach to MATLAB path
echo spinachPath = '%SPINACH_PATH_MATLAB%';
echo.
echo if exist^(spinachPath, 'dir'^)
echo     addpath^(genpath^(spinachPath^)^);
echo     fprintf^('[OK] Spinach loaded from: %%s\n', spinachPath^);
echo else
echo     warning^('Spinach directory not found: %%s', spinachPath^);
echo end
echo.
echo %% Set default number format
echo format long
echo.
echo %% Display welcome message
echo fprintf^('\n'^);
echo fprintf^('====================================\n'^);
echo fprintf^('  ZULF-NMR Suite v0.1.0\n'^);
echo fprintf^('  MATLAB Backend Ready\n'^);
echo fprintf^('====================================\n'^);
echo fprintf^('\n'^);
) > "%STARTUP_FILE%"

echo   Created: matlab_startup.m
echo   [OK] Startup script configured
echo.

REM Step 5: Install MATLAB Engine for Python
echo Step 5/6: Installing MATLAB Engine for Python...

set "PYTHON_EXE=%ROOT_DIR%\environments\python\python.exe"
if exist "%PYTHON_EXE%" (
    echo   Python found: %PYTHON_EXE%
    echo   Installing matlabengine package...
    
    "%PYTHON_EXE%" -m pip install matlabengine==25.1.2 --quiet --no-warn-script-location 2>nul
    
    if !errorlevel!==0 (
        echo   [OK] MATLAB Engine for Python installed successfully
    ) else (
        echo   [WARNING] Failed to install MATLAB Engine
        echo   This is optional - you can still use MATLAB via subprocess
    )
) else (
    echo   [WARNING] Python not found at: %PYTHON_EXE%
    echo   Please run setup_embedded_python first
)
echo.

REM Step 6: Update config.txt
echo Step 6/6: Updating configuration...

if exist "%CONFIG_FILE%" (
    set "TEMP_CONFIG=%TEMP%\config_temp.txt"
    set "MATLAB_UPDATED=0"
    set "SPINACH_UPDATED=0"
    
    REM Read and update config
    (for /f "usebackq delims=" %%L in ("%CONFIG_FILE%") do (
        set "LINE=%%L"
        echo !LINE! | findstr /B /C:"MATLAB_PATH" >nul
        if !errorlevel!==0 (
            echo MATLAB_PATH = %MATLAB_PATH:/=\%
            set "MATLAB_UPDATED=1"
        ) else (
            echo !LINE! | findstr /B /C:"SPINACH_PATH" >nul
            if !errorlevel!==0 (
                echo SPINACH_PATH = %SPINACH_DIR:/=\%
                set "SPINACH_UPDATED=1"
            ) else (
                echo !LINE!
            )
        )
    )) > "%TEMP_CONFIG%"
    
    REM Append if not found
    if !MATLAB_UPDATED!==0 (
        echo. >> "%TEMP_CONFIG%"
        echo # MATLAB Configuration (auto-detected) >> "%TEMP_CONFIG%"
        echo MATLAB_PATH = %MATLAB_PATH:/=\% >> "%TEMP_CONFIG%"
    )
    
    if !SPINACH_UPDATED!==0 (
        echo SPINACH_PATH = %SPINACH_DIR:/=\% >> "%TEMP_CONFIG%"
    )
    
    move /y "%TEMP_CONFIG%" "%CONFIG_FILE%" >nul
    
    echo   Updated config.txt:
    echo     MATLAB_PATH = %MATLAB_PATH%
    echo     SPINACH_PATH = %SPINACH_DIR%
    echo   [OK] Configuration updated
) else (
    echo   [WARNING] config.txt not found
)

echo.

REM Optional: Test MATLAB connection
echo Optional: Test MATLAB connection...
choice /C YN /M "  Launch MATLAB to verify configuration"

if not errorlevel 2 (
    echo   Starting MATLAB (this may take a minute)...
    echo.
    
    set "TEST_FILE=%TEMP%\zulf_matlab_test.m"
    
    (
    echo try
    echo     %% Test Spinach
    echo     if exist^('spinach_version', 'file'^)
    echo         ver = spinach_version^(^);
    echo         fprintf^('[OK] Spinach loaded successfully\n'^);
    echo         fprintf^('  Version: %%s\n', ver^);
    echo     else
    echo         warning^('Spinach not loaded correctly'^);
    echo     end
    echo catch e
    echo     warning^('Error testing Spinach: %%s', e.message^);
    echo end
    echo.
    echo fprintf^('\nPress any key to exit...\n'^);
    echo pause;
    echo exit;
    ) > "!TEST_FILE!"
    
    start "" "!MATLAB_EXE!" -r "run('%STARTUP_FILE:\=\\%'); run('!TEST_FILE:\=\\!')"
    
    timeout /t 2 >nul
    del "!TEST_FILE!" 2>nul
)

REM Summary
echo.
echo ============================================================
echo   Spinach Setup Complete!
echo ============================================================
echo.
echo Configuration summary:
echo   MATLAB Version: !MATLAB_VERSION!
echo   MATLAB Path:    !MATLAB_PATH!
echo   Spinach Path:   %SPINACH_DIR%
echo   Startup Script: matlab_startup.m
echo.
echo Next steps:
echo   1. Launch the suite:
echo      start.bat  (or)  start.ps1
echo   2. Select 'MATLAB' backend in startup dialog
echo   3. Start your ZULF-NMR simulations!
echo.
goto :END

:GetMatlabVar
set "MATLAB_VERSION=!MATLAB_%1_VERSION!"
set "MATLAB_PATH=!MATLAB_%1_PATH!"
set "MATLAB_EXE=!MATLAB_%1_EXE!"
goto :EOF

:ERROR
echo.
echo ============================================================
echo   Setup Failed!
echo ============================================================
echo.
echo Please check the error messages above.
echo.
pause
exit /b 1

:END
echo Press any key to exit...
pause >nul
exit /b 0
