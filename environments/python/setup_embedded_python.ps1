# Setup Embedded Python Environment
# This script downloads and configures embedded Python in environments/python/

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ZULF-NMR Suite - Embedded Python Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$embedDir = $PSScriptRoot
$pythonVersion = "3.12.7"
$downloadUrl = "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-embed-amd64.zip"
$zipFile = Join-Path $embedDir "python-embed.zip"

# Check if already installed
$pythonExe = Join-Path $embedDir "python.exe"
if (Test-Path $pythonExe) {
    Write-Host "Python already installed in environments/python/" -ForegroundColor Yellow
    Write-Host "Version:"
    & $pythonExe --version
    Write-Host ""
    
    $response = Read-Host "Reinstall? (y/n)"
    if ($response -ne 'y') {
        exit 0
    }
    Write-Host ""
}

# Step 1: Download
Write-Host "Step 1: Downloading embedded Python $pythonVersion..." -ForegroundColor Yellow
Write-Host "URL: $downloadUrl"
Write-Host ""

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    Write-Host "✓ Download complete" -ForegroundColor Green
}
catch {
    Write-Host "✗ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Extract
Write-Host ""
Write-Host "Step 2: Extracting Python..." -ForegroundColor Yellow

try {
    Expand-Archive -Path $zipFile -DestinationPath $embedDir -Force
    Remove-Item $zipFile
    Write-Host "✓ Extraction complete" -ForegroundColor Green
}
catch {
    Write-Host "✗ Extraction failed: $_" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $pythonExe)) {
    Write-Host "✗ Python executable not found after extraction" -ForegroundColor Red
    exit 1
}

# Step 3: Configure
Write-Host ""
Write-Host "Step 3: Configuring Python..." -ForegroundColor Yellow

Get-ChildItem -Path $embedDir -Filter "python3*._pth" | ForEach-Object {
    $content = Get-Content $_.FullName
    $newContent = $content -replace '#import site', 'import site'
    Set-Content -Path $_.FullName -Value $newContent
    Write-Host "✓ Configured: $($_.Name)" -ForegroundColor Green
}

# Step 4: Install pip
Write-Host ""
Write-Host "Step 4: Installing pip..." -ForegroundColor Yellow

$getPipPath = Join-Path $embedDir "get-pip.py"
try {
    Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPipPath
    & $pythonExe $getPipPath
    Remove-Item $getPipPath
    Write-Host "✓ pip installed" -ForegroundColor Green
}
catch {
    Write-Host "✗ pip installation failed: $_" -ForegroundColor Red
    exit 1
}

# Step 5: Install dependencies
Write-Host ""
Write-Host "Step 5: Installing dependencies..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray
Write-Host ""

$requirementsFile = Join-Path $embedDir "..\..\requirements.txt"

if (Test-Path $requirementsFile) {
    try {
        & $pythonExe -m pip install -r $requirementsFile
        Write-Host "✓ Dependencies installed from requirements.txt" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Dependency installation failed: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Warning: requirements.txt not found" -ForegroundColor Yellow
    Write-Host "Installing core packages manually..." -ForegroundColor Gray
    
    $packages = @('PySide6', 'numpy', 'matplotlib', 'scipy')
    foreach ($pkg in $packages) {
        Write-Host "  Installing $pkg..." -ForegroundColor Gray
        & $pythonExe -m pip install $pkg
    }
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Python installed in: $embedDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test it:" -ForegroundColor Yellow
Write-Host "  $pythonExe --version" -ForegroundColor Gray
Write-Host "  $pythonExe -c `"import PySide6; print('OK')`"" -ForegroundColor Gray
Write-Host ""
Write-Host "To use embedded Python, update config.txt:" -ForegroundColor Yellow
Write-Host "  PYTHON_ENV_PATH = environments/python/python.exe" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
