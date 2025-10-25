# WhiteBeard Pawn Plugin Installer - Architecture & Design

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Windows Installer (MSI)                      │
└─────────────────────────────────────────────────────────────────┘
         │
         ├──> Product.wxs (Main Configuration)
         │       ├─ Product metadata
         │       ├─ Directory structure
         │       ├─ Features & components
         │       ├─ Custom actions references
         │       └─ UI sequence definition
         │
         ├──> CustomDialog.wxs (UI Dialogs)
         │       ├─ License Selection Dialog
         │       ├─ Company Info Dialog
         │       ├─ MT5 Directory Dialog
         │       └─ License Agreement Dialog
         │
         └──> CustomActions.dll (C# Logic)
                 ├─ SearchAndValidateLicense()
                 ├─ VerifyLicenseWithAPI()
                 ├─ DetectMT5Directory()
                 └─ InstallPluginFiles()
```

## 🔄 Installation Flow

```
START
  │
  ├─> Welcome Dialog
  │     └─> Show introduction
  │
  ├─> SearchAndValidateLicense (Custom Action)
  │     ├─> Search C:\ProgramData\WhiteBeard for *_pawn_plugin.lic
  │     ├─> If not found, prompt user to browse
  │     ├─> Extract company info (decrypt if needed)
  │     └─> Populate LICENSE_PATH, COMPANY_NAME, COMPANY_EMAIL
  │
  ├─> License Selection Dialog
  │     └─> Display selected license file path
  │
  ├─> VerifyLicenseWithAPI (Custom Action)
  │     ├─> Call POST https://yourserver.com/verify
  │     ├─> Send: companyName, companyEmail, licenseFile
  │     ├─> If HTTP 200: Success
  │     └─> If error: Abort with error message
  │
  ├─> Company Info Dialog
  │     ├─> Display Company Name (extracted from license)
  │     ├─> Display Company Email (extracted from license)
  │     └─> Display License File Path
  │
  ├─> DetectMT5Directory (Custom Action)
  │     ├─> Check Registry: HKEY_LOCAL_MACHINE\SOFTWARE\MetaQuotes\MetaTrader 5
  │     ├─> Check default: C:\MetaTrader 5 Platform\TradeMain
  │     ├─> If not found, prompt user to browse
  │     └─> Populate MT5_ROOT
  │
  ├─> MT5 Directory Dialog
  │     └─> Display detected/selected MT5 directory
  │
  ├─> License Agreement Dialog
  │     ├─> Show EULA
  │     ├─> Require checkbox acceptance
  │     └─> Enable Install button only when accepted
  │
  ├─> Installation Progress
  │     └─> Show progress bar
  │
  ├─> InstallPluginFiles (Custom Action)
  │     ├─> Check admin privileges
  │     ├─> Create directories if needed:
  │     │   ├─ [MT5_ROOT]\Plugins
  │     │   └─ C:\ProgramData\WhiteBeard
  │     ├─> Copy files:
  │     │   ├─ PawnPlugin64.dll → [MT5_ROOT]\Plugins\
  │     │   └─ License file → C:\ProgramData\WhiteBeard\
  │     ├─> Register in Windows Registry
  │     └─> Log all operations
  │
  ├─> Success Dialog
  │     └─> Show completion message
  │
  END
```

## 🗂️ File Organization

```
WhiteBeardPawnInstallerWiX/
│
├── CustomActions/
│   ├── CustomActions.cs              [C# implementation]
│   └── CustomActions.csproj          [Project file]
│
├── Product.wxs                       [Main WiX definition]
├── Product_Enhanced.wxs              [Enhanced version with docs]
├── CustomDialog.wxs                  [UI dialogs]
│
├── build.bat                         [Windows build script]
├── build.sh                          [Unix build script]
│
├── example_license.lic               [Example license template]
│
├── README.md                         [Detailed documentation]
├── QUICK_START.md                    [Quick start guide]
├── ARCHITECTURE.md                   [This file]
│
├── bin/                              [Build output]
│   └── WhiteBeardPawnPlugin.msi      [Generated installer]
│
└── obj/                              [Intermediate files]
    └── [compiled objects]
```

## 🔐 Security Considerations

### 1. **License File Security**
```
┌─ License File (*.lic)
├─ XML or text format
├─ Contains: CompanyName, CompanyEmail, LicenseKey
├─ Should be: Encrypted/signed in production
└─ Stored in: C:\ProgramData\WhiteBeard (restricted access)
```

### 2. **API Communication**
```
POST https://yourserver.com/verify
├─ HTTPS required for secure transmission
├─ Verify SSL certificate
├─ Send license file as multipart/form-data
├─ Validate API response
└─ Log all communication for audit
```

### 3. **Registry Protection**
```
HKEY_LOCAL_MACHINE\Software\WhiteBeard\PawnPlugin
├─ Requires admin to write
├─ Tracks installation state
└─ Records version information
```

### 4. **File Permissions**
```
C:\ProgramData\WhiteBeard\
├─ Restricted access (SYSTEM, Admins only)
└─ Contains license and configuration data

[MT5_ROOT]\Plugins\
├─ Write access needed
└─ Contains plugin binary
```

## 🎯 Key Components

### CustomActions.cs Functions

| Function | Purpose | Timing |
|----------|---------|--------|
| `SearchAndValidateLicense` | Find and validate license file | UI Phase |
| `DecryptLicenseInfo` | Extract company data from license | UI Phase |
| `VerifyLicenseWithAPI` | Verify with remote server | UI Phase |
| `DetectMT5Directory` | Find MT5 installation | UI Phase |
| `GetMT5PathFromRegistry` | Check registry for MT5 | Helper |
| `InstallPluginFiles` | Copy files to destinations | Install Phase |
| `HasAdminRights` | Check admin privileges | Install Phase |

### Product.wxs Components

| Component | Purpose |
|-----------|---------|
| `PluginFilesComponent` | Contains PawnPlugin64.dll |
| `RegistryEntriesComponent` | Windows registry entries |
| Custom Actions | DLL references and definitions |
| UI Dialogs | User interface sequence |

### CustomDialog.wxs Dialogs

| Dialog | Purpose |
|--------|---------|
| `LicenseSelectionDlg` | Select/confirm license file |
| `CompanyInfoDlg` | Display company details |
| `MT5DirectoryDlg` | Select MT5 directory |
| `LicenseAgreementDlg` | Accept EULA |

## 📊 Data Flow

```
User
  │
  ├─> Provides License File Path
  │     │
  │     ├─> CustomActions reads file
  │     ├─> Decrypts/parses company info
  │     └─> Validates format
  │
  ├─> Accepts License Agreement
  │     │
  │     └─> CustomActions sends to API
  │          ├─> API validates
  │          └─> Confirms authenticity
  │
  ├─> Confirms MT5 Directory
  │     │
  │     └─> CustomActions verifies path
  │
  ├─> Installation Begins
  │     │
  │     ├─> Copy files to MT5
  │     ├─> Copy license to ProgramData
  │     ├─> Register in Windows
  │     └─> Create log entries
  │
  └─> Installation Complete
```

## 🔍 Property Variables

| Property | Set By | Used For |
|----------|--------|----------|
| `LICENSE_PATH` | CustomAction | Dialog display, file operations |
| `COMPANY_NAME` | License file | Dialog display, API call |
| `COMPANY_EMAIL` | License file | Dialog display, API call |
| `MT5_ROOT` | Registry/Browse | Plugin installation path |
| `LICENSE_AGREEMENT_ACCEPTED` | User checkbox | Enable Install button |
| `INSTALLDIR` | WiX | Source for files |

## 🚀 Deployment Scenarios

### Scenario 1: Corporate Environment
```
Scenario: Large IT department
├─ License file pre-deployed to C:\ProgramData\WhiteBeard
├─ MT5 already installed on all machines
├─ Run installer with /quiet flag
└─ Results: Fully automated, no user interaction
```

### Scenario 2: Individual User
```
Scenario: Single trader
├─ License file on USB or email
├─ MT5 may or may not be installed
├─ Run installer interactively
└─ Results: User-guided with dialogs
```

### Scenario 3: Troubleshooting
```
Scenario: Installation fails
├─ Check log: msiexec /i setup.msi /l*v debug.log
├─ Verify prerequisites
├─ Rollback and retry
└─ Contact support with logs
```

## 🔧 Extensibility

### Adding New Custom Actions

1. **Add method to CustomActions.cs:**
```csharp
[CustomAction]
public static ActionResult MyNewAction(Session session)
{
    try
    {
        session.Log("Executing MyNewAction");
        // Implementation
        return ActionResult.Success;
    }
    catch (Exception ex)
    {
        session.Log($"ERROR: {ex.Message}");
        return ActionResult.Failure;
    }
}
```

2. **Reference in Product.wxs:**
```xml
<CustomAction 
    Id="MyNewActionId"
    BinaryRef="CustomActionsBinary"
    DllEntry="MyNewAction"
    Execute="immediate"
    Return="check"
    Impersonate="no" />
```

3. **Add to sequence:**
```xml
<Custom Action="MyNewActionId" After="SomeOtherAction" />
```

### Adding New Dialogs

1. **Add to CustomDialog.wxs:**
```xml
<Dialog Id="MyNewDlg" Width="370" Height="270" Title="My Dialog">
    <!-- Controls -->
</Dialog>
```

2. **Reference in Product.wxs:**
```xml
<DialogRef Id="MyNewDlg" />
```

3. **Add to dialog sequence:**
```xml
<Publish Dialog="PreviousDlg" Control="NextButton" 
         Event="NewDialog" Value="MyNewDlg" />
```

## 📈 Performance Considerations

| Operation | Time | Notes |
|-----------|------|-------|
| License search | < 1s | Local file search |
| API verification | 2-5s | Network dependent |
| MT5 detection | < 1s | Registry + file check |
| File copy | 1-10s | Size dependent |
| **Total** | **~10-20s** | Normal installation |

## 🛡️ Error Handling

```
Error Scenarios:
├─ License file not found
│   └─ Prompt user to browse
├─ License invalid format
│   └─ Show error, ask for different file
├─ API verification fails
│   └─ Show support contact info
├─ Admin rights missing
│   └─ Abort with privilege error
├─ MT5 not found
│   └─ Prompt user to locate
└─ File copy fails
    └─ Log error, abort installation
```

## 📝 Logging

All operations logged to Windows Installer log:

```bash
# View installation log
msiexec /i setup.msi /l*v installation.log

# Log includes:
# - Custom action calls
# - File operations
# - Registry changes
# - Error messages
# - Timestamps
```

## 🎓 Best Practices

1. **Always verify prerequisites** before installation
2. **Log every critical operation** for troubleshooting
3. **Use rollback** on installation failure
4. **Sign code and binaries** for production
5. **Test on multiple Windows versions**
6. **Provide clear error messages** to users
7. **Document all customizations** for future maintenance
8. **Use HTTPS** for API communication
9. **Encrypt sensitive data** in transit and at rest
10. **Monitor installation failures** for improvements

---

**Document Version:** 1.0  
**Last Updated:** October 2024  
**Author:** WhiteBeard Development Team
