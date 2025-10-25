# Plugin DLL Files Directory

This directory contains the plugin binary files that will be packaged into the installer.

## File Structure

```
Files/
├── PawnPlugin64.dll      (Your actual 64-bit plugin DLL)
└── README.md             (This file)
```

## ⚠️ IMPORTANT: DLL Placement

### What Goes Here

Place your compiled `PawnPlugin64.dll` file in this directory:

```
WhiteBeardPawnInstallerWiX/Files/PawnPlugin64.dll
```

### File Requirements

| Property | Value |
|----------|-------|
| **Filename** | `PawnPlugin64.dll` |
| **Architecture** | 64-bit (x64) |
| **File Size** | Typically 2-10 MB |
| **Status** | Must be present before building |
| **Format** | Windows DLL (PE format) |

### Getting Your DLL

Your DLL should be:
1. Compiled for Windows x64 architecture
2. Compatible with MetaTrader 5
3. Fully tested and validated
4. Named exactly `PawnPlugin64.dll`

## 🛠️ Build Process

### Before Building the Installer

```bash
# 1. Copy your compiled DLL to this directory
copy "C:\your\build\output\PawnPlugin64.dll" "Files\PawnPlugin64.dll"

# 2. Verify the file exists
dir Files\PawnPlugin64.dll

# 3. Now build the installer
build.bat
```

## 📝 WiX Configuration

The installer is configured to use the DLL from this location:

**File:** `Product.wxs` (Line ~415)

```xml
<File Id="PluginDLL" Name="PawnPlugin64.dll" 
      Source="Files\PawnPlugin64.dll"
      Vital="yes"
      KeyPath="yes" />
```

### If You Change the Location

If you want to place the DLL elsewhere, update this line in `Product.wxs`:

```xml
<File Id="PluginDLL" Name="PawnPlugin64.dll" 
      Source="path/to/your/PawnPlugin64.dll" />
```

## 🔍 Installation Destinations

After building the installer, the DLL will be:

1. **Embedded in MSI** during packaging
2. **Extracted to Installation Directory**: `C:\Program Files\WhiteBeard\Pawn Plugin\PawnPlugin64.dll` (master copy)
3. **Deployed to MT5**: `[MT5_ROOT]\Plugins\PawnPlugin64.dll` (working copy)

```
Installation Flow:
┌─────────────────┐
│  PawnPlugin     │
│  64.dll (here)  │
└────────┬────────┘
         │
         ├─> MSI Packaging
         │
         ├─> Installation Directory
         │   C:\Program Files\WhiteBeard\Pawn Plugin\
         │
         └─> MT5 Plugins Directory
             C:\MetaTrader 5 Platform\TradeMain\Plugins\
```

## ✅ Checklist Before Building

- [ ] `PawnPlugin64.dll` file exists
- [ ] File is in `Files/` directory
- [ ] File is 64-bit (x64) architecture
- [ ] File size is reasonable (2-10 MB typical)
- [ ] File is named exactly `PawnPlugin64.dll`
- [ ] `Product.wxs` points to correct location
- [ ] DLL has been tested independently
- [ ] No other DLL files in this directory

## 📦 Build Command

Once DLL is in place:

```bash
# Navigate to project root
cd WhiteBeardPawnInstallerWiX

# Build (DLL will be automatically included)
build.bat

# Output: bin\WhiteBeardPawnPlugin.msi
```

## 🐛 Troubleshooting

### "Source file not found" Error

**Problem:** Build fails with "Files\PawnPlugin64.dll not found"

**Solution:**
1. Check DLL exists: `dir Files\PawnPlugin64.dll`
2. Verify filename spelling (case-sensitive on some systems)
3. Check file is readable: `attrib Files\PawnPlugin64.dll`
4. Rebuild: `build.bat`

### MSI Build Succeeds but DLL Not Included

**Problem:** Installer built successfully but DLL seems missing

**Solution:**
1. Verify DLL was in `Files\` during build
2. Check `build.bat` console output for errors
3. Inspect MSI with WiX Toolset tools:
   ```bash
   dark.exe bin\WhiteBeardPawnPlugin.msi -o extracted.wxs
   ```

### DLL Not Copied to MT5 Directory After Installation

**Problem:** Installer runs but DLL not found in `[MT5_ROOT]\Plugins\`

**Solution:**
1. Check installation log:
   ```bash
   msiexec /i bin\WhiteBeardPawnPlugin.msi /l*v install.log
   notepad install.log
   ```
2. Look for `[SUCCESS] Copied plugin DLL` message
3. Verify MT5 directory was detected correctly
4. Check file permissions on MT5 Plugins directory

## 📚 Related Documentation

- [PLUGIN_DLL_GUIDE.md](../PLUGIN_DLL_GUIDE.md) - Complete plugin installation guide
- [QUICK_START.md](../QUICK_START.md) - Quick start guide
- [README.md](../README.md) - Full technical documentation

## 🎯 Key Points

✅ Place `PawnPlugin64.dll` in this `Files/` directory  
✅ File must be 64-bit Windows DLL  
✅ File must be named exactly `PawnPlugin64.dll`  
✅ File must exist before running `build.bat`  
✅ Installer will embed and deploy it automatically  

---

**Version:** 1.0.0  
**Last Updated:** October 25, 2024  
**Status:** ✅ Ready for DLL Placement
