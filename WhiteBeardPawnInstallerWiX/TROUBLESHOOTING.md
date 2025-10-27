# Complete Build Troubleshooting Guide

## Common Build Errors and Solutions

### Error 1: CS0246 - CustomAction Not Found

**Full Error:**
```
error CS0246: The type or namespace name 'CustomAction' could not be found 
(are you missing a using directive or an assembly reference?)
```

**Cause:** WiX DTF NuGet packages not properly restored

**Fix:**
```bash
# 1. Clean everything
dotnet clean CustomActions\CustomActions.csproj
rmdir /s /q CustomActions\bin
rmdir /s /q CustomActions\obj

# 2. Restore packages
dotnet restore CustomActions\CustomActions.csproj

# 3. Build again
build.bat
```

---

### Error 2: Missing PawnPlugin64.dll

**Error:**
```
WiX Error: The file "Files\PawnPlugin64.dll" was not found.
```

**Cause:** Plugin DLL not placed in Files directory

**Fix:**
```bash
# 1. Copy your DLL to Files directory
copy "C:\your\build\output\PawnPlugin64.dll" Files\PawnPlugin64.dll

# 2. Verify it exists
dir Files\PawnPlugin64.dll

# 3. Retry build
build.bat
```

---

### Error 3: WiX Tools Not Found

**Error:**
```
'wix' is not recognized as an internal or external command
```

**Cause:** WiX Toolset not installed or not in PATH

**Fix:**

**Option A: Install WiX Toolset 4**
1. Download from: https://wixtoolset.org/releases/
2. Run installer
3. Restart command prompt
4. Verify: `wix --version`

**Option B: Add to PATH manually**
```bash
# Find WiX installation (usually)
dir "C:\Program Files (x86)\WiX Toolset v4\bin"

# Add to PATH in environment variables
# Then restart command prompt
```

---

### Error 4: .NET Framework Issues

**Error:**
```
'dotnet' is not recognized
OR
error NETSDK1045: To build a project that targets .NET Framework
```

**Cause:** .NET SDK or Framework not installed

**Fix:**

```bash
# Check what's installed
dotnet --version
dotnet --list-runtimes
dotnet --list-sdks

# Install .NET 8 SDK (includes .NET Framework targeting)
# Download from: https://dotnet.microsoft.com/download

# Or install .NET Framework 4.8
# Download from: https://dotnet.microsoft.com/download/dotnet-framework
```

---

### Error 5: admin privileges Required Error

**Error:**
```
Access denied
OR
Cannot create directory
```

**Cause:** Insufficient permissions

**Fix:**
1. Open Command Prompt as Administrator
2. Navigate to project directory
3. Run `build.bat`

```bash
# Quick check: Are you admin?
echo %username%
```

---

### Error 6: Build Succeeds but No MSI Created

**Error:** No error messages but `bin\WhiteBeardPawnPlugin.msi` not created

**Cause:** Multiple possible issues

**Debug:**
```bash
# Check if intermediate files were created
dir bin\

# Check for error details
dir obj\
type build.log (if exists)

# Rebuild with verbose output
wix build -v diag -o bin\WhiteBeardPawnPlugin.msi Product.wxs CustomDialog.wxs -ext WixToolset.UI.wixext
```

---

### Error 7: CustomActions DLL Not Found During WiX Build

**Error:**
```
The file "path/to/CustomActions.dll" was not found
```

**Cause:** C# build failed silently or path is wrong

**Fix:**
```bash
# 1. Verify C# build succeeded
dir bin\CustomActions.dll

# 2. If not found, rebuild C#
dotnet build CustomActions\CustomActions.csproj -c Release -o bin\

# 3. Check build output
dir bin\

# 4. Retry WiX build
build.bat
```

---

## Step-by-Step Diagnostic

### Quick Health Check

Run this to diagnose your environment:

```bash
@echo off
echo === WhiteBeard Installer Build Diagnostics ===
echo.

echo [1] Checking .NET SDK
dotnet --version
echo.

echo [2] Checking WiX Toolset
wix --version
echo.

echo [3] Checking Required Files
if exist "Files\PawnPlugin64.dll" (
    echo OK: Files\PawnPlugin64.dll exists
) else (
    echo ERROR: Files\PawnPlugin64.dll NOT FOUND
)
echo.

echo [4] Checking Configuration Files
if exist "Product.wxs" echo OK: Product.wxs
if exist "CustomDialog.wxs" echo OK: CustomDialog.wxs
if exist "CustomActions\CustomActions.cs" echo OK: CustomActions.cs
if exist "CustomActions\CustomActions.csproj" echo OK: CustomActions.csproj
echo.

echo [5] Attempting to Build C#
dotnet build CustomActions\CustomActions.csproj -c Release -o bin\
if %errorlevel% equ 0 (
    echo OK: C# build succeeded
    dir bin\CustomActions.dll
) else (
    echo ERROR: C# build failed
)
```

Save as `diagnose.bat` and run it.

---

## Advanced Debugging

### Verbose Build Output

```bash
# Build with maximum verbosity
dotnet build CustomActions\CustomActions.csproj -c Release -v diag

# WiX with diagnostics
wix build -v diag -o bin\WhiteBeardPawnPlugin.msi Product.wxs CustomDialog.wxs
```

### Check NuGet Package Status

```bash
# List WiX packages
dotnet package search wixtoolset

# Check installed packages
dir "%USERPROFILE%\.nuget\packages\wixtoolset*"

# Clear cache if needed
dotnet nuget locals all --clear
```

### Inspect Generated Files

```bash
# View intermediate WiX files
dir obj\

# View generated MSI structure
dark.exe bin\WhiteBeardPawnPlugin.msi -o extracted.wxs
```

---

## Build System Cleanup

### Complete Fresh Start

```bash
@echo off
echo === Cleaning Build System ===

echo [1] Deleting build outputs
rmdir /s /q bin
rmdir /s /q obj
rmdir /s /q CustomActions\bin
rmdir /s /q CustomActions\obj

echo [2] Clearing NuGet cache
dotnet nuget locals all --clear

echo [3] Restoring packages
dotnet restore CustomActions\CustomActions.csproj

echo [4] Building from scratch
build.bat

echo === Done ===
```

---

## Testing Installation After Build

Once build succeeds:

```bash
# Test with verbose logging
msiexec /i bin\WhiteBeardPawnPlugin.msi /l*v install_test.log

# Check for errors in log
findstr /I "ERROR FAIL" install_test.log

# View log
notepad install_test.log
```

---

## Environment Requirements Checklist

- [ ] Windows 10/11 or Server 2016+
- [ ] .NET SDK 6.0+ installed
- [ ] .NET Framework 4.8 installed
- [ ] WiX Toolset 4.0+ installed
- [ ] Visual Studio, VS Code, or Build Tools installed
- [ ] Administrator command prompt
- [ ] Plugin DLL in `Files\` directory
- [ ] Sufficient disk space (2 GB recommended)
- [ ] Antivirus not blocking build process

---

## Common Environment Issues

### Issue: Old Version of WiX Installed

```bash
# Check version
wix --version

# Should be 4.0 or higher
# If older, uninstall and reinstall from
# https://wixtoolset.org/releases/
```

### Issue: Multiple .NET Versions Conflict

```bash
# Check which SDK is active
dotnet --version

# Force specific version by creating global.json
# in project root:
{
  "sdk": {
    "version": "8.0.0"
  }
}
```

### Issue: Build Tools vs Full Visual Studio

WiX requires:
- Visual Studio 2019+ OR
- Visual Studio Build Tools 2019+ OR
- .NET SDK with matching runtime

```bash
# Verify build tools
where msbuild
where dotnet
```

---

## Getting Help

If you're still stuck:

1. **Check logs carefully**
   - WiX build output
   - Custom action build output
   - Installation log

2. **Try reproduction steps**
   - On a clean directory
   - On a different machine
   - With minimal changes

3. **Review documentation**
   - [BUILD_ERROR_FIX.md](BUILD_ERROR_FIX.md)
   - [QUICK_START.md](QUICK_START.md)
   - [README.md](README.md)

4. **Contact Support**
   - WhiteBeard: info@whitebeard.ai
   - WiX Toolset: https://wixtoolset.org/community/

---

## Success Indicators

Build successful if you see:

```
✓ dotnet build completes without errors
✓ CustomActions.dll created (100-200 KB)
✓ WiX compilation completes
✓ bin\WhiteBeardPawnPlugin.msi created (2-5 MB)
✓ No error messages in final output
```

Test successful if:

```
✓ Installer launches
✓ License dialog appears
✓ Installation proceeds
✓ No error messages during installation
✓ Registry entries created
✓ Plugin DLL copied to MT5
```

---

**Version:** 1.0.0  
**Last Updated:** October 25, 2024  
**Status:** ✅ Comprehensive Troubleshooting Guide
