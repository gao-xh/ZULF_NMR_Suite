# Clean project for distribution
# Removes development artifacts

$ErrorActionPreference = "Stop"

Write-Host "Cleaning ZULF-NMR Suite project..." -ForegroundColor Cyan
Write-Host ""

$rootDir = $PSScriptRoot | Split-Path

# Remove __pycache__
Write-Host "Removing __pycache__ directories..." -NoNewline
$pycache = Get-ChildItem -Path $rootDir -Recurse -Directory -Filter "__pycache__"
$pycache | Remove-Item -Recurse -Force
Write-Host " Done ($($pycache.Count) removed)" -ForegroundColor Green

# Remove .pyc files
Write-Host "Removing .pyc files..." -NoNewline
$pyc = Get-ChildItem -Path $rootDir -Recurse -Filter "*.pyc"
$pyc | Remove-Item -Force
Write-Host " Done ($($pyc.Count) removed)" -ForegroundColor Green

# Remove pytest cache
Write-Host "Removing .pytest_cache..." -NoNewline
$pytest = Get-ChildItem -Path $rootDir -Recurse -Directory -Filter ".pytest_cache"
$pytest | Remove-Item -Recurse -Force
Write-Host " Done ($($pytest.Count) removed)" -ForegroundColor Green

# Remove .DS_Store (macOS)
Write-Host "Removing .DS_Store files..." -NoNewline
$ds = Get-ChildItem -Path $rootDir -Recurse -Filter ".DS_Store"
$ds | Remove-Item -Force
Write-Host " Done ($($ds.Count) removed)" -ForegroundColor Green

# Remove log files
Write-Host "Removing log files..." -NoNewline
$logs = Get-ChildItem -Path $rootDir -Recurse -Filter "*.log"
$logs | Remove-Item -Force
Write-Host " Done ($($logs.Count) removed)" -ForegroundColor Green

Write-Host ""
Write-Host "[OK] Project cleaned successfully!" -ForegroundColor Green
Write-Host ""
