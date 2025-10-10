# File Integrity Verification Script
# Usage: .\scripts\verify_file_integrity.ps1

param(
    [string]$FilePath = "main_application.py"
)

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  File Integrity Check: $FilePath" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "[ERROR] File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Get file info
$fileInfo = Get-Item $FilePath
$lineCount = (Get-Content $FilePath).Count
$fileSize = $fileInfo.Length

Write-Host "File: $FilePath" -ForegroundColor White
Write-Host "Size: $fileSize bytes" -ForegroundColor Gray
Write-Host "Lines: $lineCount" -ForegroundColor Gray
Write-Host "Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
Write-Host ""

# Expected values for critical files
$expectedMetrics = @{
    "main_application.py" = @{
        MinLines = 150
        MaxLines = 250
        MinSize = 4000
        MaxSize = 8000
    }
    "run.py" = @{
        MinLines = 200
        MaxLines = 400
        MinSize = 8000
        MaxSize = 15000
    }
}

# Check expected ranges
$fileName = Split-Path -Leaf $FilePath
if ($expectedMetrics.ContainsKey($fileName)) {
    $expected = $expectedMetrics[$fileName]
    
    Write-Host "Expected Ranges:" -ForegroundColor Yellow
    Write-Host "  Lines: $($expected.MinLines) - $($expected.MaxLines)" -ForegroundColor Gray
    Write-Host "  Size: $($expected.MinSize) - $($expected.MaxSize) bytes" -ForegroundColor Gray
    Write-Host ""
    
    $issues = @()
    
    if ($lineCount -lt $expected.MinLines) {
        $issues += "Line count too low ($lineCount < $($expected.MinLines))"
    }
    if ($lineCount -gt $expected.MaxLines) {
        $issues += "Line count too high ($lineCount > $($expected.MaxLines))"
    }
    if ($fileSize -lt $expected.MinSize) {
        $issues += "File size too small ($fileSize < $($expected.MinSize))"
    }
    if ($fileSize -gt $expected.MaxSize) {
        $issues += "File size too large ($fileSize > $($expected.MaxSize))"
    }
    
    if ($issues.Count -gt 0) {
        Write-Host "[WARN] Potential issues detected:" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "  - $issue" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "[OK] File metrics within expected range" -ForegroundColor Green
        Write-Host ""
    }
}

# Python syntax check
Write-Host "Checking Python syntax..." -ForegroundColor Yellow
try {
    $result = python -m py_compile $FilePath 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] No syntax errors" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Syntax errors detected:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to run syntax check" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

# Check for common corruption patterns
Write-Host "Checking for corruption patterns..." -ForegroundColor Yellow
$content = Get-Content $FilePath -Raw

$corruptionPatterns = @(
    @{ Pattern = '""""""'; Description = "Multiple empty docstrings" }
    @{ Pattern = 'import.*import'; Description = "Duplicate import statements" }
    @{ Pattern = 'class.*class'; Description = "Duplicate class definitions" }
    @{ Pattern = 'def.*def.*def.*def.*def'; Description = "Too many consecutive function definitions" }
)

$foundIssues = $false
foreach ($check in $corruptionPatterns) {
    if ($content -match $check.Pattern) {
        Write-Host "[WARN] Found: $($check.Description)" -ForegroundColor Yellow
        $foundIssues = $true
    }
}

if (-not $foundIssues) {
    Write-Host "[OK] No corruption patterns detected" -ForegroundColor Green
}

Write-Host ""

# Show first and last few lines
Write-Host "File preview (first 10 lines):" -ForegroundColor Cyan
Get-Content $FilePath -TotalCount 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  Integrity Check Complete" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
