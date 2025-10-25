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
REM --- Ensure WiX UI extension is available (v4) and compile using extension ID ---
REM Check if extension is already available; if not, add it globally
for /f "delims=" %%i in ('%WIX_EXE% extension list ^| findstr /i /c:"WixToolset.UI.wixext"') do set "_WIX_UI_EXT_FOUND=1"
if not defined _WIX_UI_EXT_FOUND (
    echo WiX UI extension not found locally; adding via WiX CLI...
    "%WIX_EXE%" extension add -g WixToolset.UI.wixext
    if errorlevel 1 (
        echo ERROR: Failed to add WixToolset.UI.wixext extension.
        exit /b 1
    )
)

REM Attempt to locate the extension DLL explicitly as a reliable fallback
set "EXT_DLL="
set "USER_HOME=%USERPROFILE%"
if not defined USER_HOME set "USER_HOME=%HOMEDRIVE%%HOMEPATH%"

if exist "%USER_HOME%\.wix\extensions\WixToolset.UI.wixext" (
    for /f "delims=" %%v in ('dir /b /ad /o-n "%USER_HOME%\.wix\extensions\WixToolset.UI.wixext"') do (
        if exist "%USER_HOME%\.wix\extensions\WixToolset.UI.wixext\%%v\wixext4\WixToolset.UI.wixext.dll" (
            set "EXT_DLL=%USER_HOME%\.wix\extensions\WixToolset.UI.wixext\%%v\wixext4\WixToolset.UI.wixext.dll"
            goto ext_path_found
        )
    )
)

:ext_path_found
if defined EXT_DLL (
    echo Compiling installer with extension DLL: %EXT_DLL%
    call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs CustomDialog.wxs -ext "%EXT_DLL%"
    goto post_build
)

echo Compiling installer with extension: WixToolset.UI.wixext
call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs CustomDialog.wxs -ext WixToolset.UI.wixext
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
