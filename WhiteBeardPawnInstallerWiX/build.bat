@echo off
REM Build script for WhiteBeard Pawn Plugin Installer
REM This script compiles C# custom actions and WiX source files

setlocal enabledelayedexpansion

echo ========================================
echo WhiteBeard Pawn Plugin Installer Build
echo ========================================
echo.

REM Set paths
set WIX_BIN=C:\Program Files\WiX Toolset v4\bin
set DOTNET_BIN=dotnet
set OUTPUT_DIR=bin
set OBJ_DIR=obj

echo [1/5] Cleaning previous builds...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
if exist "%OBJ_DIR%" rmdir /s /q "%OBJ_DIR%"
mkdir "%OUTPUT_DIR%"
mkdir "%OBJ_DIR%"

echo [2/5] Building C# Custom Actions...
call %DOTNET_BIN% build CustomActions\CustomActions.csproj -c Release -o "%OUTPUT_DIR%"
if errorlevel 1 (
    echo ERROR: Failed to build custom actions
    exit /b 1
)
echo SUCCESS: Custom actions built

echo [3/5] Copying custom actions DLL...
copy "%OUTPUT_DIR%\CustomActions.dll" .
if errorlevel 1 (
    echo ERROR: Failed to copy CustomActions.dll
    exit /b 1
)

echo [4/5] Compiling WiX source files...
REM Locate wix.exe (WiX v4): prefer WIX_BIN, then default locations, then PATH (dotnet tool)
set "WIX_EXE=%WIX_BIN%\wix.exe"
if exist "%WIX_EXE%" goto wix_found
set "WIX_EXE=%ProgramFiles%\WiX Toolset v4\bin\wix.exe"
if exist "%WIX_EXE%" goto wix_found
set "WIX_EXE=%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe"
if exist "%WIX_EXE%" goto wix_found
where wix >nul 2>nul
if %errorlevel%==0 (
    set "WIX_EXE=wix"
    goto wix_found
) else (
    echo ERROR: WiX v4 not found.
    echo        Install WiX v4 or add it to PATH. For example:
    echo          dotnet tool install --global wix
    echo        Or set WIX_BIN to the correct install folder.
    exit /b 1
)

:wix_found
REM Compile Product.wxs and CustomDialog.wxs
call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs CustomDialog.wxs -ext WixToolset.UI.wixext
if errorlevel 1 (
    echo ERROR: Failed to build WiX installer
    exit /b 1
)
echo SUCCESS: Installer compiled

echo [5/5] Verifying output...
if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo Output: %OUTPUT_DIR%\WhiteBeardPawnPlugin.msi
    echo.
    echo You can now install with:
    echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
    echo.
    echo For verbose logging:
    echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" /l*v install.log
    echo.
) else (
    echo ERROR: Installer file not created
    exit /b 1
)

endlocal
exit /b 0
