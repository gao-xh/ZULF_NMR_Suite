# Setup Embedded Python Environment
# This script downloads and configures embedded Python 3.12.7 in environments/python/
# Author: Xuehan Gao, Ajoy Lab
# Date: October 2025

$ErrorActionPreference = "Stop"

# Configuration
$PYTHON_VERSION = "3.12.7"
$EMBED_DIR = $PSScriptRoot

# Multiple download sources (official + mirrors)
$DOWNLOAD_SOURCES = @(
    @{
        Name = "Python.org (Official)"
        URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
    },
    @{
        Name = "npm mirror (China)"
        URL = "https://registry.npmmirror.com/-/binary/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
    },
    @{
        Name = "Huawei Cloud (China)"
        URL = "https://repo.huaweicloud.com/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
    }
)

$ZIP_FILE = Join-Path $EMBED_DIR "python-embed.zip"
$PYTHON_EXE = Join-Path $EMBED_DIR "python.exe"
$REQUIREMENTS_FILE = Join-Path $EMBED_DIR "..\..\requirements.txt"

# Banner
function Show-Banner {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  ZULF-NMR Suite - Embedded Python Setup" -ForegroundColor Cyan
    Write-Host "  Python Version: $PYTHON_VERSION" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Check if Python is already installed
function Test-Installation {
    if (Test-Path $PYTHON_EXE) {
        Write-Host "Python is already installed at:" -ForegroundColor Yellow
        Write-Host "  $EMBED_DIR" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Current version:" -ForegroundColor Yellow
        & $PYTHON_EXE --version
        Write-Host ""
        
        $response = Read-Host "Do you want to reinstall? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host ""
            Write-Host "Setup cancelled. Existing installation preserved." -ForegroundColor Green
            Write-Host ""
            return $false
        }
        Write-Host ""
        Write-Host "Removing existing installation..." -ForegroundColor Yellow
        Get-ChildItem -Path $EMBED_DIR -Exclude "*.ps1", "*.bat" | Remove-Item -Recurse -Force
        Write-Host ""
    }
    return $true
}

# Download embedded Python
function Download-Python {
    Write-Host "Step 1/5: Downloading embedded Python..." -ForegroundColor Cyan
    Write-Host "  Version: $PYTHON_VERSION" -ForegroundColor Gray
    Write-Host ""
    
    foreach ($source in $DOWNLOAD_SOURCES) {
        Write-Host "  Trying: $($source.Name)" -ForegroundColor Yellow
        Write-Host "  URL: $($source.URL)" -ForegroundColor DarkGray
        
        try {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $source.URL -OutFile $ZIP_FILE -UseBasicParsing -TimeoutSec 30
            $ProgressPreference = 'Continue'
            
            $fileSize = (Get-Item $ZIP_FILE).Length / 1MB
            Write-Host "  Downloaded: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
            Write-Host "  [OK] Download complete from $($source.Name)" -ForegroundColor Green
            Write-Host ""
            return $true
        }
        catch {
            Write-Host "  [FAILED] $($source.Name): $_" -ForegroundColor Red
            if (Test-Path $ZIP_FILE) {
                Remove-Item $ZIP_FILE -Force
            }
            Write-Host ""
            # Try next source
        }
    }
    
    # All sources failed
    Write-Host "  [ERROR] All download sources failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Please try:" -ForegroundColor Yellow
    Write-Host "    1. Check your internet connection" -ForegroundColor Gray
    Write-Host "    2. Download manually from: https://www.python.org/downloads/" -ForegroundColor Gray
    Write-Host "    3. Extract to: $EMBED_DIR" -ForegroundColor Gray
    Write-Host ""
    return $false
}

# Extract Python archive
function Extract-Python {
    Write-Host "Step 2/5: Extracting Python archive..." -ForegroundColor Cyan
    
    try {
        Expand-Archive -Path $ZIP_FILE -DestinationPath $EMBED_DIR -Force
        Remove-Item $ZIP_FILE -Force
        Write-Host "  [OK] Extraction complete" -ForegroundColor Green
        Write-Host ""
        
        if (-not (Test-Path $PYTHON_EXE)) {
            Write-Host "  [ERROR] python.exe not found after extraction" -ForegroundColor Red
            Write-Host ""
            return $false
        }
        return $true
    }
    catch {
        Write-Host "  [ERROR] Extraction failed: $_" -ForegroundColor Red
        Write-Host ""
        return $false
    }
}

# Configure Python environment
function Configure-Python {
    Write-Host "Step 3/5: Configuring Python environment..." -ForegroundColor Cyan
    
    $pthFiles = Get-ChildItem -Path $EMBED_DIR -Filter "python3*._pth"
    
    if ($pthFiles.Count -eq 0) {
        Write-Host "  [WARNING] No ._pth file found" -ForegroundColor Yellow
        Write-Host ""
        return $true
    }
    
    foreach ($file in $pthFiles) {
        try {
            $content = Get-Content $file.FullName
            $newContent = $content -replace '#import site', 'import site'
            Set-Content -Path $file.FullName -Value $newContent
            Write-Host "  Enabled site packages: $($file.Name)" -ForegroundColor Gray
        }
        catch {
            Write-Host "  [WARNING] Failed to configure $($file.Name): $_" -ForegroundColor Yellow
        }
    }
    
    Write-Host "  [OK] Configuration complete" -ForegroundColor Green
    Write-Host ""
    return $true
}

# Install pip
function Install-Pip {
    Write-Host "Step 4/5: Installing pip..." -ForegroundColor Cyan
    
    $getPipPath = Join-Path $EMBED_DIR "get-pip.py"
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPipPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        Write-Host "  Running pip installer..." -ForegroundColor Gray
        & $PYTHON_EXE $getPipPath --quiet --no-warn-script-location
        
        if ($LASTEXITCODE -ne 0) {
            throw "pip installation failed with exit code $LASTEXITCODE"
        }
        
        Remove-Item $getPipPath -Force
        
        # Install build tools first (critical for building packages from source)
        Write-Host "  Installing build tools (setuptools, wheel)..." -ForegroundColor Gray
        & $PYTHON_EXE -m pip install --upgrade setuptools wheel --quiet --no-warn-script-location 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [WARNING] Failed to upgrade build tools, trying without --upgrade..." -ForegroundColor Yellow
            & $PYTHON_EXE -m pip install setuptools wheel --quiet --no-warn-script-location 2>$null
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [WARNING] Could not install build tools, some packages may fail" -ForegroundColor Yellow
            } else {
                Write-Host "  [OK] Build tools installed (without upgrade)" -ForegroundColor Green
            }
        } else {
            Write-Host "  [OK] Build tools installed successfully" -ForegroundColor Green
        }
        
        # Verify pip installation
        $pipVersion = & $PYTHON_EXE -m pip --version 2>$null
        if ($pipVersion) {
            Write-Host "  Installed: $pipVersion" -ForegroundColor Gray
        }
        Write-Host "  [OK] pip installation complete" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host "  [ERROR] pip installation failed: $_" -ForegroundColor Red
        Write-Host ""
        if (Test-Path $getPipPath) {
            Remove-Item $getPipPath -Force
        }
        return $false
    }
}

# Install dependencies
function Install-Dependencies {
    Write-Host "Step 5/5: Installing dependencies..." -ForegroundColor Cyan
    
    if (Test-Path $REQUIREMENTS_FILE) {
        Write-Host "  Installing from requirements.txt..." -ForegroundColor Gray
        Write-Host "  This may take several minutes, please wait..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Note: Some packages (matlabengine, psutil) may require:" -ForegroundColor Yellow
        Write-Host "    - MATLAB installation (for matlabengine)" -ForegroundColor Gray
        Write-Host "    - Visual C++ Build Tools (for psutil)" -ForegroundColor Gray
        Write-Host "  Skipping these if not available..." -ForegroundColor Yellow
        Write-Host ""
        
        try {
            # First try: binary wheels only (no source builds)
            & $PYTHON_EXE -m pip install -r $REQUIREMENTS_FILE --only-binary :all: --quiet --no-warn-script-location 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] All dependencies installed successfully (binary wheels)" -ForegroundColor Green
                Write-Host ""
                
                # Show installed packages
                Write-Host "  Installed packages:" -ForegroundColor Gray
                $packages = & $PYTHON_EXE -m pip list --format=columns
                $packages | Select-Object -First 10 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
                if ($packages.Count -gt 10) {
                    Write-Host "    ... and $($packages.Count - 10) more packages" -ForegroundColor DarkGray
                }
                Write-Host ""
                return $true
            }
            
            # Second try: allow selective builds (skip packages that fail)
            Write-Host "  [WARNING] Binary-only installation failed, trying with selective builds..." -ForegroundColor Yellow
            Write-Host ""
            
            & $PYTHON_EXE -m pip install -r $REQUIREMENTS_FILE --quiet --no-warn-script-location 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] Dependencies installed with selective builds" -ForegroundColor Green
                Write-Host ""
                return $true
            }
            
            throw "pip install returned error code $LASTEXITCODE"
        }
        catch {
            Write-Host "  [ERROR] Full requirements.txt installation failed" -ForegroundColor Red
            Write-Host ""
            Write-Host "  This may be due to:" -ForegroundColor Yellow
            Write-Host "    - Network connection issues" -ForegroundColor Gray
            Write-Host "    - Package compatibility problems" -ForegroundColor Gray
            Write-Host "    - Missing build dependencies (Visual C++ Build Tools)" -ForegroundColor Gray
            Write-Host "    - Missing MATLAB installation" -ForegroundColor Gray
            Write-Host ""
            Write-Host "  Attempting to install core packages only..." -ForegroundColor Yellow
            Write-Host ""
            # Fall through to install core packages
        }
    }
    
    # Install core packages (either requirements.txt not found or failed)
    if (-not (Test-Path $REQUIREMENTS_FILE)) {
        Write-Host "  [WARNING] requirements.txt not found at:" -ForegroundColor Yellow
        Write-Host "    $REQUIREMENTS_FILE" -ForegroundColor Gray
        Write-Host "  Installing essential packages manually..." -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Essential packages for ZULF-NMR Suite
    $corePackages = @(
        @{Name='PySide6==6.7.3'; Required=$true},
        @{Name='PySide6-Addons==6.7.3'; Required=$true},
        @{Name='PySide6-Essentials==6.7.3'; Required=$true},
        @{Name='numpy==2.3.3'; Required=$true},
        @{Name='scipy==1.16.2'; Required=$true},
        @{Name='matplotlib==3.10.0'; Required=$true},
        @{Name='pandas==2.3.1'; Required=$true},
        @{Name='pillow==11.3.0'; Required=$true},
        @{Name='requests==2.32.4'; Required=$true},
        @{Name='pyyaml==6.0.2'; Required=$true},
        @{Name='colorama==0.4.6'; Required=$true},
        @{Name='tqdm==4.67.1'; Required=$true},
        @{Name='psutil==5.9.0'; Required=$false; Note='may require C++ Build Tools'},
        @{Name='pywin32==311'; Required=$true}
    )
    
    $successCount = 0
    $totalCount = $corePackages.Count
    
    foreach ($pkg in $corePackages) {
        $packageName = $pkg.Name
        $isRequired = $pkg.Required
        $note = $pkg.Note
        
        if ($note) {
            Write-Host "    Installing $packageName ($note)..." -ForegroundColor Gray
        } else {
            Write-Host "    Installing $packageName..." -ForegroundColor Gray
        }
        
        try {
            if (-not $isRequired) {
                # For optional packages, try binary only first
                & $PYTHON_EXE -m pip install $packageName --only-binary :all: --quiet --no-warn-script-location 2>$null
            } else {
                & $PYTHON_EXE -m pip install $packageName --quiet --no-warn-script-location 2>$null
            }
            
            if ($LASTEXITCODE -eq 0) {
                $successCount++
            } elseif (-not $isRequired) {
                Write-Host "      [SKIPPED] $($packageName.Split('==')[0]) - $note" -ForegroundColor Yellow
            }
        }
        catch {
            if (-not $isRequired) {
                Write-Host "      [SKIPPED] $($packageName.Split('==')[0]) - $note" -ForegroundColor Yellow
            }
            # Continue with other packages
        }
    }
    
    Write-Host ""
    Write-Host "  Installed $successCount/$totalCount packages successfully" -ForegroundColor $(if ($successCount -ge 9) { 'Green' } else { 'Yellow' })
    if ($successCount -lt 9) {
        Write-Host "  [WARNING] Only $successCount packages installed successfully" -ForegroundColor Yellow
        Write-Host "  Some optional features may not work (system monitoring)" -ForegroundColor Yellow
    }
    else {
        Write-Host "  [OK] Essential packages installation complete" -ForegroundColor Green
        Write-Host "  Note: MATLAB Engine will be installed during Spinach setup" -ForegroundColor Gray
    }
    Write-Host ""
    return ($successCount -ge 9)
}

# Show completion summary
function Show-Summary {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "  Installation Complete!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation directory:" -ForegroundColor Cyan
    Write-Host "  $EMBED_DIR" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Python version:" -ForegroundColor Cyan
    & $PYTHON_EXE --version | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "Quick test:" -ForegroundColor Cyan
    Write-Host "  $PYTHON_EXE --version" -ForegroundColor Gray
    Write-Host "  $PYTHON_EXE -c `"import PySide6; print('PySide6 OK')`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To use this environment:" -ForegroundColor Cyan
    Write-Host "  1. Update config.txt:" -ForegroundColor Gray
    Write-Host "     PYTHON_ENV_PATH = environments/python/python.exe" -ForegroundColor DarkGray
    Write-Host "  2. Run start.bat or start.ps1" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
try {
    Show-Banner
    
    if (-not (Test-Installation)) {
        exit 0
    }
    
    if (-not (Download-Python)) { exit 1 }
    if (-not (Extract-Python)) { exit 1 }
    if (-not (Configure-Python)) { exit 1 }
    if (-not (Install-Pip)) { exit 1 }
    if (-not (Install-Dependencies)) { exit 1 }
    
    Show-Summary
    
    Write-Host "Press Enter to exit..." -ForegroundColor Yellow
    Read-Host
    exit 0
}
catch {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "  Installation Failed!" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Yellow
    Read-Host
    exit 1
}
