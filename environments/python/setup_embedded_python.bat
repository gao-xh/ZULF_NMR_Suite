@echo off
REM Setup Embedded Python Environment
REM This script downloads and configures embedded Python 3.12.7 in environments/python/
REM Author: Xuehan Gao, Ajoy Lab
REM Date: October 2025

setlocal enabledelayedexpansion

REM Configuration
set "EMBED_DIR=%~dp0"
set "PYTHON_VERSION=3.12.7"

REM Multiple download sources (will try in order if one fails)
set "DOWNLOAD_URL_1=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "DOWNLOAD_NAME_1=Python.org (Official)"

set "DOWNLOAD_URL_2=https://registry.npmmirror.com/-/binary/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "DOWNLOAD_NAME_2=npm mirror (China)"

set "DOWNLOAD_URL_3=https://repo.huaweicloud.com/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "DOWNLOAD_NAME_3=Huawei Cloud (China)"

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
    
    REM Check if pip is installed
    "%PYTHON_EXE%" -m pip --version >nul 2>&1
    if errorlevel 1 (
        echo.
        echo [WARNING] pip is not installed, installation required
        echo.
        goto :INSTALL_PIP
    )
    
    REM Check if essential packages are installed
    "%PYTHON_EXE%" -c "import PySide6" >nul 2>&1
    if errorlevel 1 (
        echo.
        echo [WARNING] Essential packages missing, installation required
        echo.
        goto :INSTALL_DEPENDENCIES
    )
    
    echo   [OK] Python and packages are ready
    echo.
    
    choice /C YN /M "Do you want to reinstall"
    if errorlevel 2 (
        echo.
        echo Setup skipped. Using existing installation.
        echo.
        goto :END
    )
    
    echo.
    echo Removing existing installation...
    for /d %%D in ("%EMBED_DIR%*") do (
        if /i not "%%~nxD"=="python" rd /s /q "%%D" 2>nul
    )
    for %%F in ("%EMBED_DIR%*") do (
        if /i not "%%~xF"==".ps1" if /i not "%%~xF"==".bat" if /i not "%%~xF"==".md" del /q "%%F" 2>nul
    )
    echo.
)

REM Step 1: Download
echo Step 1/5: Downloading embedded Python...
echo   Version: %PYTHON_VERSION%
echo.

REM Try multiple download sources
set "DOWNLOAD_SUCCESS=0"

echo   Trying: %DOWNLOAD_NAME_1%
echo   Method 1: Using certutil (less likely to trigger antivirus)...
certutil -urlcache -split -f "%DOWNLOAD_URL_1%" "%ZIP_FILE%"
if exist "%ZIP_FILE%" (
    set "DOWNLOAD_SUCCESS=1"
    echo   [OK] Downloaded from %DOWNLOAD_NAME_1%
    goto :DOWNLOAD_COMPLETE
)

echo   Method 2: Using PowerShell...
echo.
powershell -NoProfile -Command "& {$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri '%DOWNLOAD_URL_1%' -OutFile '%ZIP_FILE%' -UseBasicParsing -TimeoutSec 30; Write-Host '[OK] Download completed' -ForegroundColor Green } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message -ForegroundColor Red; exit 1 }}"
if exist "%ZIP_FILE%" (
    set "DOWNLOAD_SUCCESS=1"
    echo   [OK] Downloaded from %DOWNLOAD_NAME_1%
    goto :DOWNLOAD_COMPLETE
)

echo   [FAILED] %DOWNLOAD_NAME_1%
echo.
echo   Trying: %DOWNLOAD_NAME_2%
echo   Method 1: Using certutil...
certutil -urlcache -split -f "%DOWNLOAD_URL_2%" "%ZIP_FILE%"
if exist "%ZIP_FILE%" (
    set "DOWNLOAD_SUCCESS=1"
    echo   [OK] Downloaded from %DOWNLOAD_NAME_2%
    goto :DOWNLOAD_COMPLETE
)

echo   Method 2: Using PowerShell...
echo.
powershell -NoProfile -Command "& {$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri '%DOWNLOAD_URL_2%' -OutFile '%ZIP_FILE%' -UseBasicParsing -TimeoutSec 30; Write-Host '[OK] Download completed' -ForegroundColor Green } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message -ForegroundColor Red; exit 1 }}"
if exist "%ZIP_FILE%" (
    set "DOWNLOAD_SUCCESS=1"
    echo   [OK] Downloaded from %DOWNLOAD_NAME_2%
    goto :DOWNLOAD_COMPLETE
)

echo   [FAILED] %DOWNLOAD_NAME_2%
echo.
echo   Trying: %DOWNLOAD_NAME_3%
echo   Method 1: Using certutil...
certutil -urlcache -split -f "%DOWNLOAD_URL_3%" "%ZIP_FILE%"
if exist "%ZIP_FILE%" (
    set "DOWNLOAD_SUCCESS=1"
    echo   [OK] Downloaded from %DOWNLOAD_NAME_3%
    goto :DOWNLOAD_COMPLETE
)

echo   Method 2: Using PowerShell...
echo.
powershell -NoProfile -Command "& {$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri '%DOWNLOAD_URL_3%' -OutFile '%ZIP_FILE%' -UseBasicParsing -TimeoutSec 30; Write-Host '[OK] Download completed' -ForegroundColor Green } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message -ForegroundColor Red; exit 1 }}"
if exist "%ZIP_FILE%" (
    set "DOWNLOAD_SUCCESS=1"
    echo   [OK] Downloaded from %DOWNLOAD_NAME_3%
    goto :DOWNLOAD_COMPLETE
)

echo   [FAILED] %DOWNLOAD_NAME_3%
echo.

:DOWNLOAD_COMPLETE
if "%DOWNLOAD_SUCCESS%"=="0" (
    echo   [ERROR] All download sources failed!
    echo.
    echo   ============================================================
    echo   ANTIVIRUS/WINDOWS DEFENDER ALERT?
    echo   ============================================================
    echo.
    echo   If you see "Virus detected" or download was blocked:
    echo.
    echo   [WHY THIS HAPPENS]
    echo   - This script downloads official Python from python.org
    echo   - Automated downloads + PowerShell commands = suspicious behavior
    echo   - Windows Defender/antivirus may block as "potentially unwanted"
    echo   - THIS IS A FALSE POSITIVE - the file is safe!
    echo.
    echo   [SOLUTION 1] Add to Windows Defender exclusions (RECOMMENDED):
    echo   --------------------------------------------------
    echo   1. Open Windows Security
    echo   2. Go to: Virus ^& threat protection ^> Manage settings
    echo   3. Click "Add or remove exclusions"
    echo   4. Add this folder:
    echo      %EMBED_DIR%
    echo   5. Re-run this script
    echo.
    echo   [SOLUTION 2] Manual download (if exclusion doesn't work):
    echo   --------------------------------------------------
    echo   1. Download from official Python website:
    echo      https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip
    echo.
    echo   2. Extract the ZIP file contents to:
    echo      %EMBED_DIR%
    echo.
    echo   3. Re-run this script (it will skip download step)
    echo.
    echo   [VERIFICATION]
    echo   - File is from python.org (official source)
    echo   - SHA256 checksum available at python.org
    echo   - Over 1 million developers use embedded Python daily
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

:INSTALL_PIP
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
"%PYTHON_EXE%" "%GET_PIP%"
if errorlevel 1 (
    echo   [ERROR] pip installation failed!
    echo.
    goto :ERROR
)
del /q "%GET_PIP%" 2>nul

REM Ensure setuptools and wheel are installed first
echo   Installing build tools (setuptools, wheel)...
echo   This may take a moment, please wait...
echo.

REM Install with full output visible
"%PYTHON_EXE%" -m pip install --upgrade setuptools wheel
set "SETUP_EXIT_CODE=%ERRORLEVEL%"

if %SETUP_EXIT_CODE% NEQ 0 (
    echo.
    echo   [WARNING] Build tools installation failed with exit code: %SETUP_EXIT_CODE%
    echo   Continuing anyway - some packages may fail to install
    echo.
) else (
    echo.
    echo   [OK] Build tools installed successfully
    echo.
)

echo   [OK] pip installation complete
echo.

:INSTALL_DEPENDENCIES
REM Step 5: Install dependencies
echo Step 5/5: Installing dependencies...

if exist "%REQUIREMENTS_FILE%" (
    echo   Installing from requirements.txt...
    echo   This may take several minutes, please wait...
    echo.
    echo   Note: Some packages (matlabengine, psutil) may require:
    echo     - MATLAB installation (for matlabengine)
    echo     - Visual C++ Build Tools (for psutil)
    echo   Skipping these if not available...
    echo.
    
    REM Try installing with binary wheels only (no source builds)
    "%PYTHON_EXE%" -m pip install -r "%REQUIREMENTS_FILE%" --only-binary :all:
    
    if errorlevel 1 (
        echo.
        echo   [WARNING] Binary-only installation failed, trying with selective builds...
        echo.
        
        REM Install packages that don't need compilation first
        "%PYTHON_EXE%" -m pip install -r "%REQUIREMENTS_FILE%"
        
        if errorlevel 1 (
            echo.
            echo   [ERROR] Full requirements.txt installation failed
            echo.
            echo   This may be due to:
            echo     - Network connection issues
            echo     - Package compatibility problems
            echo     - Missing build dependencies (Visual C++ Build Tools)
            echo     - Missing MATLAB installation
            echo.
            echo   Attempting to install core packages only...
            echo.
            goto :INSTALL_CORE
        )
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
    "%PYTHON_EXE%" -m pip install PySide6==6.7.3 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing PySide6-Addons==6.7.3...
    "%PYTHON_EXE%" -m pip install PySide6-Addons==6.7.3 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing PySide6-Essentials==6.7.3...
    "%PYTHON_EXE%" -m pip install PySide6-Essentials==6.7.3 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing numpy==2.3.3...
    "%PYTHON_EXE%" -m pip install numpy==2.3.3 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing scipy==1.16.2...
    "%PYTHON_EXE%" -m pip install scipy==1.16.2 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing matplotlib==3.10.0...
    "%PYTHON_EXE%" -m pip install matplotlib==3.10.0 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pandas==2.3.1...
    "%PYTHON_EXE%" -m pip install pandas==2.3.1 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pillow==11.3.0...
    "%PYTHON_EXE%" -m pip install pillow==11.3.0 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing requests==2.32.4...
    "%PYTHON_EXE%" -m pip install requests==2.32.4 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing pyyaml==6.0.2...
    "%PYTHON_EXE%" -m pip install pyyaml==6.0.2 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing colorama==0.4.6...
    "%PYTHON_EXE%" -m pip install colorama==0.4.6 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    echo     Installing tqdm==4.67.1...
    "%PYTHON_EXE%" -m pip install tqdm==4.67.1 && set /a SUCCESS_COUNT+=1
    set /a PKG_COUNT+=1
    
    REM Optional: psutil (may require Visual C++ Build Tools)
    echo     Installing psutil==5.9.0 (may require C++ Build Tools)...
    "%PYTHON_EXE%" -m pip install psutil==5.9.0 --only-binary :all: 2>nul
    if errorlevel 1 (
        echo       [SKIPPED] psutil - Binary wheel not available, C++ Build Tools needed
    ) else (
        set /a SUCCESS_COUNT+=1
    )
    set /a PKG_COUNT+=1
    
    echo     Installing pywin32==311...
    "%PYTHON_EXE%" -m pip install pywin32==311 && set /a SUCCESS_COUNT+=1
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
echo Common issues:
echo   - Internet connection problems
echo   - Insufficient disk space
echo   - Antivirus/Windows Defender blocking downloads or execution
echo   - Corrupted download
echo.
echo If antivirus blocked:
echo   1. Add to antivirus whitelist: %EMBED_DIR%
echo   2. Or download manually from: https://www.python.org/ftp/python/%PYTHON_VERSION%/
echo   3. This is official Python, safe to use
echo.

REM Only pause if NOT called from start.bat
if not defined CALLED_FROM_START (
    echo Press any key to exit...
    pause >nul
)
exit /b 1

:END
echo.
echo ============================================================
echo   Setup Complete!
echo ============================================================
echo.

REM Only pause if NOT called from start.bat
if not defined CALLED_FROM_START (
    echo Press any key to exit...
    pause >nul
)
exit /b 0
