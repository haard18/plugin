# WhiteBeard Pawn Plugin Installer - WiX Toolset 4

## Overview

This is a complete Windows Installer solution for the **WhiteBeard Pawn Plugin** built with **WiX Toolset 4**. The installer:

- ✅ Validates license files
- ✅ Verifies licenses with a remote API
- ✅ Detects MetaTrader 5 installation
- ✅ **Automatically deploys PawnPlugin64.dll to MT5\Plugins**
- ✅ Backs up existing plugins before overwriting
- ✅ Copies license files to system storage
- ✅ Logs all operations for troubleshooting

## Project Structure

```
WhiteBeardPawnInstallerWiX/
├── CustomActions/
│   ├── CustomActions.cs              # C# implementation
│   ├── CustomActions.csproj          # Project file
│   └── Properties/
│       └── [auto-generated]
├── Files/
│   └── PawnPlugin64.dll              # Plugin binary (place your DLL here)
├── Product.wxs                       # Main WiX installer definition
├── CustomDialog.wxs                  # UI dialogs
│
├── build.bat                         # Windows build script
├── build.sh                          # Unix build script
│
├── example_license.lic               # Example license template
│
├── README.md                         # Detailed documentation
├── QUICK_START.md                    # Quick start guide
├── ARCHITECTURE.md                   # System design
│
├── bin/                              # Build output
│   └── WhiteBeardPawnPlugin.msi      # Generated installer
│
└── obj/                              # Intermediate files
    └── [compiled objects]
```
## Prerequisites

### Required Software

1. **WiX Toolset 4** - Download from [wixtoolset.org](https://wixtoolset.org/)
   - Includes `wix.exe` CLI and Visual Studio integration

2. **.NET Framework 4.8** - Already installed on most Windows systems

3. **Visual Studio 2019+ or Visual Studio Code** (optional, for editing)

4. **C# Compiler** - Included with Visual Studio or can use `dotnet` CLI

### Optional

- **Visual Studio Extension**: WiX Toolset Visual Studio Extension for GUI support

## Building the Installer

### Method 1: Using WiX CLI (Recommended)

```bash
# 1. Navigate to the project directory
cd WhiteBeardPawnInstallerWiX

# 2. Compile the C# custom actions DLL
dotnet build CustomActions/CustomActions.csproj -c Release -o bin/

# 3. Copy the DLL to accessible location for WiX
cp bin/CustomActions.dll ./

# 4. Compile WiX source files
wix build -o bin/WhiteBeardPawnPlugin.msi Product.wxs CustomDialog.wxs -ext WixToolset.UI.wixext

# 5. The MSI will be generated at: bin/WhiteBeardPawnPlugin.msi
```

### Method 2: Using Visual Studio

1. Open Visual Studio
2. Create a new **WiX Setup Project**
3. Copy the `.wxs` files into the project
4. Add reference to the custom actions project
5. Build the solution (Ctrl+Shift+B)
6. Output MSI will be in `bin\Release\`

### Method 3: Using Command Line (Legacy)

```bash
# Compile C# custom actions
csc.exe /target:library /out:CustomActions.dll CustomActions/CustomActions.cs

# Compile WiX
candle.exe Product.wxs CustomDialog.wxs -o obj\
light.exe -out bin\WhiteBeardPawnPlugin.msi obj\Product.wixobj obj\CustomDialog.wixobj
```

## Configuration Before Building

### 1. Place Plugin DLL in Files Directory

Copy your compiled `PawnPlugin64.dll` to the `Files/` directory:

```bash
# Copy your DLL
copy "C:\your\build\output\PawnPlugin64.dll" "Files\PawnPlugin64.dll"

# Verify it exists
dir Files\PawnPlugin64.dll
```

**Important:** The DLL must exist at `Files\PawnPlugin64.dll` before building the installer.

### 2. Update API Verification Endpoint

In **CustomActions.cs**, update the verification API URL:

```csharp
private const string VERIFY_API_URL = "https://yourserver.com/verify";
```

### 3. Configure MT5 Detection

The installer automatically checks:
1. Windows Registry: `HKEY_LOCAL_MACHINE\SOFTWARE\MetaQuotes\MetaTrader 5`
2. Default Path: `C:\MetaTrader 5 Platform\TradeMain`
3. User browse dialog if both above fail

To customize, modify in **CustomActions.cs**:

```csharp
private const string MT5_DEFAULT_PATH = @"C:\MetaTrader 5 Platform\TradeMain";
```

### 4. License File Location

Default search directory for license files:

```csharp
private const string LICENSE_SEARCH_DIR = @"C:\ProgramData\WhiteBeard";
```

License files must end with `_pawn_plugin.lic` pattern.

## Testing the Installer

### 1. Create a Test License File

Create a file named `test_pawn_plugin.lic` in `C:\ProgramData\WhiteBeard\`:

**XML Format Example:**
```xml
<?xml version="1.0"?>
<License>
  <CompanyName>Test Company</CompanyName>
  <CompanyEmail>test@example.com</CompanyEmail>
  <LicenseKey>TEST-KEY-12345</LicenseKey>
  <ExpirationDate>2025-12-31</ExpirationDate>
</License>
```

**Text Format Example:**
```
CompanyName=Test Company
CompanyEmail=test@example.com
LicenseKey=TEST-KEY-12345
```

### 2. Mock the API Verification

For testing without a real API endpoint, modify the API verification logic in **CustomActions.cs** to return success:

```csharp
private static async Task<bool> VerifyLicenseAsync(Session session, string licenseFilePath, string companyName, string companyEmail)
{
    // For testing: return true immediately
    session.Log("License verification skipped for testing");
    return true;
}
```

### 3. Install from Command Line

```bash
# Run installer with verbose logging
msiexec /i WhiteBeardPawnPlugin.msi /l*v install_log.txt

# Uninstall
msiexec /x WhiteBeardPawnPlugin.msi
```

### 4. Check Installation Log

View the detailed log file:
```bash
notepad install_log.txt
```

## Installer Workflow

### User Experience Flow

1. **Welcome Screen** - Introduction and overview
2. **License Selection** - Browse for license file
   - Auto-searches `C:\ProgramData\WhiteBeard`
   - Falls back to file browser if not found
3. **Company Info** - Display extracted company details
4. **MT5 Directory** - Detect or select MT5 installation
5. **License Agreement** - User accepts EULA
6. **Installation** - Files copied and registered
7. **Completion** - Success or error message

### File Operations

The installer performs:

```
License File: [LICENSE_PATH]
    ↓
    Copied to: C:\ProgramData\WhiteBeard\[license_filename]

PawnPlugin64.dll: [INSTALLDIR]\PawnPlugin64.dll
    ↓
    Copied to: [MT5_ROOT]\Plugins\PawnPlugin64.dll
```

### Registry Entries

Created during installation:
```
HKEY_LOCAL_MACHINE\Software\WhiteBeard\PawnPlugin
  ├── Installed = 1
  └── LicenseVersion = 1.0
```

## Troubleshooting

### Issue: "Admin Rights Required"

**Solution:** Run the installer with administrator privileges:
```bash
# Right-click and select "Run as Administrator"
# OR use command line:
msiexec /i WhiteBeardPawnPlugin.msi
```

### Issue: "License File Not Found"

**Check:**
1. License file exists in `C:\ProgramData\WhiteBeard\`
2. File name ends with `_pawn_plugin.lic`
3. File has proper XML or text format
4. User has read permissions

### Issue: "MT5 Not Detected"

**Check:**
1. MetaTrader 5 is actually installed
2. Registry key exists: `HKEY_LOCAL_MACHINE\SOFTWARE\MetaQuotes\MetaTrader 5`
3. Manual selection path exists and contains `Plugins` subdirectory
4. User has write permissions to MT5 Plugins directory

### Issue: "API Verification Failed"

**Check:**
1. API endpoint URL is correct: `https://yourserver.com/verify`
2. API server is reachable and responding
3. License file, company name, and email are correct
4. Check installer log for detailed error: `msiexec /i setup.msi /l*v log.txt`

### Issue: "Cannot Write to ProgramData"

**Solution:** Run installer with administrator privileges.

## Deployment

### Production Considerations

1. **Code Signing**
   - Sign the MSI with an Authenticode certificate
   - Update `Product.wxs` with certificate information

2. **Self-Updating**
   - Implement minor/major version upgrades using `UpgradeCode`
   - Update version in `Product.wxs` for new releases

3. **Silent Installation**
   ```bash
   msiexec /i WhiteBeardPawnPlugin.msi /quiet /norestart /l*v log.txt
   ```

4. **Custom Install Directory**
   ```bash
   msiexec /i WhiteBeardPawnPlugin.msi INSTALLDIR="C:\Custom\Path"
   ```

5. **Remove Before Installing**
   ```bash
   # Uninstall old version
   msiexec /x WhiteBeardPawnPlugin.msi /quiet
   # Install new version
   msiexec /i WhiteBeardPawnPlugin.msi /quiet
   ```

## Customization Guide

### Changing Product Name

1. Update `Product.wxs`:
```xml
<Product Name="Your Product Name" />
```

2. Update `CustomActions.cs`:
```csharp
fbd.Description = "Select your custom directory";
```

### Adding More Files

1. Create new component in `Product.wxs`:
```xml
<Component Id="MyNewComponent" Directory="INSTALLFOLDER">
  <File Id="MyFile" Name="myfile.dll" Source="path/to/file.dll" />
</Component>
```

2. Reference in Feature:
```xml
<ComponentRef Id="MyNewComponent" />
```

### Modifying UI Dialogs

Edit `CustomDialog.wxs` to:
- Change dialog titles
- Reposition controls
- Add new input fields
- Modify colors and fonts

## API Integration

### Expected API Endpoint

**URL:** `https://yourserver.com/verify`  
**Method:** POST  
**Content-Type:** multipart/form-data

**Request Body:**
```
companyName: string
companyEmail: string
licenseFile: binary (file content)
```

**Success Response:**
```
HTTP 200 OK
```

**Error Response:**
```
HTTP 400/401/403/500 with error details
```

## License File Format

### XML Format (Recommended)
```xml
<?xml version="1.0"?>
<License>
  <CompanyName>Company Name</CompanyName>
  <CompanyEmail>company@example.com</CompanyEmail>
  <LicenseKey>UNIQUE-LICENSE-KEY</LicenseKey>
  <IssueDate>2024-01-01</IssueDate>
  <ExpirationDate>2025-12-31</ExpirationDate>
  <MaxCopies>1</MaxCopies>
</License>
```

### Text Format (Key=Value)
```
CompanyName=Company Name
CompanyEmail=company@example.com
LicenseKey=UNIQUE-LICENSE-KEY
IssueDate=2024-01-01
ExpirationDate=2025-12-31
MaxCopies=1
```

## Support Contact Information

**WhiteBeard**
- Website: [www.whitebeard.ai](https://www.whitebeard.ai)
- Email: [info@whitebeard.ai](mailto:info@whitebeard.ai)
- Phone: +1 646 422 8482

## Building for Distribution

```bash
# 1. Build release version
wix build -o bin/Release/WhiteBeardPawnPlugin.msi Product.wxs CustomDialog.wxs -ext WixToolset.UI.wixext

# 2. Sign the MSI (requires Authenticode certificate)
signtool sign /f mycert.pfx /p password /t http://timestamp.server.com bin/Release/WhiteBeardPawnPlugin.msi

# 3. Create checksum for verification
certutil -hashfile bin/Release/WhiteBeardPawnPlugin.msi SHA256 > checksum.txt

# 4. Upload to distribution server
# Include both MSI and checksum file
```

## Version History

| Version | Date       | Changes                          |
|---------|------------|---------------------------------|
| 1.0.0   | 2024-10-25 | Initial release                  |

## Notes

- Installer requires **Windows 7 or later** (x64 architecture)
- Requires **administrator privileges**
- MetaTrader 5 must be installed before running this installer
- License file must be valid and accessible
- API verification requires internet connectivity

---

**For detailed questions or support with customization, contact WhiteBeard at info@whitebeard.ai**
