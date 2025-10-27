# 🎯 Complete Setup & Build Guide

## Overview

You now have a complete, production-ready WiX Toolset 4 installer for the WhiteBeard Pawn Plugin with **PawnPlugin64.dll already in place**.

---

## ✅ What's Ready

| Component | Status | Location |
|-----------|--------|----------|
| **WiX Installer Config** | ✅ Ready | `Product.wxs` |
| **UI Dialogs** | ✅ Ready | `CustomDialog.wxs` |
| **C# Custom Actions** | ✅ Ready | `CustomActions/CustomActions.cs` |
| **Plugin DLL** | ✅ Present | `Files/PawnPlugin64.dll` |
| **Build Scripts** | ✅ Ready | `build.bat` |
| **Documentation** | ✅ Complete | Multiple `.md` files |

---

## 🚀 Quick Build (3 Steps)

### Step 1: Open Command Prompt as Administrator

```bash
# Press: Win + X, then select "Command Prompt (Admin)"
# OR right-click cmd.exe → "Run as Administrator"
```

### Step 2: Navigate to Project

```bash
cd C:\Users\Haard\Desktop\plugin\WhiteBeardPawnInstallerWiX
```

### Step 3: Run Build

```bash
build.bat
```

**Output:** `bin\WhiteBeardPawnPlugin.msi` (2-5 MB)

---

## 📋 Pre-Build Checklist

Before running `build.bat`, verify:

### 1. Environment
- [ ] Windows 10/11 or Server
- [ ] Administrator command prompt
- [ ] .NET SDK installed: `dotnet --version`
- [ ] WiX Toolset 4 installed: `wix --version`
- [ ] 2+ GB free disk space

### 2. Project Files
- [ ] `CustomActions/CustomActions.cs` exists
- [ ] `CustomActions/CustomActions.csproj` exists
- [ ] `Files/PawnPlugin64.dll` exists (binary file)
- [ ] `Product.wxs` exists
- [ ] `CustomDialog.wxs` exists

### 3. Configuration
- [ ] Update API endpoint in `CustomActions.cs` (optional)
- [ ] Verify MT5 default path (optional)
- [ ] Check license search directory (optional)

### 4. DLL Verification
```bash
# Check DLL exists and is valid
dir Files\PawnPlugin64.dll
# Should show: PawnPlugin64.dll with size > 100 KB
```

---

## 🔧 Configuration (Optional)

### Change API Verification Endpoint

**File:** `CustomActions/CustomActions.cs` (Line 28)

```csharp
// Current
private const string VERIFY_API_URL = "https://yourserver.com/verify";

// Change to your endpoint
private const string VERIFY_API_URL = "https://api.yourcompany.com/license/verify";
```

### Change MT5 Default Path

**File:** `CustomActions/CustomActions.cs` (Line 29)

```csharp
// Current
private const string MT5_DEFAULT_PATH = @"C:\MetaTrader 5 Platform\TradeMain";

// Change if MT5 installed elsewhere
private const string MT5_DEFAULT_PATH = @"C:\Program Files\MetaTrader 5\TradeMain";
```

### Change License Search Directory

**File:** `CustomActions/CustomActions.cs` (Line 27)

```csharp
// Current
private const string LICENSE_SEARCH_DIR = @"C:\ProgramData\WhiteBeard";

// Change if needed
private const string LICENSE_SEARCH_DIR = @"C:\ProgramData\YourCompany";
```

---

## 🏗️ Build Process (Detailed)

When you run `build.bat`, it:

```
1. Clean previous builds
   ├─ Remove bin/ directory
   └─ Remove obj/ directory

2. Build C# Custom Actions
   ├─ Restore NuGet packages
   ├─ Compile CustomActions.cs
   └─ Output: bin\CustomActions.dll

3. Copy Files
   ├─ Copy CustomActions.dll to project root
   └─ Prepare for WiX packaging

4. Compile WiX Source Files
   ├─ Process Product.wxs
   ├─ Process CustomDialog.wxs
   ├─ Embed CustomActions.dll
   ├─ Embed Files\PawnPlugin64.dll
   └─ Output: bin\WhiteBeardPawnPlugin.msi

5. Verify Output
   ├─ Check MSI was created
   ├─ Verify file size
   └─ Display success message
```

---

## 📊 Build Output

After successful build:

```
bin/
├── WhiteBeardPawnPlugin.msi    (Main installer - 2-5 MB)
├── CustomActions.dll            (Custom actions library)
├── Product.wixobj              (Intermediate WiX object)
└── CustomDialog.wixobj         (Intermediate WiX object)
```

The **MSI file** is what you distribute to users.

---

## 🧪 Testing After Build

### Test 1: Verify MSI Creation

```bash
# Check file exists and has reasonable size
dir bin\WhiteBeardPawnPlugin.msi

# Should show file size between 2-5 MB
```

### Test 2: Run Installer

```bash
# Interactive installation (recommended for first test)
bin\WhiteBeardPawnPlugin.msi

# OR with verbose logging
msiexec /i bin\WhiteBeardPawnPlugin.msi /l*v install_test.log
```

### Test 3: Verify Installation

```bash
# Check plugin copied to MT5
dir "C:\MetaTrader 5 Platform\TradeMain\Plugins\PawnPlugin64.dll"

# Check license in ProgramData
dir C:\ProgramData\WhiteBeard\

# Check registry entries
reg query HKLM\Software\WhiteBeard\PawnPlugin

# View detailed log
notepad install_test.log
```

---

## 📁 Project Structure

```
WhiteBeardPawnInstallerWiX/
│
├── Files/                          ← Plugin DLL location
│   ├── PawnPlugin64.dll           ✅ Your plugin (present)
│   └── README.md                   (Instructions)
│
├── CustomActions/                  ← C# implementation
│   ├── CustomActions.cs           (650+ lines)
│   ├── CustomActions.csproj       (Updated)
│   ├── bin/                        (Build output)
│   └── obj/                        (Intermediate)
│
├── Product.wxs                    (Main config - 430 lines)
├── CustomDialog.wxs               (UI dialogs - 200 lines)
├── Product_Enhanced.wxs           (Documented version)
│
├── build.bat                       (Windows build script)
├── build.sh                        (Unix reference)
│
├── Documentation/
│   ├── README.md                  (Complete guide)
│   ├── QUICK_START.md             (5-minute setup)
│   ├── ARCHITECTURE.md            (System design)
│   ├── PLUGIN_DLL_GUIDE.md        (DLL handling)
│   ├── TROUBLESHOOTING.md         (Error solutions)
│   ├── BUILD_ERROR_FIX.md         (CS0246 fix)
│   ├── INDEX.md                   (Navigation)
│   ├── BUILD_SUMMARY.md           (Overview)
│   └── DELIVERABLES.md            (What's included)
│
├── example_license.lic            (Sample for testing)
│
├── bin/                           (Build output - created after build.bat)
│   └── WhiteBeardPawnPlugin.msi   (Your installer)
│
└── obj/                           (Intermediate - created during build)
    └── [build artifacts]
```

---

## 🎯 Complete Workflow

### Phase 1: Preparation
```bash
# 1. Verify environment
dotnet --version          # Should be 6.0+
wix --version            # Should be 4.0+

# 2. Check DLL exists
dir Files\PawnPlugin64.dll

# 3. Navigate to project
cd WhiteBeardPawnInstallerWiX
```

### Phase 2: Configuration (Optional)
```
Edit CustomActions.cs for:
- API endpoint URL
- MT5 default path
- License search directory
```

### Phase 3: Build
```bash
# Run build script (as Admin)
build.bat

# Output: bin\WhiteBeardPawnPlugin.msi
```

### Phase 4: Test
```bash
# Install and verify
msiexec /i bin\WhiteBeardPawnPlugin.msi /l*v test.log

# Check results
reg query HKLM\Software\WhiteBeard\PawnPlugin
dir "C:\MetaTrader 5 Platform\TradeMain\Plugins\PawnPlugin64.dll"
```

### Phase 5: Deploy
```bash
# Sign MSI (optional but recommended)
signtool sign /f cert.pfx /p password bin\WhiteBeardPawnPlugin.msi

# Distribute
# Upload to web server or share location
```

---

## ⚠️ Common Issues & Fixes

### Issue: Build Fails - CS0246

**Error:** "The type or namespace name 'CustomAction' could not be found"

**Fix:**
```bash
dotnet clean CustomActions\CustomActions.csproj
dotnet restore CustomActions\CustomActions.csproj
build.bat
```

See: [BUILD_ERROR_FIX.md](BUILD_ERROR_FIX.md)

### Issue: DLL Not Found

**Error:** "Files\PawnPlugin64.dll" was not found

**Verify:**
```bash
dir Files\PawnPlugin64.dll
```

**If missing:** Copy your plugin DLL to `Files\` directory

### Issue: WiX Not Found

**Error:** "'wix' is not recognized as an internal or external command"

**Fix:**
1. Install WiX Toolset 4: https://wixtoolset.org/
2. Restart command prompt
3. Verify: `wix --version`

### Issue: Not Running as Admin

**Error:** "Access denied" or "Cannot create file"

**Fix:**
1. Open Command Prompt as Administrator
2. Run `build.bat` again

---

## 📚 Documentation

| File | Purpose | Read Time |
|------|---------|-----------|
| [QUICK_START.md](QUICK_START.md) | Get started in 5 minutes | 5 min |
| [README.md](README.md) | Complete technical guide | 20 min |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design | 15 min |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Error solutions | 10 min |
| [PLUGIN_DLL_GUIDE.md](PLUGIN_DLL_GUIDE.md) | DLL handling | 15 min |
| [BUILD_ERROR_FIX.md](BUILD_ERROR_FIX.md) | CS0246 error fix | 5 min |

---

## ✅ Success Indicators

### Build Successful if:
```
✓ No error messages
✓ bin\WhiteBeardPawnPlugin.msi created
✓ MSI file size 2-5 MB
✓ Installation proceeds when run
```

### Installation Successful if:
```
✓ All dialogs appear
✓ License validated
✓ API verification passes
✓ MT5 detected
✓ Plugin DLL copied
✓ License file copied
✓ Registry entries created
✓ Completion dialog shown
```

---

## 🎓 Next Steps

1. **Run Build:** `build.bat`
2. **Test Installation:** Run the MSI
3. **Verify Deployment:** Check files and registry
4. **Customize:** Update API endpoint and paths
5. **Sign MSI:** Add code signing certificate
6. **Deploy:** Distribute to users

---

## 📞 Support Resources

| Issue | Resource |
|-------|----------|
| Build errors | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| CustomAction errors | [BUILD_ERROR_FIX.md](BUILD_ERROR_FIX.md) |
| Plugin DLL issues | [PLUGIN_DLL_GUIDE.md](PLUGIN_DLL_GUIDE.md) |
| General setup | [QUICK_START.md](QUICK_START.md) |
| System architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |

---

## 🎉 You're Ready!

Your installer is fully configured and ready to build. Just run:

```bash
build.bat
```

The `bin\WhiteBeardPawnPlugin.msi` will be created and ready for testing and deployment.

**Good luck! 🚀**

---

**Version:** 1.0.0  
**Last Updated:** October 25, 2024  
**Status:** ✅ Ready to Build and Deploy
