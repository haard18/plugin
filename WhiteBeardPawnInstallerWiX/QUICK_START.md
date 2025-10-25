# WhiteBeard Pawn Plugin Installer - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- Windows 10/11 (or Windows 7+)
- Administrator account
- WiX Toolset 4 installed
- .NET Framework 4.8
- Visual Studio or command-line tools

### Step 1: Prepare Your Environment

```bash
# Download WiX Toolset 4
# Visit: https://wixtoolset.org/releases/

# Verify .NET Framework
# Open PowerShell as Admin and run:
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | 
  Get-ItemProperty -Name Version -ErrorAction SilentlyContinue
```

### Step 2: Prepare Test Files

1. **Place Plugin DLL:**
   ```bash
   # Copy your PawnPlugin64.dll to the Files directory
   copy "C:\your\build\output\PawnPlugin64.dll" "Files\PawnPlugin64.dll"
   
   # Verify it exists
   dir Files\PawnPlugin64.dll
   ```

2. **Create Test License File:**
   ```bash
   mkdir C:\ProgramData\WhiteBeard
   # Copy example_license.lic as test_pawn_plugin.lic
   copy example_license.lic C:\ProgramData\WhiteBeard\test_pawn_plugin.lic
   ```

### Step 3: Configure API Endpoint

Edit `CustomActions.cs` and update:

```csharp
private const string VERIFY_API_URL = "https://yourserver.com/verify";
```

For testing without real API:

```csharp
// In VerifyLicenseAsync method, add at the start:
session.Log("Testing mode: skipping API verification");
return true;
```

### Step 4: Build the Installer

**On Windows Command Prompt (as Administrator):**

```bash
cd WhiteBeardPawnInstallerWiX
build.bat
```

**Output:** `bin\WhiteBeardPawnPlugin.msi`

### Step 5: Test Installation

**Silent Test:**
```bash
msiexec /i bin\WhiteBeardPawnPlugin.msi /quiet /l*v test.log
```

**Interactive Test:**
```bash
bin\WhiteBeardPawnPlugin.msi
# OR
msiexec /i bin\WhiteBeardPawnPlugin.msi
```

**View Log:**
```bash
notepad test.log
```

## 🔧 Configuration Checklist

- [ ] License search directory: `C:\ProgramData\WhiteBeard`
- [ ] License file pattern: `*_pawn_plugin.lic`
- [ ] API endpoint: Updated to your server
- [ ] Plugin DLL path: Points to correct location
- [ ] MT5 default path: `C:\MetaTrader 5 Platform\TradeMain`
- [ ] Product GUID (UpgradeCode): Updated for your product
- [ ] Company name: Changed from "WhiteBeard" to your company

## 📝 Common Customizations

### Change Product Name

1. **Product.wxs:**
   ```xml
   <Product Name="Your Product Name" />
   ```

2. **CustomActions.cs:**
   Search/replace "WhiteBeard" with your company name

### Change Company Info

1. **README.md:**
   Update support contact information

2. **Product.wxs:**
   ```xml
   <Product Manufacturer="Your Company Name" />
   ```

### Add Additional Files

**Product.wxs:**
```xml
<Component Id="AdditionalFilesComponent" Directory="INSTALLFOLDER">
  <File Id="ConfigFile" Name="config.ini" Source="path/to/config.ini" />
  <File Id="DocFile" Name="README.txt" Source="path/to/README.txt" />
</Component>
```

Then in Feature:
```xml
<ComponentRef Id="AdditionalFilesComponent" />
```

### Modify UI Dialog Order

**Product.wxs** - Change `DialogRef` order and publish events:
```xml
<Publish Dialog="WelcomeDlg" Control="NextButton" Event="NewDialog" Value="YourDialog" />
```

## 🐛 Troubleshooting

### "WiX not found"
```bash
# Check WiX installation
"C:\Program Files (x86)\WiX Toolset v4\bin\wix.exe" --version

# Update build.bat if installed in different location
```

### "Cannot write to C:\ProgramData"
```bash
# Run Command Prompt as Administrator
# Then run build and install commands
```

### "License file not found"
- Verify file exists: `dir C:\ProgramData\WhiteBeard\*.lic`
- Check file permissions: `icacls C:\ProgramData\WhiteBeard`
- Verify filename pattern ends with `_pawn_plugin.lic`

### "MT5 not detected"
- Verify MT5 installed: `C:\MetaTrader 5 Platform\TradeMain`
- Check registry: `reg query HKLM\SOFTWARE\MetaQuotes\MetaTrader`
- Update default path in `CustomActions.cs` if different

### "API verification failed"
- Check internet connectivity
- Verify API endpoint is correct
- Test API manually:
  ```bash
  curl -X POST -F "companyName=Test" -F "companyEmail=test@test.com" -F "licenseFile=@license.lic" https://yourserver.com/verify
  ```

### "Build succeeds but MSI not created"
- Check `bin\` directory exists
- Review build output for errors
- Run `build.bat` again with admin privileges

## 📦 Distribution

To create a production installer:

1. **Sign the MSI** (requires code signing certificate):
   ```bash
   signtool sign /f certificate.pfx /p password /t http://timestamp.server.com bin\WhiteBeardPawnPlugin.msi
   ```

2. **Create checksum:**
   ```bash
   certutil -hashfile bin\WhiteBeardPawnPlugin.msi SHA256 > checksum.txt
   ```

3. **Upload files:**
   - `bin\WhiteBeardPawnPlugin.msi`
   - `checksum.txt`
   - Documentation/README

## 🔗 Useful Links

- **WiX Documentation:** https://wixtoolset.org/docs/
- **WiX Tutorials:** https://wixtoolset.org/docs/overview/
- **Custom Actions:** https://wixtoolset.org/docs/v4/topic/ca-overview
- **.NET Framework:** https://dotnet.microsoft.com/download/dotnet-framework

## 📞 Support

- **WhiteBeard Support:** info@whitebeard.ai
- **Website:** www.whitebeard.ai
- **Phone:** +1 646 422 8482

## 🎓 Next Steps

1. Review `README.md` for detailed documentation
2. Examine `CustomActions.cs` to understand the logic
3. Test with different license files
4. Verify MT5 detection works on target machines
5. Set up automated builds/CI-CD pipeline

---

**Good luck with your installation! 🎉**
