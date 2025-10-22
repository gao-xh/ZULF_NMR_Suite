@echo off
REM Setup Embedded Python Environment
REM This script downloads and configures embedded Python 3.12.7 in environments/python/
REM Author: Xuehan Gao, Ajoy Lab
REM Date: October 2025

setlocal enabledelayedexpansion

REM Configuration
set "EMBED_DIR=%~dp0"
set "PYTHON_VERSION=3.12.7"
set "DOWNLOAD_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "ZIP_FILE=%EMBED_DIR%python-embed.zip"
set "PYTHON_EXE=%EMBED_DIR%python.exe"
set "REQUIREMENTS_FILE=%EMBED_DIR%..\..\requirements.txt"

REM Colors (not natively supported, but we can use echo styling)
echo.
echo ============================================================
echo   ZULF-NMR Suite - Embedded Python Setup
echo   Python Version: %PYTHON_VERSION%
echo ============================================================
echo.

REM Check if already installed
if exist "%PYTHON_EXE%" (
    echo Python is already installed at:
    echo   %EMBED_DIR%
    echo.
    echo Current version:
    "%PYTHON_EXE%" --version
    echo.
    
    choice /C YN /M "Do you want to reinstall"
    if errorlevel 2 (
        echo.
        echo Setup cancelled. Existing installation preserved.
        echo.
        goto :END
    )
    
    echo.
    echo Removing existing installation...
    for /d %%D in ("%EMBED_DIR%*") do (
        if /i not "%%~nxD"=="python" rd /s /q "%%D" 2>nul
    )
    for %%F in ("%EMBED_DIR%*") do (
        if /i not "%%~xF"==".ps1" if /i not "%%~xF"==".bat" del /q "%%F" 2>nul
    )
    echo.
)

REM Step 1: Download
echo Step 1/5: Downloading embedded Python...
echo   URL: %DOWNLOAD_URL%
echo.

powershell -NoProfile -Command "& {$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' -UseBasicParsing}"

if not exist "%ZIP_FILE%" (
    echo   [ERROR] Download failed!
    echo.
    goto :ERROR
)

for %%F in ("%ZIP_FILE%") do set "FILE_SIZE=%%~zF"
set /a FILE_SIZE_MB=!FILE_SIZE! / 1048576
echo   Downloaded: !FILE_SIZE_MB! MB
echo   [OK] Download complete
echo.

REM Step 2: Extract
echo Step 2/5: Extracting Python archive...

powershell -NoProfile -Command "& {Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EMBED_DIR%' -Force}"
del /q "%ZIP_FILE%" 2>nul

if not exist "%PYTHON_EXE%" (
    echo   [ERROR] python.exe not found after extraction
    echo.
    goto :ERROR
)

echo   [OK] Extraction complete
echo.

REM Step 3: Configure
echo Step 3/5: Configuring Python environment...

set "PTH_FOUND=0"
for %%F in ("%EMBED_DIR%python3*._pth") do (
    set "PTH_FOUND=1"
    powershell -NoProfile -Command "& {(Get-Content '%%F') -replace '#import site', 'import site' | Set-Content '%%F'}"
    echo   Enabled site packages: %%~nxF
)

if !PTH_FOUND!==0 (
    echo   [WARNING] No ._pth file found
) else (
    echo   [OK] Configuration complete
)
echo.

REM Step 4: Install pip
echo Step 4/5: Installing pip...

set "GET_PIP=%EMBED_DIR%get-pip.py"
powershell -NoProfile -Command "& {$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%GET_PIP%' -UseBasicParsing}"

if not exist "%GET_PIP%" (
    echo   [ERROR] Failed to download get-pip.py
    echo.
    goto :ERROR
)

echo   Running pip installer...
"%PYTHON_EXE%" "%GET_PIP%" --quiet --no-warn-script-location
del /q "%GET_PIP%" 2>nul

REM Ensure setuptools and wheel are installed first
echo   Installing build tools (setuptools, wheel)...
"%PYTHON_EXE%" -m pip install --upgrade setuptools wheel --quiet --no-warn-script-location

if errorlevel 1 (
    echo   [WARNING] Failed to upgrade build tools, but continuing...
)

echo   [OK] pip installation complete
echo.

REM Step 5: Install dependencies
echo Step 5/5: Installing dependencies...

if exist "%REQUIREMENTS_FILE%" (
    echo   Installing from requirements.txt...
    echo   This may take several minutes, please wait...
    echo.
    
    "%PYTHON_EXE%" -m pip install -r "%REQUIREMENTS_FILE%" --quiet --no-warn-script-location
    
    if errorlevel 1 (
        echo   [ERROR] Full requirements.txt installation failed
        echo.
        echo   This may be due to:
        echo     - Network connection issues
        echo     - Package compatibility problems
        echo     - Missing build dependencies
        echo.
        echo   Attempting to install core packages only...
        echo.
        goto :INSTALL_CORE
    )
    
    echo   [OK] All dependencies installed successfully
    echo.
    
    echo   Installed packages:
    "%PYTHON_EXE%" -m pip list --format=columns > "%TEMP%\pip_list.txt"
    for /f "skip=2 tokens=*" %%L in ('type "%TEMP%\pip_list.txt" ^| more /e +0') do (
        set /a COUNT+=1
        if !COUNT! LEQ 10 echo     %%L
    )
    del "%TEMP%\pip_list.txt" 2>nul
    echo.
    goto :SUCCESS
)

:INSTALL_CORE
echo   [WARNING] requirements.txt not found or installation failed
echo   Installing essential packages manually...
echo.

REM Essential packages for ZULF-NMR Suite
set "PKG_COUNT=0"
set "SUCCESS_COUNT=0"
    
    echo     Installing PySide6==6.7.3...
    "%PYTHON_EXE%" -m pip install PySide6==6.7.3 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing PySide6-Addons==6.7.3...
    "%PYTHON_EXE%" -m pip install PySide6-Addons==6.7.3 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing PySide6-Essentials==6.7.3...
    "%PYTHON_EXE%" -m pip install PySide6-Essentials==6.7.3 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing numpy==2.3.3...
    "%PYTHON_EXE%" -m pip install numpy==2.3.3 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing scipy==1.16.2...
    "%PYTHON_EXE%" -m pip install scipy==1.16.2 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing matplotlib==3.10.0...
    "%PYTHON_EXE%" -m pip install matplotlib==3.10.0 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pandas==2.3.1...
    "%PYTHON_EXE%" -m pip install pandas==2.3.1 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pillow==11.3.0...
    "%PYTHON_EXE%" -m pip install pillow==11.3.0 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing matlabengine==25.1.2...
    "%PYTHON_EXE%" -m pip install matlabengine==25.1.2 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing requests==2.32.4...
    "%PYTHON_EXE%" -m pip install requests==2.32.4 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pyyaml==6.0.2...
    "%PYTHON_EXE%" -m pip install pyyaml==6.0.2 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing colorama==0.4.6...
    "%PYTHON_EXE%" -m pip install colorama==0.4.6 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing tqdm==4.67.1...
    "%PYTHON_EXE%" -m pip install tqdm==4.67.1 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing psutil==5.9.0...
    "%PYTHON_EXE%" -m pip install psutil==5.9.0 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pywin32==311...
    "%PYTHON_EXE%" -m pip install pywin32==311 --quiet --no-warn-script-location && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo.
    echo   Installed !SUCCESS_COUNT!/!PKG_COUNT! packages successfully
    if !SUCCESS_COUNT! LSS 5 (
        echo   [WARNING] Only !SUCCESS_COUNT! packages installed successfully
        echo   Some features may not work correctly
    ) else (
        echo   [OK] Essential packages installation complete
    )
    echo.

:SUCCESS
REM Success summary
echo.
echo ============================================================
echo   Installation Complete!
echo ============================================================
echo.
echo Installation directory:
echo   %EMBED_DIR%
echo.
echo Python version:
"%PYTHON_EXE%" --version
echo.
echo Quick test:
echo   %PYTHON_EXE% --version
echo   %PYTHON_EXE% -c "import PySide6; print('PySide6 OK')"
echo.
echo To use this environment:
echo   1. Update config.txt:
echo      PYTHON_ENV_PATH = environments/python/python.exe
echo   2. Run start.bat or start.ps1
echo.
goto :END

:ERROR
echo.
echo ============================================================
echo   Installation Failed!
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
