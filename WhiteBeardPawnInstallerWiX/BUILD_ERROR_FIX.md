# Build Error Fix - CustomActions.cs

## Error Message

```
error CS0246: The type or namespace name 'CustomAction' could not be found
(are you missing a using directive or an assembly reference?)
```

## Solution

The error occurs because the WiX DTF (Deployment Tools Framework) NuGet packages haven't been properly restored. Here are the steps to fix it:

### Step 1: Clean and Restore NuGet Packages

```bash
# Navigate to the CustomActions project directory
cd WhiteBeardPawnInstallerWiX\CustomActions

# Clean the project
dotnet clean

# Restore packages
dotnet restore

# Return to root
cd ..
```

### Step 2: Verify the Project File

The `CustomActions.csproj` has been updated with:
- Correct SDK: `Microsoft.NET.Sdk.WindowsDesktop`
- Windows Forms support enabled
- Latest WiX DTF version: `4.0.5`
- Explicit XML reference

### Step 3: Rebuild

```bash
# From project root
dotnet build CustomActions\CustomActions.csproj -c Release -o bin/

# If that fails, try explicit restore + build
dotnet restore CustomActions\CustomActions.csproj
dotnet build CustomActions\CustomActions.csproj -c Release -o bin/
```

## Detailed Fix Steps

### Option A: Using Command Line (Recommended)

```bash
# 1. Navigate to project root
cd C:\Users\Haard\Desktop\plugin\WhiteBeardPawnInstallerWiX

# 2. Clean everything
dotnet clean CustomActions\CustomActions.csproj
rmdir /s /q CustomActions\bin
rmdir /s /q CustomActions\obj

# 3. Restore packages with verbose output
dotnet restore CustomActions\CustomActions.csproj -v diag

# 4. Build
dotnet build CustomActions\CustomActions.csproj -c Release -v diag

# 5. Run full build
build.bat
```

### Option B: Using Visual Studio

1. Open Visual Studio
2. Open the solution or the `CustomActions.csproj` project
3. Right-click project → "Restore NuGet Packages"
4. Wait for restore to complete
5. Clean solution (Build → Clean Solution)
6. Rebuild solution (Build → Rebuild Solution)

### Option C: Using Visual Studio Code

```bash
# Open terminal in VS Code

# Restore packages
dotnet restore CustomActions/CustomActions.csproj

# Build
dotnet build CustomActions/CustomActions.csproj -c Release
```

## Verification Checklist

After applying the fix:

- [ ] File `CustomActions.csproj` updated with new SDK and packages
- [ ] Run `dotnet restore`
- [ ] Run `dotnet build` successfully
- [ ] No CS0246 errors
- [ ] `bin\CustomActions.dll` created (should be ~100-200 KB)
- [ ] Run `build.bat` successfully

## Expected Output

When build succeeds, you should see:

```
Microsoft (R) Build Engine version 16.x.x
[SUCCESS] CustomActions built

[4/5] Copying custom actions DLL...
[SUCCESS] Custom actions built

[5/5] Verifying output...
[5/5] Compiling WiX source files...

========================================
BUILD SUCCESSFUL!
========================================
Output: bin\WhiteBeardPawnPlugin.msi
```

## If Problem Persists

### Clear Everything and Start Fresh

```bash
# 1. Delete all build artifacts
rmdir /s /q bin
rmdir /s /q obj
rmdir /s /q CustomActions\bin
rmdir /s /q CustomActions\obj

# 2. Delete NuGet cache (optional, more aggressive)
del /q "%USERPROFILE%\.nuget\packages\wixtoolset*" /s

# 3. Restore from scratch
dotnet nuget locals all --clear
dotnet restore CustomActions\CustomActions.csproj

# 4. Build
build.bat
```

### Check .NET Installation

```bash
# Verify .NET SDK is installed
dotnet --version

# Verify .NET Framework 4.8 is available
dotnet --list-runtimes
```

### Manual Package Installation (If all else fails)

```bash
# Install WiX DTF manually using dotnet CLI
dotnet add CustomActions\CustomActions.csproj package WixToolset.Dtf.WindowsInstaller --version 4.0.5

# Then rebuild
dotnet build CustomActions\CustomActions.csproj -c Release
```

## Understanding the Error

The `[CustomAction]` attribute comes from:
```csharp
using Microsoft.Deployment.WindowsInstaller;
```

Which is provided by the NuGet package:
```xml
<PackageReference Include="WixToolset.Dtf.WindowsInstaller" Version="4.0.5" />
```

If this package isn't properly restored, the compiler can't find the attribute, resulting in CS0246 error.

## Updated Project File Summary

**File:** `CustomActions/CustomActions.csproj`

Changes made:
- ✅ Updated to `Microsoft.NET.Sdk.WindowsDesktop` (better for Windows Forms)
- ✅ Added `<UseWindowsForms>true</UseWindowsForms>`
- ✅ Added `<OutputType>Library</OutputType>` (explicit DLL output)
- ✅ Updated WiX DTF to version `4.0.5`
- ✅ Added explicit `System.Xml.Linq` reference

## Next Steps

1. Apply the fix above
2. Verify build succeeds
3. Run `build.bat` to create the MSI
4. Test the installer

## Support

If you continue to experience issues:

1. Check .NET installation: `dotnet --version`
2. Verify WiX Toolset is installed: `wix --version`
3. Check Visual Studio/Build Tools version compatibility
4. Try on a different machine if possible
5. Review WiX Toolset documentation: https://wixtoolset.org/

---

**Last Updated:** October 25, 2024  
**Status:** ✅ Fix Applied
