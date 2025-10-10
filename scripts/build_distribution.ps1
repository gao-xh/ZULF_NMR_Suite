# ZULF-NMR Suite - Distribution Builder
# Automated script to prepare and package the application for distribution

param(
    [string]$Version = "0.1.0",
    [switch]$SkipPython,
    [switch]$SkipTests,
    [switch]$CleanOnly
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Step { param($msg) Write-Host "`n==== $msg ====" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

$rootDir = $PSScriptRoot | Split-Path
$distDir = Join-Path $rootDir "dist"
$buildName = "ZULF_NMR_Suite_v${Version}_Windows_x64"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ZULF-NMR Suite - Distribution Builder" -ForegroundColor Cyan
Write-Host "  Version: $Version" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Step 1: Clean project
Write-Step "Step 1: Cleaning project"

Write-Host "Removing __pycache__ directories..."
Get-ChildItem -Path $rootDir -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force
Write-Success "Removed __pycache__ directories"

Write-Host "Removing .pyc files..."
Get-ChildItem -Path $rootDir -Recurse -Filter "*.pyc" | Remove-Item -Force
Write-Success "Removed .pyc files"

Write-Host "Removing .pytest_cache..."
Get-ChildItem -Path $rootDir -Recurse -Directory -Filter ".pytest_cache" | Remove-Item -Recurse -Force
Write-Success "Removed pytest cache"

if ($CleanOnly) {
    Write-Success "Clean complete! Exiting..."
    exit 0
}

# Step 2: Setup embedded Python
if (-not $SkipPython) {
    Write-Step "Step 2: Setting up embedded Python"
    
    $pythonDir = Join-Path $rootDir "environments\python"
    $pythonExe = Join-Path $pythonDir "python.exe"
    
    if (Test-Path $pythonExe) {
        Write-Warning "Embedded Python already exists"
        $response = Read-Host "Reinstall? (y/n)"
        if ($response -eq 'y') {
            Push-Location $pythonDir
            & ".\setup_embedded_python.ps1"
            Pop-Location
        }
    }
    else {
        Write-Host "Installing embedded Python..."
        Push-Location $pythonDir
        & ".\setup_embedded_python.ps1"
        Pop-Location
    }
    
    if (Test-Path $pythonExe) {
        Write-Success "Embedded Python ready"
    }
    else {
        Write-Error "Failed to setup embedded Python"
        exit 1
    }
}
else {
    Write-Step "Step 2: Skipping embedded Python setup"
}

# Step 3: Run tests
if (-not $SkipTests) {
    Write-Step "Step 3: Running tests"
    
    $pythonExe = Join-Path $rootDir "environments\python\python.exe"
    if (-not (Test-Path $pythonExe)) {
        $pythonExe = "python"
    }
    
    Write-Host "Testing environment detection..."
    & $pythonExe (Join-Path $rootDir "tests\test_environment.py")
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tests passed"
    }
    else {
        Write-Warning "Tests failed, but continuing..."
    }
}
else {
    Write-Step "Step 3: Skipping tests"
}

# Step 4: Update config
Write-Step "Step 4: Updating configuration"

$configFile = Join-Path $rootDir "config.txt"
$configContent = Get-Content $configFile

# Update Python path to use embedded
$configContent = $configContent -replace 'PYTHON_ENV_PATH\s*=\s*.*', 'PYTHON_ENV_PATH = environments/python/python.exe'

Set-Content -Path $configFile -Value $configContent
Write-Success "Updated config.txt to use embedded Python"

# Step 5: Create distribution directory
Write-Step "Step 5: Preparing distribution"

if (Test-Path $distDir) {
    Remove-Item -Path $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $distDir | Out-Null

$buildDir = Join-Path $distDir $buildName
Write-Host "Copying files to: $buildDir"

# Copy entire project
Copy-Item -Path $rootDir -Destination $buildDir -Recurse -Force `
    -Exclude @('.git', '.gitignore', 'dist', '*.log', '.vscode', '.idea', 'venv', 'env')

Write-Success "Files copied"

# Step 6: Clean distribution copy
Write-Step "Step 6: Cleaning distribution copy"

# Remove test files (optional)
# Remove-Item -Path (Join-Path $buildDir "tests") -Recurse -Force -ErrorAction SilentlyContinue

# Remove development scripts
Remove-Item -Path (Join-Path $buildDir "scripts\prepare_distribution.ps1") -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $buildDir "scripts\build_distribution.ps1") -Force -ErrorAction SilentlyContinue

# Remove Git files
Remove-Item -Path (Join-Path $buildDir ".git") -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $buildDir ".gitignore") -Force -ErrorAction SilentlyContinue

Write-Success "Distribution cleaned"

# Step 7: Create user documentation
Write-Step "Step 7: Creating user documentation"

$readmeContent = @"
# ZULF-NMR Suite v$Version

## Quick Start

1. Extract this folder to any location
2. Double-click ``start.bat`` to launch the application
3. Select your preferred backend in the startup dialog
4. Start using!

## System Requirements

- Windows 10/11 (64-bit)
- 4GB RAM (8GB recommended)
- 2GB disk space
- Optional: MATLAB R2021b+ for MATLAB backend

## Troubleshooting

### Application won't start
- Right-click ``start.bat`` → Edit
- Check that paths are correct
- Ensure you have write permissions in this folder

### Missing DLL errors
Install Visual C++ Redistributable:
https://aka.ms/vs/17/release/vc_redist.x64.exe

### Other issues
See ``docs/`` folder or contact support

## Documentation

- Quick Start Guide: ``docs/QUICK_START.md``
- User Manual: ``docs/INDEX.md``
- Troubleshooting: ``docs/troubleshooting/``

## Version Information

- Version: $Version
- Release Date: $(Get-Date -Format "MMMM yyyy")
- Python: 3.12.7 (embedded)
- PySide6: 6.7.3

## License

See ``LICENSE`` file for details.

## Contact

- GitHub: https://github.com/yourusername/ZULF_NMR_Suite
- Email: your.email@example.com

---

**IMPORTANT**: This folder contains a complete Python environment.
You do NOT need to install Python separately.
"@

Set-Content -Path (Join-Path $buildDir "README.txt") -Value $readmeContent
Write-Success "Created README.txt"

# Step 8: Package
Write-Step "Step 8: Creating distribution package"

$zipFile = Join-Path $distDir "$buildName.zip"

Write-Host "Compressing to: $zipFile"
Write-Host "This may take several minutes..."

Compress-Archive -Path $buildDir -DestinationPath $zipFile -CompressionLevel Optimal

if (Test-Path $zipFile) {
    $size = (Get-Item $zipFile).Length / 1MB
    Write-Success "Package created: $($size.ToString('F2')) MB"
}
else {
    Write-Error "Failed to create package"
    exit 1
}

# Step 9: Generate checksums
Write-Step "Step 9: Generating checksums"

$hash = Get-FileHash -Path $zipFile -Algorithm SHA256
$checksumFile = Join-Path $distDir "checksums.txt"

$checksumContent = @"
ZULF-NMR Suite v$Version
Build Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

SHA256: $($hash.Hash)
File: $buildName.zip
Size: $($size.ToString('F2')) MB

Verify with:
  Get-FileHash -Algorithm SHA256 $buildName.zip
"@

Set-Content -Path $checksumFile -Value $checksumContent
Write-Success "Checksums generated"

# Step 10: Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Distribution Build Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Distribution package:" -ForegroundColor Cyan
Write-Host "  $zipFile" -ForegroundColor White
Write-Host "  Size: $($size.ToString('F2')) MB" -ForegroundColor Gray
Write-Host ""
Write-Host "SHA256: $($hash.Hash)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test the package on a clean system" -ForegroundColor Gray
Write-Host "  2. Upload to distribution server" -ForegroundColor Gray
Write-Host "  3. Create GitHub Release" -ForegroundColor Gray
Write-Host "  4. Notify users" -ForegroundColor Gray
Write-Host ""

# Open distribution folder
Start-Process $distDir
