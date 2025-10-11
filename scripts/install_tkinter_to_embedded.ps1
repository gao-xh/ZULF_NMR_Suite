# Install tkinter to Embedded Python Environment
# This script copies tkinter from system Python to embedded Python

param(
    [string]$SourcePython = "D:\anaconda3",
    [string]$TargetPython = ".\environments\python"
)

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Installing tkinter to Embedded Python" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Resolve paths
$SourcePython = Resolve-Path $SourcePython -ErrorAction Stop
$TargetPython = Resolve-Path $TargetPython -ErrorAction Stop

Write-Host "[INFO] Source Python: $SourcePython" -ForegroundColor Green
Write-Host "[INFO] Target Python: $TargetPython" -ForegroundColor Green
Write-Host ""

# Check if source has tkinter
$sourceTkinter = Join-Path $SourcePython "Lib\tkinter"
if (-not (Test-Path $sourceTkinter)) {
    Write-Host "[ERROR] tkinter not found in source Python: $sourceTkinter" -ForegroundColor Red
    exit 1
}

# Copy tkinter library
Write-Host "[1/4] Copying tkinter library..." -ForegroundColor Yellow
$targetLib = Join-Path $TargetPython "Lib"
$targetTkinter = Join-Path $targetLib "tkinter"

if (-not (Test-Path $targetLib)) {
    New-Item -ItemType Directory -Path $targetLib -Force | Out-Null
}

Copy-Item -Path $sourceTkinter -Destination $targetLib -Recurse -Force
Write-Host "      [OK] tkinter library copied" -ForegroundColor Green

# Copy _tkinter.pyd (Python extension module)
Write-Host "[2/4] Copying _tkinter.pyd..." -ForegroundColor Yellow
$sourceTkinterPyd = Join-Path $SourcePython "DLLs\_tkinter.pyd"
$targetDLLs = Join-Path $TargetPython "DLLs"

if (-not (Test-Path $targetDLLs)) {
    New-Item -ItemType Directory -Path $targetDLLs -Force | Out-Null
}

if (Test-Path $sourceTkinterPyd) {
    Copy-Item -Path $sourceTkinterPyd -Destination $targetDLLs -Force
    Write-Host "      [OK] _tkinter.pyd copied" -ForegroundColor Green
} else {
    Write-Host "      [WARN] _tkinter.pyd not found at $sourceTkinterPyd" -ForegroundColor Yellow
}

# Copy TCL/TK DLLs
Write-Host "[3/4] Copying TCL/TK DLLs..." -ForegroundColor Yellow
$tcltkDLLs = @("tcl86t.dll", "tk86t.dll", "tcl86.dll", "tk86.dll")

foreach ($dll in $tcltkDLLs) {
    $sourceDLL = Join-Path $SourcePython "DLLs\$dll"
    if (Test-Path $sourceDLL) {
        Copy-Item -Path $sourceDLL -Destination $targetDLLs -Force
        Write-Host "      [OK] $dll copied" -ForegroundColor Green
    } else {
        Write-Host "      [SKIP] $dll not found" -ForegroundColor Gray
    }
}

# Copy tcl library folder
Write-Host "[4/4] Copying tcl library folder..." -ForegroundColor Yellow
$sourceTcl = Join-Path $SourcePython "tcl"
if (Test-Path $sourceTcl) {
    $targetTcl = Join-Path $TargetPython "tcl"
    Copy-Item -Path $sourceTcl -Destination $TargetPython -Recurse -Force
    Write-Host "      [OK] tcl library folder copied" -ForegroundColor Green
} else {
    Write-Host "      [SKIP] tcl folder not found at $sourceTcl" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "tkinter Installation Complete!" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Test tkinter import
Write-Host "Testing tkinter import..." -ForegroundColor Yellow
$testResult = & "$TargetPython\python.exe" -c "import tkinter; print('tkinter version:', tkinter.TkVersion)" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] tkinter import successful!" -ForegroundColor Green
    Write-Host "     $testResult" -ForegroundColor Green
} else {
    Write-Host "[ERROR] tkinter import failed:" -ForegroundColor Red
    Write-Host "     $testResult" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "You can now use tkinter in the embedded Python environment." -ForegroundColor Green
