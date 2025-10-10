# ===================================================================
# Git Setup and Backup Protection Script
# ===================================================================
# This script initializes Git version control and creates backup 
# protection to prevent file corruption issues.
#
# Usage: .\scripts\setup_git_protection.ps1
# ===================================================================

param(
    [string]$GitUserName = "ZULF-NMR Developer",
    [string]$GitUserEmail = "developer@zulf-nmr.local"
)

$ErrorActionPreference = "Stop"

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  Git Version Control Setup" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
try {
    $gitVersion = git --version 2>&1
    Write-Host "[OK] Git is installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please restart PowerShell after Git installation" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After restarting PowerShell, run this script again:" -ForegroundColor Yellow
    Write-Host "  .\scripts\setup_git_protection.ps1" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# Navigate to project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot

Write-Host "Project root: $projectRoot" -ForegroundColor Gray
Write-Host ""

# Initialize Git repository if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host "[INIT] Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "[OK] Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "[OK] Git repository already exists" -ForegroundColor Green
}

Write-Host ""

# Configure Git user
Write-Host "[CONFIG] Setting up Git user configuration..." -ForegroundColor Yellow
git config user.name "$GitUserName"
git config user.email "$GitUserEmail"
Write-Host "[OK] Git user configured" -ForegroundColor Green
Write-Host "  Name: $GitUserName" -ForegroundColor Gray
Write-Host "  Email: $GitUserEmail" -ForegroundColor Gray

Write-Host ""

# Create initial commit if repository is empty
$commitCount = git rev-list --all --count 2>$null
if ($commitCount -eq 0 -or $null -eq $commitCount) {
    Write-Host "[COMMIT] Creating initial commit..." -ForegroundColor Yellow
    
    # Add all files
    git add .
    
    # Create initial commit
    git commit -m "Initial commit: ZULF-NMR Suite v0.1.0 Beta"
    
    Write-Host "[OK] Initial commit created" -ForegroundColor Green
} else {
    Write-Host "[OK] Repository has $commitCount commit(s)" -ForegroundColor Green
    
    # Show current status
    Write-Host ""
    Write-Host "[STATUS] Current repository status:" -ForegroundColor Yellow
    git status --short
}

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  Backup Protection Setup" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Create backup script
$backupScriptContent = @'
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
'@

$backupScriptPath = "scripts\backup_now.ps1"
Set-Content -Path $backupScriptPath -Value $backupScriptContent -Encoding UTF8
Write-Host "[OK] Created backup script: $backupScriptPath" -ForegroundColor Green

Write-Host ""

# Create backups directory if it doesn't exist
if (-not (Test-Path "backups")) {
    New-Item -ItemType Directory -Path "backups" -Force | Out-Null
    Write-Host "[OK] Created backups directory" -ForegroundColor Green
}

# Add backups to .gitignore
$gitignorePath = ".gitignore"
if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    if ($gitignoreContent -notmatch "backups/") {
        Add-Content -Path $gitignorePath -Value "`n# Backups`nbackups/`n"
        Write-Host "[OK] Added backups/ to .gitignore" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  Protection Guidelines" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

Write-Host "1. BEFORE making major changes:" -ForegroundColor Yellow
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'Before: [description]'" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. AFTER completing changes:" -ForegroundColor Yellow
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'After: [description]'" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. To create manual backup:" -ForegroundColor Yellow
Write-Host "   .\scripts\backup_now.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. To see file changes:" -ForegroundColor Yellow
Write-Host "   git diff main_application.py" -ForegroundColor Cyan
Write-Host ""

Write-Host "5. To restore a file from last commit:" -ForegroundColor Yellow
Write-Host "   git checkout HEAD -- main_application.py" -ForegroundColor Cyan
Write-Host ""

Write-Host "6. To see commit history:" -ForegroundColor Yellow
Write-Host "   git log --oneline -10" -ForegroundColor Cyan
Write-Host ""

Write-Host "=" * 70 -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green
Write-Host ""
Write-Host "Your code is now protected with:" -ForegroundColor Green
Write-Host "  [OK] Git version control" -ForegroundColor Green
Write-Host "  [OK] Backup script (.\scripts\backup_now.ps1)" -ForegroundColor Green
Write-Host "  [OK] .gitignore configured" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Please restart your PowerShell terminal" -ForegroundColor Yellow
Write-Host "           to ensure Git commands work properly." -ForegroundColor Yellow
Write-Host ""
