@echo off
REM Clean build script for WhiteBeard Pawn Plugin Installer
REM Fixed for WiX v4 compatibility

setlocal enabledelayedexpansion

echo ========================================
echo WhiteBeard Pawn Plugin Installer Build
echo ========================================
echo.

REM Set paths
set DOTNET_BIN=dotnet
set OUTPUT_DIR=bin
set WIX_FILE=Product_Fixed.wxs

echo [1/4] Cleaning previous builds...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

echo [2/4] Building C# Custom Actions...
call %DOTNET_BIN% build CustomActions\CustomActions.csproj -c Release -o "%OUTPUT_DIR%"
if errorlevel 1 (
    echo ERROR: Failed to build custom actions
    pause
    exit /b 1
)
echo SUCCESS: Custom actions built

echo [3/4] Copying custom actions DLL...
copy "%OUTPUT_DIR%\CustomActions.dll" .
if errorlevel 1 (
    echo ERROR: Failed to copy CustomActions.dll
    pause
    exit /b 1
)

echo [4/4] Creating Files directory and dummy plugin...
if not exist Files mkdir Files
if not exist Files\PawnPlugin64.dll (
    echo Creating dummy plugin file for testing...
    echo dummy > Files\PawnPlugin64.dll
)

echo [5/5] Building WiX installer...
REM Try to find WiX
set "WIX_EXE="
where wix >nul 2>nul
if %errorlevel%==0 (
    set "WIX_EXE=wix"
    goto build_installer
)

REM Check common installation paths
if exist "%ProgramFiles%\WiX Toolset v4\bin\wix.exe" (
    set "WIX_EXE=%ProgramFiles%\WiX Toolset v4\bin\wix.exe"
    goto build_installer
)

if exist "%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe" (
    set "WIX_EXE=%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe"
    goto build_installer
)

echo ERROR: WiX v4 not found. Please install WiX Toolset v4.
echo Download from: https://github.com/wixtoolset/wix4/releases
pause
exit /b 1

:build_installer
echo Using WiX: %WIX_EXE%
echo Compiling %WIX_FILE%...

call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" "%WIX_FILE%"

if errorlevel 1 (
    echo ERROR: WiX build failed
    echo.
    echo Common issues:
    echo 1. Missing Files\PawnPlugin64.dll
    echo 2. WiX v4 syntax errors
    echo 3. Missing dependencies
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo Output: %OUTPUT_DIR%\WhiteBeardPawnPlugin.msi
echo.
echo To install:
echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
echo.
echo For verbose logging:
echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" /l*v install.log
echo.

pause
endlocal
exit /b 0