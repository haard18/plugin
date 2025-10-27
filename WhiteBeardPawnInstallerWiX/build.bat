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
REM Locate wix.exe (WiX v4): prefer WIX_BIN, then default locations, then PATH
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
    echo        Install WiX v4 or add it to PATH.
    exit /b 1
)

:wix_found
echo Using WiX: %WIX_EXE%
REM --- Ensure WiX UI extension is available (v4) ---
REM Try to add the extension globally if not already present
echo Compiling installer...
REM First try without extension since we're using custom dialogs
call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs CustomDialog.wxs
if errorlevel 1 (
    echo First attempt failed, trying with UI extension...
    REM Try different approaches to add the extension
    echo Attempting to install WiX UI extension...
    "%WIX_EXE%" extension add --global WixToolset.UI.wixext --version 4.0.4 2>nul
    if errorlevel 1 (
        echo Extension add failed, trying alternative...
        "%WIX_EXE%" extension list
    )
    echo Attempting build with UI extension...
    call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs CustomDialog.wxs -ext WixToolset.UI.wixext
)
if errorlevel 1 (
    echo ERROR: Failed to build WiX installer
    exit /b 1
)
echo SUCCESS: Installer compiled

:post_build

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
