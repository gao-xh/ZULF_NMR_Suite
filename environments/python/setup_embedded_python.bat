@echo off
REM Setup Embedded Python Environment
REM This script downloads and configures embedded Python in environments/python/

setlocal enabledelayedexpansion

echo ============================================================
echo   ZULF-NMR Suite - Embedded Python Setup
echo ============================================================
echo.

set "EMBED_DIR=%~dp0"
set "PYTHON_VERSION=3.12.7"
set "DOWNLOAD_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "ZIP_FILE=python-embed.zip"

REM Check if already installed
if exist "%EMBED_DIR%python.exe" (
    echo Python already installed in environments/python/
    echo Version:
    "%EMBED_DIR%python.exe" --version
    echo.
    choice /C YN /M "Reinstall"
    if errorlevel 2 goto :END
    echo.
)

echo Step 1: Downloading embedded Python %PYTHON_VERSION%...
echo URL: %DOWNLOAD_URL%
echo.

REM Download using PowerShell
powershell -Command "& {Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%'}"

if not exist "%ZIP_FILE%" (
    echo ERROR: Download failed!
    goto :ERROR
)

echo.
echo Step 2: Extracting Python...
powershell -Command "& {Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EMBED_DIR%' -Force}"

del "%ZIP_FILE%"

if not exist "%EMBED_DIR%python.exe" (
    echo ERROR: Extraction failed!
    goto :ERROR
)

echo.
echo Step 3: Configuring Python...
REM Enable pip by uncommenting 'import site' in python3xx._pth
for %%f in (python3*.._pth) do (
    powershell -Command "(Get-Content '%%f') -replace '#import site', 'import site' | Set-Content '%%f'"
    echo Configured: %%f
)

echo.
echo Step 4: Installing pip...
powershell -Command "& {Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile 'get-pip.py'}"
"%EMBED_DIR%python.exe" get-pip.py
del get-pip.py

echo.
echo Step 5: Installing dependencies...
echo This may take several minutes...
echo.

REM Install from requirements.txt
if exist "..\..\requirements.txt" (
    "%EMBED_DIR%python.exe" -m pip install -r "..\..\requirements.txt"
) else (
    echo Warning: requirements.txt not found
    echo Installing core packages manually...
    "%EMBED_DIR%python.exe" -m pip install PySide6
    "%EMBED_DIR%python.exe" -m pip install numpy
    "%EMBED_DIR%python.exe" -m pip install matplotlib
    "%EMBED_DIR%python.exe" -m pip install scipy
)

echo.
echo ============================================================
echo   Setup Complete!
echo ============================================================
echo.
echo Python installed in: %EMBED_DIR%
echo.
echo Test it:
echo   %EMBED_DIR%python.exe --version
echo   %EMBED_DIR%python.exe -c "import PySide6; print('OK')"
echo.
echo To use embedded Python, update config.txt:
echo   PYTHON_ENV_PATH = environments/python/python.exe
echo.
goto :END

:ERROR
echo.
echo Setup failed! Please check the error messages above.
echo.
pause
exit /b 1

:END
pause
