# Setup Embedded Python Environment
# This script downloads and configures embedded Python 3.12.7 in environments/python/
# Author: Xuehan Gao, Ajoy Lab
# Date: October 2025

$ErrorActionPreference = "Stop"

# Configuration
$PYTHON_VERSION = "3.12.7"
$EMBED_DIR = $PSScriptRoot
$DOWNLOAD_URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
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
    Write-Host "  URL: $DOWNLOAD_URL" -ForegroundColor Gray
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $ZIP_FILE -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        $fileSize = (Get-Item $ZIP_FILE).Length / 1MB
        Write-Host "  Downloaded: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
        Write-Host "  [OK] Download complete" -ForegroundColor Green
        Write-Host ""
        return $true
    }
    catch {
        Write-Host "  [ERROR] Download failed: $_" -ForegroundColor Red
        Write-Host ""
        return $false
    }
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
        Remove-Item $getPipPath -Force
        
        # Verify pip installation
        $pipVersion = & $PYTHON_EXE -m pip --version
        Write-Host "  Installed: $pipVersion" -ForegroundColor Gray
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
        
        try {
            & $PYTHON_EXE -m pip install -r $REQUIREMENTS_FILE --quiet --no-warn-script-location
            Write-Host "  [OK] All dependencies installed successfully" -ForegroundColor Green
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
        catch {
            Write-Host "  [ERROR] Dependency installation failed: $_" -ForegroundColor Red
            Write-Host ""
            return $false
        }
    }
    else {
        Write-Host "  [WARNING] requirements.txt not found at:" -ForegroundColor Yellow
        Write-Host "    $REQUIREMENTS_FILE" -ForegroundColor Gray
        Write-Host "  Installing essential packages manually..." -ForegroundColor Yellow
        Write-Host ""
        
        # Essential packages for ZULF-NMR Suite
        $corePackages = @(
            'PySide6==6.7.3',
            'PySide6-Addons==6.7.3',
            'PySide6-Essentials==6.7.3',
            'numpy==2.3.3',
            'scipy==1.16.2',
            'matplotlib==3.10.0',
            'pandas==2.3.1',
            'pillow==11.3.0',
            'matlabengine==25.1.2',
            'requests==2.32.4',
            'pyyaml==6.0.2',
            'colorama==0.4.6',
            'tqdm==4.67.1',
            'psutil==5.9.0',
            'pywin32==311'
        )
        
        $successCount = 0
        $failCount = 0
        
        foreach ($pkg in $corePackages) {
            Write-Host "    Installing $pkg..." -ForegroundColor Gray
            try {
                & $PYTHON_EXE -m pip install $pkg --quiet --no-warn-script-location
                $successCount++
            }
            catch {
                Write-Host "    [WARNING] Failed to install $pkg" -ForegroundColor Yellow
                $failCount++
            }
        }
        
        Write-Host ""
        Write-Host "  Installed $successCount/$($corePackages.Count) packages successfully" -ForegroundColor Gray
        if ($failCount -gt 0) {
            Write-Host "  [WARNING] $failCount package(s) failed to install" -ForegroundColor Yellow
        }
        Write-Host "  [OK] Essential packages installation complete" -ForegroundColor Green
        Write-Host ""
        return $true
    }
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
