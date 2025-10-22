# Multi-System ZULF-NMR Simulator Launcher (PowerShell)
# Reads configuration from config.txt and launches application
# Auto-configures environment on first run
#
# Usage:
#   .\start.ps1           - Normal launch (auto-configure on first run)
#   .\start.ps1 --setup   - Force reconfiguration of environment

param(
    [switch]$Setup
)

$ErrorActionPreference = "Stop"

# Check for --setup flag
if ($Setup) {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  MANUAL RECONFIGURATION REQUESTED" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Removing first-run marker and reconfiguring environment..." -ForegroundColor White
    if (Test-Path ".setup_complete") {
        Remove-Item ".setup_complete" -Force
    }
    Write-Host ""
}

# ============================================================
# First-Run Auto-Configuration
# ============================================================

# Check if this is the first run (marker file doesn't exist)
if (-not (Test-Path ".setup_complete")) {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  FIRST RUN DETECTED - Auto-Configuration Starting" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This appears to be your first time running ZULF-NMR Suite." -ForegroundColor White
    Write-Host "Setting up the environment automatically..." -ForegroundColor White
    Write-Host ""
    
    # Step 1: Setup embedded Python
    Write-Host "[1/2] Configuring embedded Python environment..." -ForegroundColor Green
    Write-Host ""
    
    $pythonSetupScript = "environments\python\setup_embedded_python.ps1"
    if (Test-Path $pythonSetupScript) {
        try {
            & $pythonSetupScript
            if ($LASTEXITCODE -ne 0) {
                throw "Python setup script returned error code: $LASTEXITCODE"
            }
        }
        catch {
            Write-Host ""
            Write-Host "ERROR: Python environment setup failed!" -ForegroundColor Red
            Write-Host "Please run the setup script manually:" -ForegroundColor Yellow
            Write-Host "  $pythonSetupScript" -ForegroundColor White
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
    else {
        Write-Host "WARNING: Python setup script not found!" -ForegroundColor Yellow
        Write-Host "Expected: $pythonSetupScript" -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host ""
    Write-Host "[2/2] Configuring Spinach/MATLAB environment..." -ForegroundColor Green
    Write-Host ""
    
    $spinachSetupScript = "environments\spinach\setup_spinach.ps1"
    if (Test-Path $spinachSetupScript) {
        try {
            & $spinachSetupScript
            # Note: Spinach setup may exit with non-zero if user chooses Python-only mode
            # This is acceptable, so we don't throw on error
        }
        catch {
            Write-Host ""
            Write-Host "WARNING: Spinach/MATLAB setup failed or skipped." -ForegroundColor Yellow
            Write-Host "You can run this setup later if needed:" -ForegroundColor White
            Write-Host "  $spinachSetupScript" -ForegroundColor White
            Write-Host ""
            Write-Host "Continuing with Python-only mode..." -ForegroundColor White
            Write-Host ""
        }
    }
    else {
        Write-Host "WARNING: Spinach setup script not found!" -ForegroundColor Yellow
        Write-Host "Expected: $spinachSetupScript" -ForegroundColor White
        Write-Host ""
    }
    
    # Create first-run completion marker
    New-Item -Path ".setup_complete" -ItemType File -Force | Out-Null
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  First-Run Configuration Complete!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Enter to start the application..." -ForegroundColor White
    Read-Host
    Write-Host ""
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Read configuration file
$configFile = "config.txt"

if (-not (Test-Path $configFile)) {
    Write-Host "ERROR: Configuration file not found: $configFile" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Parse config.txt
$config = @{}
Get-Content $configFile | ForEach-Object {
    $line = $_.Trim()
    # Skip comments and empty lines
    if ($line -and -not $line.StartsWith('#')) {
        if ($line -match '^(.+?)\s*=\s*(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $config[$key] = $value
        }
    }
}

# Get required parameters
$appName = $config['APP_NAME']
$appVersion = $config['APP_VERSION']
$pythonPath = $config['PYTHON_ENV_PATH']

if (-not $pythonPath) {
    Write-Host "ERROR: PYTHON_ENV_PATH not found in config.txt" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Convert path format
$pythonPath = $pythonPath.Replace('/', '\')

# Display header
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "" 
Write-Host "  $appName" -ForegroundColor Cyan
Write-Host "  Version $appVersion" -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if this is a conda environment
$isConda = $pythonPath -match 'anaconda|conda|miniconda'

if ($isConda) {
    # Extract environment name from path
    $envName = Split-Path (Split-Path $pythonPath -Parent) -Leaf
    
    Write-Host "Python Environment: $envName (conda)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Activating conda environment..." -ForegroundColor Yellow
    
    try {
        # Initialize conda for PowerShell if not already done
        $condaHook = "D:\anaconda3\shell\condabin\conda-hook.ps1"
        if (Test-Path $condaHook) {
            & $condaHook
        }
        
        conda activate $envName
        
        Write-Host "Environment activated successfully" -ForegroundColor Green
        Write-Host ""
        
        $useDirectPath = $false
    }
    catch {
        Write-Host "Failed to activate conda environment, using direct Python path instead..." -ForegroundColor Yellow
        Write-Host ""
        $useDirectPath = $true
    }
}
else {
    # Not a conda environment (venv or system Python)
    Write-Host "Python Path: $pythonPath" -ForegroundColor Yellow
    Write-Host "Environment Type: venv/system Python" -ForegroundColor Gray
    Write-Host ""
    $useDirectPath = $true
}

# Run the application
Write-Host "Starting application..." -ForegroundColor Yellow
Write-Host ""

# Clear Qt environment variables to avoid conflicts
$env:QT_PLUGIN_PATH = ""
$env:QT_QPA_PLATFORM_PLUGIN_PATH = ""

try {
    if ($useDirectPath) {
        # Use direct Python path
        # Try pythonw.exe first (GUI mode, no console), fallback to python.exe
        $pythonDir = Split-Path $pythonPath -Parent
        $pythonwPath = Join-Path $pythonDir "pythonw.exe"
        
        if (Test-Path $pythonwPath) {
            Write-Host "Using pythonw.exe (GUI mode, no console window)" -ForegroundColor Green
            Start-Process -FilePath $pythonwPath -ArgumentList "run.py" -WorkingDirectory $PSScriptRoot
        }
        else {
            Write-Host "pythonw.exe not found, using python.exe" -ForegroundColor Yellow
            & $pythonPath run.py
        }
    }
    else {
        # Use activated conda environment
        # Try to find pythonw.exe in the activated environment
        $pythonwCmd = Get-Command pythonw.exe -ErrorAction SilentlyContinue
        
        if ($pythonwCmd) {
            Write-Host "Using pythonw.exe (GUI mode, no console window)" -ForegroundColor Green
            Start-Process -FilePath "pythonw.exe" -ArgumentList "run.py" -WorkingDirectory $PSScriptRoot
        }
        else {
            Write-Host "pythonw.exe not found, using python.exe" -ForegroundColor Yellow
            & python run.py
        }
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Application exited with errors" -ForegroundColor Red
        Read-Host "Press Enter to exit"
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: Failed to activate environment: $envName" -ForegroundColor Red
    Write-Host "Please check if the environment exists:" -ForegroundColor Yellow
    Write-Host "  conda env list" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or run directly using Python path from config.txt:" -ForegroundColor Yellow
    Write-Host "  $pythonPath run.py" -ForegroundColor Gray
    Read-Host "Press Enter to exit"
    exit 1
}
