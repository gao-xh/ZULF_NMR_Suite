# Multi-System ZULF-NMR Simulator Launcher (PowerShell)
# Reads configuration from config.txt and launches application

$ErrorActionPreference = "Stop"

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
