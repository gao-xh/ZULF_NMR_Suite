# Python Environment Download Strategy

**Last Updated**: October 22, 2025  
**Version**: v0.1.0

---

## Why Not Upload Python Environment to GitHub?

### ❌ Problems with Uploading to GitHub

1. **File Size Limitations**
   - Python embedded: ~50 MB
   - All packages installed: ~500-800 MB
   - GitHub file limit: 100 MB per file
   - GitHub repository recommended size: < 1 GB
   
2. **Platform Dependency**
   - Python binaries are platform-specific
   - Windows binary ≠ Linux binary ≠ macOS binary
   - Would need separate uploads for each platform
   
3. **Security Concerns**
   - Binary files flagged by GitHub security scanners
   - Users may not trust pre-compiled binaries
   - Difficult to audit for malicious code
   
4. **Performance Issues**
   - Large repositories slow down `git clone`
   - Wastes bandwidth on every clone
   - GitHub may throttle or warn about repository size

---

## ✅ Current Solution: Multi-Source Download

### How It Works

The setup scripts (`setup_embedded_python.ps1` and `setup_embedded_python.bat`) automatically try **multiple download sources** in order:

1. **Python.org (Official)** - Primary source
   ```
   https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

2. **npm mirror (China)** - Faster for users in Asia
   ```
   https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

3. **Huawei Cloud (China)** - Alternative Asian mirror
   ```
   https://repo.huaweicloud.com/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

### Automatic Fallback

If the first source fails (timeout, network error, etc.), the script automatically tries the next source:

```powershell
Trying: Python.org (Official)
[FAILED] Connection timeout

Trying: npm mirror (China)
[OK] Downloaded from npm mirror (China)
```

### Benefits

- ✅ **High Reliability**: Multiple mirrors ensure download succeeds
- ✅ **Geographic Optimization**: Faster downloads worldwide
- ✅ **Always Latest**: Downloads from official sources
- ✅ **Small Repository**: GitHub repo stays lightweight (< 50 MB)
- ✅ **Security**: Users can verify official checksums

---

## Manual Download (If All Sources Fail)

If all automatic downloads fail, users can download manually:

### Step 1: Download Python

Visit: https://www.python.org/downloads/release/python-3127/

Look for: **Windows embeddable package (64-bit)**

### Step 2: Extract Files

Extract the downloaded ZIP file to:
```
ZULF_NMR_Suite/environments/python/
```

### Step 3: Verify Structure

Check that `python.exe` exists:
```
ZULF_NMR_Suite/
└── environments/
    └── python/
        ├── python.exe          ← Should exist
        ├── python312.dll
        └── ... (other files)
```

### Step 4: Continue Setup

Run the setup script again:
```powershell
cd environments\python
.\setup_embedded_python.ps1
```

The script will detect the existing Python installation and continue with configuration.

---

## Alternative: Use System Python

If you prefer to use an existing Python installation:

### Option 1: Create Virtual Environment

```powershell
# Navigate to project root
cd ZULF_NMR_Suite

# Create virtual environment
python -m venv environments\python

# Activate and install dependencies
environments\python\Scripts\activate
pip install -r requirements.txt
```

### Option 2: Use Conda Environment

```powershell
# Create conda environment
conda create -n zulf-nmr python=3.12

# Activate
conda activate zulf-nmr

# Install dependencies
pip install -r requirements.txt
```

**Note**: You'll need to modify launcher scripts to use your environment instead of embedded Python.

---

## For Developers: Adding New Mirrors

To add additional download mirrors, edit the setup scripts:

### PowerShell (`setup_embedded_python.ps1`)

```powershell
$DOWNLOAD_SOURCES = @(
    @{
        Name = "Python.org (Official)"
        URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
    },
    @{
        Name = "Your Mirror Name"
        URL = "https://your-mirror.com/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip"
    }
)
```

### Batch (`setup_embedded_python.bat`)

```batch
set "DOWNLOAD_URL_4=https://your-mirror.com/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "DOWNLOAD_NAME_4=Your Mirror Name"
```

Then add the download attempt logic in the script.

---

## Comparison with Other Approaches

| Approach | Pros | Cons | Recommended? |
|----------|------|------|--------------|
| **Multi-source download** | ✅ Small repo<br>✅ Always latest<br>✅ Secure | ⚠️ Requires internet | **✅ Yes** (Current) |
| Upload to GitHub | ✅ No download needed | ❌ Large repo<br>❌ Platform-specific<br>❌ Security concerns | ❌ No |
| GitHub Releases | ✅ Separate from repo | ❌ Still platform-specific<br>❌ Manual updates | ⚠️ Maybe |
| Cloud Storage (OneDrive, etc.) | ✅ Large files OK | ❌ Requires auth<br>❌ Not version controlled | ❌ No |
| Package manager (Chocolatey, winget) | ✅ Automatic updates | ❌ External dependency<br>❌ Not portable | ⚠️ Maybe |

---

## Troubleshooting

### All Download Sources Fail

**Possible Causes**:
- No internet connection
- Corporate firewall blocking downloads
- DNS resolution issues

**Solutions**:
1. Check internet connection
2. Try downloading manually from https://www.python.org
3. Configure proxy if behind corporate firewall
4. Use system Python instead (see Alternative section)

### Download is Very Slow

**Solutions**:
1. The script will automatically try faster mirrors (China mirrors for Asian users)
2. Use manual download with a download manager
3. Download during off-peak hours

### Downloaded File is Corrupted

**Solutions**:
1. Script will automatically detect and retry
2. Delete `python-embed.zip` and run setup again
3. Verify file size: should be ~30-35 MB

---

## Related Documentation

- [Installation Guide](./INSTALLATION.md) - Complete setup instructions
- [Troubleshooting](../troubleshooting/README.md) - Common issues
- [Optional Packages](../troubleshooting/OPTIONAL_PACKAGES.md) - Package dependencies

---

**Summary**: The multi-source download approach provides the best balance of reliability, security, and repository size. This is the industry-standard approach used by professional software projects.

---

**Last Updated**: October 22, 2025  
**Applies To**: ZULF-NMR Suite v0.1.0 and later
