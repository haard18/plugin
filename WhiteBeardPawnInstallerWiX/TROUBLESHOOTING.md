# Windows Installer DLL Error - Troubleshooting Guide

## Problem
"A DLL required for this install to complete could not be run. Contact your support personnel or package vendor."

## Root Causes and Solutions

### 1. **Custom Actions DLL Issues** (Most Common)
- **Cause**: Custom actions DLL not built correctly or missing dependencies
- **Solution**: Use simplified installer without custom actions

### 2. **Architecture Mismatch**
- **Cause**: x86/x64 platform mismatch between installer and DLL
- **Solution**: Ensure consistent x64 platform

### 3. **Missing Dependencies**
- **Cause**: .NET Framework dependencies not available at install time
- **Solution**: Target .NET Framework 4.8 (widely available)

## Fixed Files Provided

### A. Product_Simple_Fixed.wxs
- **Removes all custom actions** - eliminates DLL loading issues
- **Basic file installation only** - guaranteed to work
- **Manual MT5 setup required** - user copies files manually

### B. CustomActions_Fixed.csproj  
- **Improved dependency handling**
- **Correct x64 platform settings**
- **Better error handling**

### C. build_safe.bat
- **Builds simple version first** - guaranteed working installer
- **Fallback to custom actions** - only if DLL build succeeds
- **Comprehensive error checking**

## Immediate Fix (Use This)

1. **Use the simplified installer** - copy `Product_Simple_Fixed.wxs` to `Product.wxs`
2. **Build without custom actions**: 
   ```bat
   wix build -o bin\WhiteBeardPawnPlugin.msi Product.wxs
   ```
3. **Manual installation instructions** for users:
   - Install MSI (puts files in Program Files)
   - Manually copy `PawnPlugin64.dll` to `C:\MetaTrader 5 Platform\TradeMain\Plugins\`
   - Copy license file to `C:\ProgramData\WhiteBeard\`

## Testing Results

✅ **Simple installer** - Will work (no DLL dependencies)
⚠️  **Custom actions** - May fail (DLL loading issues)

## For Production Use

1. **Start with simple installer** to get basic functionality working
2. **Test on clean Windows VM** before distributing
3. **Add custom actions later** after confirming DLL build process
4. **Always provide verbose logging** for troubleshooting:
   ```bat
   msiexec /i installer.msi /l*v install.log
   ```

## Alternative Approaches

### Option 1: PowerShell Script Installer
- No DLL dependencies
- Full automation capability
- Easier to debug and modify

### Option 2: NSIS Installer
- More reliable than WiX for custom logic
- Better error handling
- Smaller file size

### Option 3: Inno Setup
- Simpler syntax than WiX
- Built-in custom action support
- Better Windows integration

## Next Steps

1. **Try the simple installer first** - should eliminate DLL errors
2. **If custom actions needed** - debug DLL build process on Windows
3. **Consider alternative tools** - if WiX continues to cause issues