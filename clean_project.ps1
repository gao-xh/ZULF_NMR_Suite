# Clean Project Script
# Removes temporary files, caches, and build artifacts

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ZULF-NMR Suite - Project Cleanup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$cleaned = 0

# Remove Python cache directories in project source
Write-Host "Cleaning Python cache files..." -ForegroundColor Yellow
$pycacheDirs = @(
    "__pycache__",
    "src\__pycache__",
    "src\core\__pycache__",
    "src\simulation\__pycache__",
    "src\simulation\ui\__pycache__",
    "src\ui\__pycache__",
    "src\utils\__pycache__",
    "src\processing\__pycache__"
)

foreach ($dir in $pycacheDirs) {
    if (Test-Path $dir) {
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ Removed $dir" -ForegroundColor Green
        $cleaned++
    }
}

# Remove temporary log files
Write-Host "`nCleaning log files..." -ForegroundColor Yellow
$logFiles = Get-ChildItem -Path . -Filter "replay_pid*.log" -ErrorAction SilentlyContinue
foreach ($file in $logFiles) {
    Remove-Item $file -Force
    Write-Host "  ✓ Removed $($file.Name)" -ForegroundColor Green
    $cleaned++
}

if (Test-Path "matlab_output.log") {
    Remove-Item "matlab_output.log" -Force
    Write-Host "  ✓ Removed matlab_output.log" -ForegroundColor Green
    $cleaned++
}

# Remove Python compiled files
Write-Host "`nCleaning .pyc files..." -ForegroundColor Yellow
$pycFiles = Get-ChildItem -Path src -Filter "*.pyc" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $pycFiles) {
    Remove-Item $file -Force
    Write-Host "  ✓ Removed $($file.FullName)" -ForegroundColor Green
    $cleaned++
}

# Remove Spinach scratch directory if it exists
Write-Host "`nCleaning Spinach scratch files..." -ForegroundColor Yellow
if (Test-Path "environments\spinach\scratch") {
    Remove-Item "environments\spinach\scratch" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ Removed environments\spinach\scratch" -ForegroundColor Green
    $cleaned++
}

# Remove temporary directories
Write-Host "`nCleaning temporary directories..." -ForegroundColor Yellow
$tempDirs = @("temp", "tmp", ".pytest_cache")
foreach ($dir in $tempDirs) {
    if (Test-Path $dir) {
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ Removed $dir" -ForegroundColor Green
        $cleaned++
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($cleaned -eq 0) {
    Write-Host "Project is already clean! ✨" -ForegroundColor Green
} else {
    Write-Host "Cleanup complete! Removed $cleaned items. ✨" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
