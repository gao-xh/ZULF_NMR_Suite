# Spinach Auto-Setup Script
# Automatically detects MATLAB installation and configures Spinach toolbox
# Author: Xuehan Gao, Ajoy Lab
# Date: October 2025

param(
    [string]$MatlabPath = "",
    [switch]$Interactive = $true
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ZULF-NMR Suite - Spinach Toolbox Setup" -ForegroundColor Cyan
Write-Host "  MATLAB Backend Configuration" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$rootDir = $PSScriptRoot | Split-Path | Split-Path
$spinachDir = Join-Path $rootDir "environments\spinach"
$configFile = Join-Path $rootDir "config.txt"

# Step 1: Check if Spinach is already installed
Write-Host "Step 1/6: Checking Spinach installation..." -ForegroundColor Cyan

if (Test-Path (Join-Path $spinachDir "kernel")) {
    Write-Host "  Spinach found in:" -ForegroundColor Gray
    Write-Host "    $spinachDir" -ForegroundColor DarkGray
    Write-Host "  [OK] Spinach toolbox detected" -ForegroundColor Green
    Write-Host ""
    
    if ($Interactive) {
        $response = Read-Host "  Reconfigure MATLAB settings? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "  Keeping existing configuration" -ForegroundColor Gray
            Write-Host ""
            exit 0
        }
        Write-Host ""
    }
}
else {
    Write-Host "  [INFO] Spinach not found in environments/spinach/" -ForegroundColor Yellow
    Write-Host "  Downloading Spinach from GitHub Releases..." -ForegroundColor Cyan
    Write-Host ""
    
    # Read Spinach version from config.txt
    $spinachVersion = "2.9.2"  # Default fallback
    $spinachGithubUrl = "https://github.com/IlyaKuprov/Spinach"  # Default fallback
    
    if (Test-Path $configFile) {
        $configContent = Get-Content $configFile
        foreach ($line in $configContent) {
            if ($line -match '^\s*SPINACH_VERSION\s*=\s*(.+)') {
                $spinachVersion = $matches[1].Trim()
            }
            if ($line -match '^\s*SPINACH_GITHUB_URL\s*=\s*(.+)') {
                $spinachGithubUrl = $matches[1].Trim()
            }
        }
    }
    
    $downloadUrl = "$spinachGithubUrl/archive/refs/tags/$spinachVersion.zip"
    $zipFile = Join-Path $env:TEMP "Spinach-$spinachVersion.zip"
    $extractPath = Join-Path $env:TEMP "Spinach-$spinachVersion"
    
    try {
        Write-Host "  Downloading Spinach v$spinachVersion..." -ForegroundColor Gray
        Write-Host "    URL: $downloadUrl" -ForegroundColor DarkGray
        
        # Download with progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        Write-Host "  [OK] Download completed" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "  Extracting files..." -ForegroundColor Gray
        Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force
        
        # Find the extracted folder (it will be named Spinach-2.9.2)
        $sourceFolder = Join-Path $extractPath "Spinach-$spinachVersion"
        
        if (Test-Path $sourceFolder) {
            Write-Host "  Copying to installation directory..." -ForegroundColor Gray
            
            # Create spinach directory if it doesn't exist
            if (-not (Test-Path $spinachDir)) {
                New-Item -ItemType Directory -Path $spinachDir -Force | Out-Null
            }
            
            # Copy contents (not the folder itself)
            Copy-Item -Path "$sourceFolder\*" -Destination $spinachDir -Recurse -Force
            
            Write-Host "  [OK] Spinach installed successfully" -ForegroundColor Green
            Write-Host ""
            
            # Cleanup
            Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
            Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        else {
            throw "Extracted folder not found: $sourceFolder"
        }
    }
    catch {
        Write-Host "  [ERROR] Failed to download Spinach: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Manual Download Instructions:" -ForegroundColor Cyan
        Write-Host "    1. Visit: https://github.com/IlyaKuprov/Spinach/releases/tag/$spinachVersion" -ForegroundColor Gray
        Write-Host "    2. Download 'Source code (zip)'" -ForegroundColor Gray
        Write-Host "    3. Extract the ZIP file" -ForegroundColor Gray
        Write-Host "    4. Copy the contents of Spinach-$spinachVersion folder to:" -ForegroundColor Gray
        Write-Host "       $spinachDir" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Alternative (Official Site):" -ForegroundColor Cyan
        Write-Host "    Visit: https://spindynamics.org/Spinach.php" -ForegroundColor Gray
        Write-Host "    (Requires registration)" -ForegroundColor DarkGray
        Write-Host ""
        
        if ($Interactive) {
            $response = Read-Host "  Do you have Spinach installed elsewhere? (y/N)"
            if ($response -eq 'y' -or $response -eq 'Y') {
                $source = Read-Host "  Enter Spinach installation path"
                if (Test-Path $source) {
                    Write-Host "  Copying Spinach..." -ForegroundColor Yellow
                    Copy-Item -Path "$source\*" -Destination $spinachDir -Recurse -Force
                    Write-Host "  [OK] Spinach copied successfully" -ForegroundColor Green
                    Write-Host ""
                }
                else {
                    Write-Host "  [ERROR] Path not found: $source" -ForegroundColor Red
                    Write-Host ""
                    exit 1
                }
            }
            else {
                Write-Host ""
                Write-Host "  Alternative: Use Python backend instead (no MATLAB required)" -ForegroundColor Cyan
                Write-Host ""
                exit 0
            }
        }
        else {
            exit 1
        }
    }
}

# Step 2: Detect MATLAB installation
# Step 2: Detect MATLAB installation
Write-Host "Step 2/6: Detecting MATLAB installation..." -ForegroundColor Cyan

$matlabLocations = @()

# Check common installation paths
$commonPaths = @(
    "C:\Program Files\MATLAB",
    "C:\Program Files (x86)\MATLAB",
    "D:\MATLAB",
    "E:\MATLAB",
    "C:\MATLAB"
)

foreach ($basePath in $commonPaths) {
    if (Test-Path $basePath) {
        Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $matlabExe = Join-Path $_.FullName "bin\matlab.exe"
            if (Test-Path $matlabExe) {
                $matlabLocations += @{
                    Version = $_.Name
                    Path = $_.FullName
                    Exe = $matlabExe
                }
                Write-Host "  Found: $($_.Name) at $($_.FullName)" -ForegroundColor DarkGray
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
    Write-Host "  [WARNING] No MATLAB installation found automatically" -ForegroundColor Yellow
    Write-Host ""
    
    if ($Interactive) {
        Write-Host "  Would you like to:" -ForegroundColor Cyan
        Write-Host "    1. Manually enter MATLAB installation path" -ForegroundColor Gray
        Write-Host "    2. Exit and install MATLAB" -ForegroundColor Gray
        Write-Host "    3. Use Python backend instead" -ForegroundColor Gray
        Write-Host ""
        
        $choice = Read-Host "  Select option (1-3)"
        
        if ($choice -eq "1") {
            Write-Host ""
            $manualPath = Read-Host "  Enter MATLAB installation path (e.g., C:\Program Files\MATLAB\R2023b)"
            
            if (Test-Path $manualPath) {
                $matlabExe = Join-Path $manualPath "bin\matlab.exe"
                if (Test-Path $matlabExe) {
                    $version = Split-Path $manualPath -Leaf
                    $matlabLocations += @{
                        Version = $version
                        Path = $manualPath
                        Exe = $matlabExe
                    }
                    Write-Host "  [OK] MATLAB found at: $manualPath" -ForegroundColor Green
                    Write-Host ""
                }
                else {
                    Write-Host "  [ERROR] matlab.exe not found in: $manualPath\bin\" -ForegroundColor Red
                    Write-Host ""
                    exit 1
                }
            }
            else {
                Write-Host "  [ERROR] Path not found: $manualPath" -ForegroundColor Red
                Write-Host ""
                exit 1
            }
        }
        elseif ($choice -eq "2") {
            Write-Host ""
            Write-Host "  Please install MATLAB R2021b or later, then run this script again." -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
        else {
            Write-Host ""
            Write-Host "  You can use Python backend instead (no MATLAB required)" -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
    }
    else {
        Write-Host "  [ERROR] No MATLAB installation found" -ForegroundColor Red
        Write-Host ""
        Write-Host "  MATLAB R2021b or later is required for MATLAB backend." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Options:" -ForegroundColor Gray
        Write-Host "    1. Install MATLAB from MathWorks" -ForegroundColor DarkGray
        Write-Host "    2. Run this script with -MatlabPath parameter" -ForegroundColor DarkGray
        Write-Host "    3. Use Python backend instead (no MATLAB required)" -ForegroundColor DarkGray
        Write-Host ""
        exit 1
    }
}

Write-Host "  [OK] Found $($matlabLocations.Count) MATLAB installation(s)" -ForegroundColor Green
Write-Host ""

for ($i = 0; $i -lt $matlabLocations.Count; $i++) {
    $matlab = $matlabLocations[$i]
    Write-Host "    [$($i+1)] $($matlab.Version)" -ForegroundColor White
    Write-Host "        $($matlab.Path)" -ForegroundColor DarkGray
}

Write-Host ""

# Step 3: Select MATLAB version
# Step 3: Select MATLAB version
Write-Host "Step 3/6: Selecting MATLAB version..." -ForegroundColor Cyan

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
    Write-Host "  Auto-selected: $($selectedMatlab.Version)" -ForegroundColor Gray
    Write-Host "  [OK] MATLAB selected" -ForegroundColor Green
}
elseif ($Interactive) {
    # Let user choose
    $choice = Read-Host "  Select MATLAB version (1-$($matlabLocations.Count))"
    $index = [int]$choice - 1
    
    if ($index -ge 0 -and $index -lt $matlabLocations.Count) {
        $selectedMatlab = $matlabLocations[$index]
        Write-Host "  Selected: $($selectedMatlab.Version)" -ForegroundColor Gray
        Write-Host "  [OK] MATLAB selected" -ForegroundColor Green
    }
    else {
        Write-Host "  [ERROR] Invalid selection" -ForegroundColor Red
        exit 1
    }
}
else {
    # Use the newest version (last in sorted list)
    $selectedMatlab = $matlabLocations | Sort-Object Version | Select-Object -Last 1
    Write-Host "  Auto-selected newest: $($selectedMatlab.Version)" -ForegroundColor Gray
    Write-Host "  [OK] MATLAB selected" -ForegroundColor Green
}

Write-Host ""

# Step 4: Configure startup script
# Step 4: Configure MATLAB startup script
Write-Host "Step 4/6: Configuring MATLAB startup script..." -ForegroundColor Cyan

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
Write-Host "  Created: matlab_startup.m" -ForegroundColor Gray
Write-Host "  [OK] Startup script configured" -ForegroundColor Green

Write-Host ""

# Step 5: Install MATLAB Engine for Python
Write-Host "Step 5/6: Installing MATLAB Engine for Python..." -ForegroundColor Cyan

$pythonExe = Join-Path $rootDir "environments\python\python.exe"
if (Test-Path $pythonExe) {
    Write-Host "  Python found: $pythonExe" -ForegroundColor Gray
    Write-Host "  Installing matlabengine package..." -ForegroundColor Gray
    
    try {
        # Try installing matlabengine with the detected MATLAB installation
        & $pythonExe -m pip install matlabengine==25.1.2 --quiet --no-warn-script-location 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] MATLAB Engine for Python installed successfully" -ForegroundColor Green
        } else {
            Write-Host "  [WARNING] Failed to install MATLAB Engine" -ForegroundColor Yellow
            Write-Host "  This is optional - you can still use MATLAB via subprocess" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  [WARNING] Failed to install MATLAB Engine" -ForegroundColor Yellow
        Write-Host "  Error: $_" -ForegroundColor DarkGray
        Write-Host "  This is optional - you can still use MATLAB via subprocess" -ForegroundColor Gray
    }
} else {
    Write-Host "  [WARNING] Python not found at: $pythonExe" -ForegroundColor Yellow
    Write-Host "  Please run setup_embedded_python first" -ForegroundColor Gray
}

Write-Host ""

# Step 6: Update config.txt
Write-Host "Step 6/6: Updating configuration..." -ForegroundColor Cyan

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
    Write-Host "  Updated config.txt:" -ForegroundColor Gray
    Write-Host "    MATLAB_PATH = $($selectedMatlab.Path.Replace('\', '/'))" -ForegroundColor DarkGray
    Write-Host "    SPINACH_PATH = $($spinachDir.Replace('\', '/'))" -ForegroundColor DarkGray
    Write-Host "  [OK] Configuration updated" -ForegroundColor Green
}
else {
    Write-Host "  [WARNING] config.txt not found" -ForegroundColor Yellow
}

Write-Host ""

# Optional: Test MATLAB connection
if ($Interactive) {
    Write-Host "Optional: Test MATLAB connection..." -ForegroundColor Cyan
    $response = Read-Host "  Launch MATLAB to verify configuration? (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host "  Starting MATLAB (this may take a minute)..." -ForegroundColor Gray
        Write-Host ""
        
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
Write-Host "Configuration summary:" -ForegroundColor Cyan
Write-Host "  MATLAB Version: $($selectedMatlab.Version)" -ForegroundColor Gray
Write-Host "  MATLAB Path:    $($selectedMatlab.Path)" -ForegroundColor DarkGray
Write-Host "  Spinach Path:   $spinachDir" -ForegroundColor DarkGray
Write-Host "  Startup Script: matlab_startup.m" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Launch the suite:" -ForegroundColor Gray
Write-Host "     start.bat  (or)  start.ps1" -ForegroundColor DarkGray
Write-Host "  2. Select 'MATLAB' backend in startup dialog" -ForegroundColor Gray
Write-Host "  3. Start your ZULF-NMR simulations!" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
