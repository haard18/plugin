@echo off
REM Clean Build Script for WhiteBeard Pawn Plugin Installer
REM Uses simplified approach with working WiX v4 syntax

setlocal enabledelayedexpansion

echo ========================================
echo WhiteBeard Pawn Plugin Installer Build
echo ========================================
echo.

REM Set paths
set DOTNET_BIN=dotnet
set OUTPUT_DIR=bin

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

echo [4/4] Building WiX installer...
REM Find WiX executable
set "WIX_EXE="
where wix >nul 2>nul
if %errorlevel%==0 (
    set "WIX_EXE=wix"
) else (
    if exist "%ProgramFiles%\WiX Toolset v4\bin\wix.exe" (
        set "WIX_EXE=%ProgramFiles%\WiX Toolset v4\bin\wix.exe"
    ) else if exist "%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe" (
        set "WIX_EXE=%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe"
    ) else (
        echo ERROR: WiX v4 not found. Please install WiX Toolset v4.
        echo Download from: https://github.com/wixtoolset/wix4/releases
        pause
        exit /b 1
    )
)

echo Using WiX: %WIX_EXE%
echo Building installer...

REM Use the clean Product_Ultimate.wxs (no complex UI issues)
call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product_Ultimate.wxs

if errorlevel 1 (
    echo ERROR: WiX build failed
    echo Trying fallback to basic Product.wxs...
    call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs
    if errorlevel 1 (
        echo ERROR: Both WiX builds failed
        pause
        exit /b 1
    )
)

if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo Output: %OUTPUT_DIR%\WhiteBeardPawnPlugin.msi
    echo.
    dir "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
    echo.
    echo To install:
    echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
    echo.
    echo To install with verbose logging:
    echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" /l*v install.log
    echo.
) else (
    echo ERROR: Installer file not created
    exit /b 1
)

pause
endlocal
exit /b 0
