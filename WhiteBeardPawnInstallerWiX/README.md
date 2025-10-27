# WhiteBeard Pawn Plugin Installer

A clean, working Windows Installer (MSI) for the WhiteBeard Pawn Plugin for MetaTrader 5.

## Quick Start

### Requirements
- Windows with .NET Framework 4.8+
- WiX Toolset v4 ([Download here](https://github.com/wixtoolset/wix4/releases))
- .NET SDK or Visual Studio

### Build the Installer

```cmd
build.bat
```

This will:
1. Build the C# custom actions
2. Create the MSI installer in `bin\WhiteBeardPawnPlugin.msi`

### Install the Plugin

```cmd
msiexec /i bin\WhiteBeardPawnPlugin.msi
```

For detailed installation logging:
```cmd
msiexec /i bin\WhiteBeardPawnPlugin.msi /l*v install.log
```

## Files Structure

- **`build.bat`** - Main build script (Windows)
- **`build.sh`** - Build script for Linux/macOS (requires WSL)
- **`Product.wxs`** - Complex WiX installer with custom UI
- **`Product_Ultimate.wxs`** - Simplified WiX installer (recommended)
- **`CustomActions/`** - C# custom action logic for MT5 deployment
- **`Files/PawnPlugin64.dll`** - The actual plugin to install
- **`example_license.lic`** - Example license file format

## What the Installer Does

1. **Installs** PawnPlugin64.dll to Program Files
2. **Deploys** plugin automatically to MetaTrader 5 Plugins directory
3. **Processes** license files and stores them securely
4. **Creates** registry entries for tracking installation
5. **Logs** all operations for troubleshooting

## Troubleshooting

### "DLL required for install could not be run" Error
1. Make sure .NET Framework 4.8+ is installed
2. Run installer as Administrator
3. Check installation log: `msiexec /i bin\WhiteBeardPawnPlugin.msi /l*v debug.log`

### Build Errors
1. Ensure WiX Toolset v4 is installed and in PATH
2. Verify .NET SDK is available
3. Check that `Files/PawnPlugin64.dll` exists

## Development

To customize the installer:
1. **Installer Structure**: Edit `Product_Ultimate.wxs`
2. **Installation Logic**: Edit `CustomActions/CustomActions.cs`
3. **Build**: Run `build.bat`

The simplified `Product_Ultimate.wxs` is recommended as it avoids WiX v4 compatibility issues with complex UI elements.
