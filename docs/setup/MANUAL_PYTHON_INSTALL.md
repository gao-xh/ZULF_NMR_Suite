# Manual Python Installation Guide

## When to Use This Guide

Use this manual installation method if antivirus software blocks the automatic setup scripts.

---

## Step 1: Download Python

### Method A: Browser Download (Recommended)

1. **Open your browser** (Edge/Chrome/Firefox)

2. **Visit download link** (choose one):

   **Official Source** (international):
   ```
   https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

   **China Mirror** (faster in China):
   ```
   https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

   **Backup Mirror**:
   ```
   https://repo.huaweicloud.com/python/3.12.7/python-3.12.7-embed-amd64.zip
   ```

3. **Save the file**
   - Filename: `python-3.12.7-embed-amd64.zip`
   - Size: ~10-12 MB
   - Save to: Downloads folder

4. **Wait for download to complete**

### Method B: Download Manager (if browser is too slow)

Copy the link above and use Thunder/IDM/Free Download Manager.

---

## Step 2: Extract Files

1. **Locate the downloaded file**
   - Path: `C:\Users\YourUsername\Downloads\python-3.12.7-embed-amd64.zip`

2. **Right-click the ZIP file** → **Extract All** or **Extract Here**

3. **Copy all extracted files** (not the folder itself, but the files inside)

4. **Paste into**:
   ```
   C:\Users\YourUsername\Desktop\ZULF_NMR_Suite\environments\python\
   ```

5. **Verify file structure**:
   ```
   environments\python\
   ├── python.exe          ✅ Must have this file
   ├── python312.dll
   ├── python3.dll
   ├── python312._pth
   ├── python312.zip
   └── ... (other DLL files)
   ```

---

## Step 3: Run Manual Setup Script

1. **Double-click to run**:
   ```
   environments\python\manual_setup.bat
   ```

2. **The script will automatically**:
   - ✅ Detect if Python is correctly extracted
   - ✅ Configure Python environment
   - ✅ Install pip (package manager)
   - ✅ Install all dependencies

3. **Wait for completion** (~5-10 minutes)

---

## Troubleshooting

### Q1: Antivirus still blocks `manual_setup.bat`?

**Solution 1**: Add to whitelist
1. Open Windows Security
2. Virus & threat protection → Manage settings
3. Add exclusions → Folder
4. Select: `C:\Users\YourUsername\Desktop\ZULF_NMR_Suite\environments\python\`

**Solution 2**: Use PowerShell (safer)
1. Right-click `environments\python` folder
2. Select "Open in Terminal"
3. Run:
   ```powershell
   python.exe -m pip install --upgrade pip setuptools wheel
   python.exe -m pip install -r ..\..\requirements.txt
   ```

### Q2: Downloaded file was deleted by antivirus?

1. Check Windows Security "Protection history"
2. Find the quarantined file
3. Click "Actions" → "Restore"
4. Then add the folder to exclusions

### Q3: Download too slow?

Use China mirror:
```
https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-embed-amd64.zip
```

Or use a download manager like Thunder/IDM.

### Q4: Cannot find `python.exe` after extraction?

Make sure you copied the **contents** of the ZIP file, not the outer folder.

Correct structure:
```
environments\python\python.exe  ✅
```

Wrong structure:
```
environments\python\python-3.12.7-embed-amd64\python.exe  ❌
```

---

## Verify Installation

In PowerShell:

```powershell
cd C:\Users\YourUsername\Desktop\ZULF_NMR_Suite
.\environments\python\python.exe --version
```

Should display:
```
Python 3.12.7
```

Check PySide6 (GUI library):
```powershell
.\environments\python\python.exe -c "import PySide6; print('PySide6 OK')"
```

Should display:
```
PySide6 OK
```

---

## Next Steps

After installation:

1. **Update config file** `config.txt`:
   ```
   PYTHON_ENV_PATH = environments/python/python.exe
   ```

2. **Run the application**:
   ```
   start.bat
   ```

---

## If Problems Persist

1. See detailed docs: `docs/troubleshooting/ANTIVIRUS_FALSE_POSITIVE.md`
2. GitHub Issues: https://github.com/gao-xh/ZULF_NMR_Suite/issues
3. Include screenshots of:
   - Antivirus blocking message
   - Folder contents (proving python.exe exists)
   - Script error messages

---

## Security Note

- ✅ Python from official python.org
- ✅ SHA256 checksum verifiable on official site
- ✅ Millions of developers worldwide use the same file
- ✅ This is NOT a virus - antivirus false positive
