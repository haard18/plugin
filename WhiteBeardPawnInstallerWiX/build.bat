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
echo Using WiX: %WIX_EXE%

REM Try to find WixToolset.UI.wixext DLL in standard locations
set "EXT_DLL="
if exist "%ProgramFiles%\WiX Toolset v4\bin\WixToolset.UI.wixext.dll" set "EXT_DLL=%ProgramFiles%\WiX Toolset v4\bin\WixToolset.UI.wixext.dll"
if exist "%ProgramFiles(x86)%\WiX Toolset v4\bin\WixToolset.UI.wixext.dll" set "EXT_DLL=%ProgramFiles(x86)%\WiX Toolset v4\bin\WixToolset.UI.wixext.dll"

REM Check user's .wix folder for the extension
if not defined EXT_DLL (
    if exist "%USERPROFILE%\.wix\extensions\WixToolset.UI.wixext" (
        for /d %%v in ("%USERPROFILE%\.wix\extensions\WixToolset.UI.wixext\*") do (
            if exist "%%v\wixext4\WixToolset.UI.wixext.dll" (
                set "EXT_DLL=%%v\wixext4\WixToolset.UI.wixext.dll"
                goto ext_found
            )
        )
    )
)

REM Check local .wix folder
if not defined EXT_DLL (
    if exist ".wix\extensions\WixToolset.UI.wixext" (
        for /d %%v in (".wix\extensions\WixToolset.UI.wixext\*") do (
            if exist "%%v\wixext4\WixToolset.UI.wixext.dll" (
                set "EXT_DLL=%%v\wixext4\WixToolset.UI.wixext.dll"
                goto ext_found
            )
        )
    )
)

:ext_found
REM If DLL found, use it directly
if defined EXT_DLL (
    echo Found WiX UI extension: %EXT_DLL%
    set "EXT_ARG=%EXT_DLL%"
    goto build_installer
)

REM Otherwise, try to install the extension via dotnet tool
echo WiX UI extension DLL not found.
echo Attempting to add WixToolset.UI.wixext via WiX CLI...

REM Try to add the extension
"%WIX_EXE%" extension add -g WixToolset.UI.wixext
if errorlevel 1 (
    echo.
    echo ERROR: Failed to add WixToolset.UI.wixext extension.
    goto ext_install_help
)

echo Extension add command completed.
echo Verifying installation...

REM Wait a moment for filesystem to catch up
timeout /t 2 /nobreak >nul

REM Check again if the DLL now exists
if exist "%USERPROFILE%\.wix\extensions\WixToolset.UI.wixext" (
    for /d %%v in ("%USERPROFILE%\.wix\extensions\WixToolset.UI.wixext\*") do (
        if exist "%%v\wixext4\WixToolset.UI.wixext.dll" (
            set "EXT_DLL=%%v\wixext4\WixToolset.UI.wixext.dll"
            echo Found extension DLL: !EXT_DLL!
            set "EXT_ARG=!EXT_DLL!"
            goto build_installer
        )
    )
)

echo WARNING: Extension was added but DLL not found in expected location.
echo Trying to build with extension name...
set "EXT_ARG=WixToolset.UI.wixext"
goto build_installer

:ext_install_help
echo.
echo ERROR: Failed to add WixToolset.UI.wixext extension.
echo.
echo Please try installing it manually:
echo   wix extension add -g WixToolset.UI.wixext
echo.
echo Or install via NuGet:
echo   dotnet add package WixToolset.UI.wixext
echo.
exit /b 1

:build_installer
REM Compile Product.wxs and CustomDialog.wxs with the resolved extension argument
echo Compiling installer with extension: %EXT_ARG%
call "%WIX_EXE%" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product.wxs CustomDialog.wxs -ext "%EXT_ARG%"
if errorlevel 1 (
    echo ERROR: Failed to build WiX installer
    echo.
    echo If the extension is missing, try:
    echo   1. wix extension remove WixToolset.UI.wixext
    echo   2. wix extension add -g WixToolset.UI.wixext
    echo   3. wix extension list (to verify)
    echo.
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