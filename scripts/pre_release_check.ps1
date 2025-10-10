# Pre-Release Quick Check Script
# Run this before building distribution package

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

function Write-Check { param($msg) Write-Host "  Checking: $msg" -ForegroundColor Cyan }
function Write-Pass { param($msg) Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-Warn { param($msg) Write-Host "  [WARN] $msg" -ForegroundColor Yellow }

$rootDir = Split-Path -Parent $PSScriptRoot
$errors = @()
$warnings = @()

Write-Host ""
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  ZULF-NMR Suite - Pre-Release Check" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# 1. Version Check
Write-Host "1. VERSION CONSISTENCY" -ForegroundColor Yellow
Write-Host "-" * 70

Write-Check "config.txt version"
$configPath = Join-Path $rootDir "config.txt"
$configContent = Get-Content $configPath -Raw
if ($configContent -match 'APP_VERSION\s*=\s*0\.1\.0') {
    Write-Pass "APP_VERSION = 0.1.0"
} else {
    Write-Fail "APP_VERSION is not 0.1.0"
    $errors += "config.txt version mismatch"
}

Write-Check "config.txt App ID"
if ($configContent -match 'APP_USER_MODEL_ID\s*=\s*AjoyLab\.ZULFNMRSuite\.Application\.0\.1') {
    Write-Pass "APP_USER_MODEL_ID = 0.1"
} else {
    Write-Fail "APP_USER_MODEL_ID is not 0.1"
    $errors += "config.txt App ID mismatch"
}

Write-Check "run.py app_id"
$runPath = Join-Path $rootDir "run.py"
$runContent = Get-Content $runPath -Raw
if ($runContent -match 'app_id\s*=\s*[''"]AjoyLab\.ZULFNMRSuite\.Application\.0\.1[''"]') {
    Write-Pass "run.py app_id = 0.1"
} else {
    Write-Fail "run.py app_id is not 0.1"
    $errors += "run.py app_id mismatch"
}

Write-Check "build_distribution.ps1 default version"
$buildScriptPath = Join-Path $rootDir "scripts\build_distribution.ps1"
$buildContent = Get-Content $buildScriptPath -Raw
if ($buildContent -match 'Version\s*=\s*"0\.1\.0"') {
    Write-Pass "build_distribution.ps1 default version = 0.1.0"
} else {
    Write-Warn "build_distribution.ps1 default version may not be 0.1.0"
    $warnings += "build script version should be checked"
}

Write-Host ""

# 2. File Existence
Write-Host "2. CRITICAL FILES" -ForegroundColor Yellow
Write-Host "-" * 70

$criticalFiles = @(
    "config.txt",
    "main_application.py",
    "run.py",
    "start.bat",
    "start.ps1",
    "requirements.txt",
    "README.md",
    "LICENSE",
    "src\__init__.py",
    "src\simulation\ui\simulation_window.py",
    "src\ui\splash_screen.py",
    "src\ui\startup_dialog.py",
    "src\utils\first_run_setup.py",
    "src\utils\environment.py",
    "environments\python\setup_embedded_python.ps1",
    "environments\spinach\setup_spinach.ps1",
    "scripts\build_distribution.ps1"
)

foreach ($file in $criticalFiles) {
    $fullPath = Join-Path $rootDir $file
    if (Test-Path $fullPath) {
        Write-Pass $file
    } else {
        Write-Fail "Missing: $file"
        $errors += "Missing file: $file"
    }
}

# File Integrity Check for main_application.py
$mainAppPath = Join-Path $rootDir "main_application.py"
if (Test-Path $mainAppPath) {
    $lineCount = (Get-Content $mainAppPath).Count
    $fileSize = (Get-Item $mainAppPath).Length
    
    if ($lineCount -lt 150 -or $lineCount -gt 250) {
        Write-Warn "main_application.py line count unusual: $lineCount (expected 150-250)"
        $warnings += "main_application.py may be corrupted (line count: $lineCount)"
    }
    
    if ($fileSize -lt 4000 -or $fileSize -gt 8000) {
        Write-Warn "main_application.py size unusual: $fileSize bytes (expected 4KB-8KB)"
        $warnings += "main_application.py may be corrupted (size: $fileSize)"
    }
}

Write-Host ""

# 3. Code Quality Checks
Write-Host "3. CODE QUALITY" -ForegroundColor Yellow
Write-Host "-" * 70

Write-Check "first_run_setup.py path calculation"
$firstRunPath = Join-Path $rootDir "src\utils\first_run_setup.py"
$firstRunContent = Get-Content $firstRunPath -Raw
if ($firstRunContent -match 'workspace_root\s*=\s*Path\(__file__\)\.parent\.parent\.parent') {
    Write-Pass "Workspace root path correctly calculated (parent.parent.parent)"
} else {
    Write-Fail "Workspace root path may be incorrect"
    $errors += "first_run_setup.py path calculation error"
}

Write-Check "run.py imports first_run_setup"
if ($runContent -match 'from src\.utils\.first_run_setup import') {
    Write-Pass "run.py imports first_run_setup"
} else {
    Write-Fail "run.py doesn't import first_run_setup"
    $errors += "Missing first_run_setup import"
}

Write-Check "run.py checks first run"
if ($runContent -match 'check_first_run') {
    Write-Pass "run.py calls check_first_run()"
} else {
    Write-Fail "run.py doesn't call check_first_run()"
    $errors += "Missing first run check"
}

Write-Host ""

# 4. Launcher Scripts
Write-Host "4. LAUNCHER SCRIPTS" -ForegroundColor Yellow
Write-Host "-" * 70

Write-Check "start.bat pythonw.exe logic"
$startBatPath = Join-Path $rootDir "start.bat"
$batContent = Get-Content $startBatPath -Raw
if ($batContent -match 'pythonw\.exe' -and $batContent -match 'if exist') {
    Write-Pass "start.bat has pythonw.exe with existence check"
} else {
    Write-Warn "start.bat may not have proper pythonw.exe fallback"
    $warnings += "Check start.bat pythonw.exe logic"
}

Write-Check "start.ps1 pythonw.exe logic"
$startPs1Path = Join-Path $rootDir "start.ps1"
$ps1Content = Get-Content $startPs1Path -Raw
if ($ps1Content -match 'pythonw\.exe' -and $ps1Content -match 'Test-Path') {
    Write-Pass "start.ps1 has pythonw.exe with existence check"
} else {
    Write-Warn "start.ps1 may not have proper pythonw.exe fallback"
    $warnings += "Check start.ps1 pythonw.exe logic"
}

Write-Host ""

# 5. Environment Setup Scripts
Write-Host "5. ENVIRONMENT SETUP" -ForegroundColor Yellow
Write-Host "-" * 70

Write-Check "setup_embedded_python.ps1 download URL"
$setupPythonPath = Join-Path $rootDir "environments\python\setup_embedded_python.ps1"
$setupPythonContent = Get-Content $setupPythonPath -Raw
if ($setupPythonContent -match 'python-3\.12\.7-embed-amd64\.zip') {
    Write-Pass "Python 3.12.7 embed download configured"
} else {
    Write-Warn "Python embed version may not be 3.12.7"
    $warnings += "Check Python version in setup script"
}

Write-Check "setup_spinach.ps1 MATLAB detection"
$setupSpinachPath = Join-Path $rootDir "environments\spinach\setup_spinach.ps1"
$setupSpinachContent = Get-Content $setupSpinachPath -Raw
if ($setupSpinachContent -match 'HKLM:\\SOFTWARE\\MathWorks\\MATLAB') {
    Write-Pass "Spinach setup has MATLAB registry detection"
} else {
    Write-Warn "Spinach setup may not detect MATLAB properly"
    $warnings += "Check MATLAB detection in setup_spinach.ps1"
}

Write-Host ""

# 6. Documentation
Write-Host "6. DOCUMENTATION" -ForegroundColor Yellow
Write-Host "-" * 70

$docFiles = @(
    "README.md",
    "docs\release\RELEASE_NOTES_v0.1.0.md",
    "docs\release\BETA_DISTRIBUTION_GUIDE.md",
    "docs\QUICK_START.md",
    "docs\QUICK_REF.md",
    "docs\setup\FIRST_RUN_SETUP.md"
)

foreach ($doc in $docFiles) {
    $fullPath = Join-Path $rootDir $doc
    if (Test-Path $fullPath) {
        Write-Pass $doc
    } else {
        Write-Warn "Missing documentation: $doc"
        $warnings += "Missing doc: $doc"
    }
}

Write-Host ""

# 7. Git Status
Write-Host "7. GIT STATUS" -ForegroundColor Yellow
Write-Host "-" * 70

Push-Location $rootDir
try {
    Write-Check "Git repository status"
    $gitStatus = git status --porcelain 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ([string]::IsNullOrWhiteSpace($gitStatus)) {
            Write-Pass "Working tree clean"
        } else {
            Write-Warn "Uncommitted changes detected:"
            if ($Verbose) {
                git status --short
            } else {
                Write-Host "    Run with -Verbose to see details" -ForegroundColor Gray
            }
            $warnings += "Uncommitted changes exist"
        }
    } else {
        Write-Warn "Not a git repository or git not available"
    }
} finally {
    Pop-Location
}

Write-Host ""

# 8. Environment Markers
Write-Host "8. ENVIRONMENT MARKERS" -ForegroundColor Yellow
Write-Host "-" * 70

Write-Check ".setup_complete marker (should NOT exist)"
$setupMarker = Join-Path $rootDir ".setup_complete"
if (Test-Path $setupMarker) {
    Write-Warn ".setup_complete exists (will prevent first-run dialog)"
    $warnings += "Delete .setup_complete for testing"
} else {
    Write-Pass ".setup_complete does not exist (good for testing)"
}

Write-Check "environments/python/python.exe (optional)"
$pythonExe = Join-Path $rootDir "environments\python\python.exe"
if (Test-Path $pythonExe) {
    Write-Warn "Embedded Python exists (will be included in package)"
    Write-Host "    Size: $((Get-Item $pythonExe).Length / 1MB) MB" -ForegroundColor Gray
} else {
    Write-Pass "Embedded Python not present (will use build script or user setup)"
}

Write-Check "environments/spinach/kernel (optional)"
$spinachKernel = Join-Path $rootDir "environments\spinach\kernel"
if (Test-Path $spinachKernel) {
    Write-Warn "Spinach exists (will be included if packaging full version)"
} else {
    Write-Pass "Spinach not present (expected for developer setup)"
}

Write-Host ""

# Summary
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

if ($errors.Count -eq 0) {
    Write-Host "  [OK] No critical errors found!" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Found $($errors.Count) critical error(s):" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "    - $err" -ForegroundColor Red
    }
}

Write-Host ""

if ($warnings.Count -eq 0) {
    Write-Host "  [OK] No warnings" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Found $($warnings.Count) warning(s):" -ForegroundColor Yellow
    foreach ($warn in $warnings) {
        Write-Host "    - $warn" -ForegroundColor Yellow
    }
}

Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "  Ready to build distribution!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor Cyan
    Write-Host "    1. Review any warnings above" -ForegroundColor Gray
    Write-Host "    2. Run: .\scripts\build_distribution.ps1 -Version 0.1.0" -ForegroundColor Gray
    Write-Host "    3. Test the generated package" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "  Please fix critical errors before building!" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""
