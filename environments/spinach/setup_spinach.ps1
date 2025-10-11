# Spinach Auto-Setup Script
# Automatically detects MATLAB installation and configures Spinach

param(
    [string]$MatlabPath = "",
    [switch]$Interactive = $true
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Spinach Auto-Setup for ZULF-NMR Suite" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = $PSScriptRoot | Split-Path | Split-Path
$spinachDir = Join-Path $rootDir "environments\spinach"
$configFile = Join-Path $rootDir "config.txt"

# Step 1: Check if Spinach is already installed
Write-Host "[1] Checking Spinach installation..." -ForegroundColor Yellow

if (Test-Path (Join-Path $spinachDir "kernel")) {
    Write-Host "  [OK] Spinach found in: $spinachDir" -ForegroundColor Green
    
    if ($Interactive) {
        $response = Read-Host "  Reconfigure? (y/n)"
        if ($response -ne 'y') {
            Write-Host "  Keeping existing configuration" -ForegroundColor Gray
            exit 0
        }
    }
}
else {
    Write-Host "  [INFO] Spinach not found in environments/spinach/" -ForegroundColor Gray
    Write-Host "  Please copy your Spinach installation to:" -ForegroundColor Yellow
    Write-Host "    $spinachDir" -ForegroundColor White
    Write-Host ""
    
    if ($Interactive) {
        $response = Read-Host "  Do you have Spinach installed elsewhere? (y/n)"
        if ($response -eq 'y') {
            $source = Read-Host "  Enter Spinach path"
            if (Test-Path $source) {
                Write-Host "  Copying Spinach..." -ForegroundColor Yellow
                Copy-Item -Path $source -Destination $spinachDir -Recurse -Force
                Write-Host "  [OK] Spinach copied" -ForegroundColor Green
            }
        }
        else {
            Write-Host ""
            Write-Host "  To use MATLAB backend, you need Spinach toolbox." -ForegroundColor Yellow
            Write-Host "  Download from: https://spindynamics.org/Spinach.php" -ForegroundColor Gray
            Write-Host ""
            Write-Host "  For now, you can use Pure Python backend." -ForegroundColor Cyan
            exit 0
        }
    }
}

Write-Host ""

# Step 2: Detect MATLAB installation
Write-Host "[2] Detecting MATLAB installation..." -ForegroundColor Yellow

$matlabLocations = @()

# Check common installation paths
$commonPaths = @(
    "C:\Program Files\MATLAB",
    "C:\Program Files (x86)\MATLAB",
    "D:\MATLAB",
    "C:\MATLAB"
)

foreach ($basePath in $commonPaths) {
    if (Test-Path $basePath) {
        Get-ChildItem -Path $basePath -Directory | ForEach-Object {
            $matlabExe = Join-Path $_.FullName "bin\matlab.exe"
            if (Test-Path $matlabExe) {
                $matlabLocations += @{
                    Version = $_.Name
                    Path = $_.FullName
                    Exe = $matlabExe
                }
            }
        }
    }
}

# Check registry (Windows)
try {
    $regKey = "HKLM:\SOFTWARE\MathWorks\MATLAB"
    if (Test-Path $regKey) {
        Get-ChildItem $regKey | ForEach-Object {
            $installPath = (Get-ItemProperty $_.PSPath).MATLABROOT
            if ($installPath -and (Test-Path $installPath)) {
                $matlabExe = Join-Path $installPath "bin\matlab.exe"
                if (Test-Path $matlabExe) {
                    $version = $_.PSChildName
                    # Avoid duplicates
                    if (-not ($matlabLocations | Where-Object { $_.Path -eq $installPath })) {
                        $matlabLocations += @{
                            Version = $version
                            Path = $installPath
                            Exe = $matlabExe
                        }
                    }
                }
            }
        }
    }
}
catch {
    # Registry check failed, continue
}

if ($matlabLocations.Count -eq 0) {
    Write-Host "  [ERROR] No MATLAB installation found" -ForegroundColor Red
    Write-Host ""
    Write-Host "  MATLAB is required for MATLAB backend." -ForegroundColor Yellow
    Write-Host "  You can:" -ForegroundColor Gray
    Write-Host "    1. Install MATLAB" -ForegroundColor Gray
    Write-Host "    2. Use Pure Python backend instead" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "  [OK] Found $($matlabLocations.Count) MATLAB installation(s):" -ForegroundColor Green

for ($i = 0; $i -lt $matlabLocations.Count; $i++) {
    $matlab = $matlabLocations[$i]
    Write-Host "    [$($i+1)] $($matlab.Version) - $($matlab.Path)" -ForegroundColor White
}

Write-Host ""

# Step 3: Select MATLAB version
$selectedMatlab = $null

if ($MatlabPath) {
    # Use provided path
    $matlabExe = Join-Path $MatlabPath "bin\matlab.exe"
    if (Test-Path $matlabExe) {
        $selectedMatlab = @{
            Path = $MatlabPath
            Exe = $matlabExe
        }
        Write-Host "  Using specified MATLAB: $MatlabPath" -ForegroundColor Cyan
    }
    else {
        Write-Host "  [ERROR] Invalid MATLAB path: $MatlabPath" -ForegroundColor Red
        exit 1
    }
}
elseif ($matlabLocations.Count -eq 1) {
    # Auto-select if only one
    $selectedMatlab = $matlabLocations[0]
    Write-Host "  Auto-selected: $($selectedMatlab.Version)" -ForegroundColor Cyan
}
elseif ($Interactive) {
    # Let user choose
    $choice = Read-Host "  Select MATLAB version (1-$($matlabLocations.Count))"
    $index = [int]$choice - 1
    
    if ($index -ge 0 -and $index -lt $matlabLocations.Count) {
        $selectedMatlab = $matlabLocations[$index]
        Write-Host "  Selected: $($selectedMatlab.Version)" -ForegroundColor Cyan
    }
    else {
        Write-Host "  [ERROR] Invalid selection" -ForegroundColor Red
        exit 1
    }
}
else {
    # Use the newest version (last in sorted list)
    $selectedMatlab = $matlabLocations | Sort-Object Version | Select-Object -Last 1
    Write-Host "  Auto-selected newest: $($selectedMatlab.Version)" -ForegroundColor Cyan
}

Write-Host ""

# Step 4: Configure startup script
Write-Host "[3] Configuring MATLAB startup script..." -ForegroundColor Yellow

$startupScript = @"
% ZULF-NMR Suite - MATLAB Startup Script
% Auto-generated by Spinach Auto-Setup

% Add Spinach to MATLAB path
spinachPath = '$($spinachDir.Replace('\', '\\'))';

if exist(spinachPath, 'dir')
    addpath(genpath(spinachPath));
    fprintf('[OK] Spinach loaded from: %s\n', spinachPath);
else
    warning('Spinach directory not found: %s', spinachPath);
end

% Set default number format
format long

% Display welcome message
fprintf('\\n');
fprintf('====================================\\n');
fprintf('  ZULF-NMR Suite v0.1.0\\n');
fprintf('  MATLAB Backend Ready\\n');
fprintf('====================================\\n');
fprintf('\\n');
"@

$startupFile = Join-Path $rootDir "matlab_startup.m"
Set-Content -Path $startupFile -Value $startupScript
Write-Host "  [OK] Created: matlab_startup.m" -ForegroundColor Green

Write-Host ""

# Step 5: Update config.txt
Write-Host "[4] Updating configuration..." -ForegroundColor Yellow

if (Test-Path $configFile) {
    $config = Get-Content $configFile
    
    # Update MATLAB path
    $updated = $false
    for ($i = 0; $i -lt $config.Length; $i++) {
        if ($config[$i] -match '^MATLAB_PATH\s*=') {
            $config[$i] = "MATLAB_PATH = $($selectedMatlab.Path.Replace('\', '/'))"
            $updated = $true
            break
        }
    }
    
    if (-not $updated) {
        # Add MATLAB_PATH if not exists
        $config += ""
        $config += "# MATLAB Configuration (auto-detected)"
        $config += "MATLAB_PATH = $($selectedMatlab.Path.Replace('\', '/'))"
    }
    
    # Update Spinach path
    $updated = $false
    for ($i = 0; $i -lt $config.Length; $i++) {
        if ($config[$i] -match '^SPINACH_PATH\s*=') {
            $config[$i] = "SPINACH_PATH = $($spinachDir.Replace('\', '/'))"
            $updated = $true
            break
        }
    }
    
    if (-not $updated) {
        $config += "SPINACH_PATH = $($spinachDir.Replace('\', '/'))"
    }
    
    Set-Content -Path $configFile -Value $config
    Write-Host "  [OK] Updated: config.txt" -ForegroundColor Green
}

Write-Host ""

# Step 6: Test MATLAB connection
Write-Host "[5] Testing MATLAB connection..." -ForegroundColor Yellow

if ($Interactive) {
    $response = Read-Host "  Launch MATLAB to verify? (y/n)"
    if ($response -eq 'y') {
        Write-Host "  Starting MATLAB (this may take a minute)..." -ForegroundColor Gray
        
        $testScript = @"
try
    % Test Spinach
    if exist('spinach_version', 'file')
        ver = spinach_version();
        fprintf('[OK] Spinach loaded successfully\n');
        fprintf('  Version: %s\n', ver);
    else
        warning('Spinach not loaded correctly');
    end
catch e
    warning('Error testing Spinach: %s', e.message);
end

fprintf('\nPress any key to exit...\n');
pause;
exit;
"@
        
        $testFile = Join-Path $env:TEMP "zulf_matlab_test.m"
        Set-Content -Path $testFile -Value $testScript
        
        # Launch MATLAB with test script
        & $selectedMatlab.Exe -r "run('$($startupFile.Replace('\', '\\'))'); run('$($testFile.Replace('\', '\\'))')"
        
        Remove-Item $testFile -ErrorAction SilentlyContinue
    }
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Spinach Setup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  MATLAB: $($selectedMatlab.Path)" -ForegroundColor White
Write-Host "  Spinach: $spinachDir" -ForegroundColor White
Write-Host "  Startup: matlab_startup.m" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Launch ZULF-NMR Suite: .\start.bat" -ForegroundColor Gray
Write-Host "  2. Select 'MATLAB' backend in startup dialog" -ForegroundColor Gray
Write-Host "  3. Start simulating!" -ForegroundColor Gray
Write-Host ""
