# Quick Backup Script
# Usage: .\scripts\backup_now.ps1

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups\backup_$timestamp"

Write-Host "Creating backup: $backupDir" -ForegroundColor Cyan

# Create backup directory
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Copy critical files
$criticalFiles = @(
    "main_application.py",
    "run.py",
    "config.txt",
    "requirements.txt"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination $backupDir -Force
        Write-Host "[OK] Backed up: $file" -ForegroundColor Green
    }
}

# Copy src directory
Copy-Item "src" -Destination "$backupDir\src" -Recurse -Force
Write-Host "[OK] Backed up: src\" -ForegroundColor Green

Write-Host ""
Write-Host "Backup completed: $backupDir" -ForegroundColor Green
Write-Host ""
Write-Host "To restore from this backup:" -ForegroundColor Yellow
Write-Host "  Copy-Item $backupDir\* -Destination . -Recurse -Force" -ForegroundColor Cyan
