@echo off
REM Fixed Build Script for WhiteBeard Pawn Plugin Installer
REM Addresses DLL loading issues and provides fallback options

setlocal enabledelayedexpansion

echo ========================================
echo WhiteBeard Pawn Plugin Installer Build
echo ========================================
echo.

REM Set paths
set DOTNET_BIN=dotnet
set OUTPUT_DIR=bin

echo [1/5] Cleaning previous builds...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
if exist "CustomActions.dll" del "CustomActions.dll"
mkdir "%OUTPUT_DIR%"

echo [2/5] Building C# Custom Actions...
call %DOTNET_BIN% build CustomActions\CustomActions.csproj -c Release -p:Platform=x64
if errorlevel 1 (
    echo ERROR: Failed to build custom actions
    echo Fallback: Building without custom actions...
    goto BuildSimple
)

echo [3/5] Copying custom actions DLL...
set "CA_SOURCE_PATH=CustomActions\bin\x64\Release\net48\CustomActions.dll"
if exist "%CA_SOURCE_PATH%" (
    copy "%CA_SOURCE_PATH%" .
    echo SUCCESS: Custom actions DLL copied
) else (
    echo WARNING: Custom actions DLL not found at expected location
    echo Trying alternative path...
    set "CA_ALT_PATH=CustomActions\bin\Release\net48\CustomActions.dll"
    if exist "!CA_ALT_PATH!" (
        copy "!CA_ALT_PATH!" .
        echo SUCCESS: Custom actions DLL copied from alternative path
    ) else (
        echo ERROR: Cannot find CustomActions.dll - building simple version
        goto BuildSimple
    )
)

echo [4/5] Building WiX installer with custom actions...
REM Find WiX executable
call :FindWiXExe
if "!WIX_EXE!"=="" (
    echo ERROR: WiX v4 not found. Please install WiX Toolset v4.
    echo Download from: https://github.com/wixtoolset/wix4/releases
    pause
    exit /b 1
)

echo Using WiX: !WIX_EXE!

REM Try building with custom actions first
call "!WIX_EXE!" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product_Ultimate.wxs
if errorlevel 1 (
    echo WARNING: Ultimate version failed, trying simplified version...
    goto BuildSimple
) else (
    echo SUCCESS: Built installer with custom actions
    goto BuildComplete
)

:BuildSimple
echo [4/5] Building simplified WiX installer (no custom actions)...
call :FindWiXExe
if "!WIX_EXE!"=="" (
    echo ERROR: WiX v4 not found
    pause
    exit /b 1
)

call "!WIX_EXE!" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" Product_Simple.wxs
if errorlevel 1 (
    echo ERROR: Simple build also failed
    echo Checking if files exist...
    if not exist "Files\PawnPlugin64.dll" (
        echo ERROR: Files\PawnPlugin64.dll not found!
        echo Please ensure the plugin DLL is in the Files directory
    )
    pause
    exit /b 1
)

echo SUCCESS: Built simplified installer (manual installation required)

:BuildComplete
if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo Output: %OUTPUT_DIR%\WhiteBeardPawnPlugin.msi
    echo.
    dir "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
    echo.
    
    if exist "CustomActions.dll" (
        echo NOTE: This installer includes custom actions for:
        echo   - License validation
        echo   - MT5 auto-detection
        echo   - Automatic plugin deployment
        echo.
    ) else (
        echo NOTE: This is a simplified installer that will:
        echo   - Install plugin files to Program Files
        echo   - Create registry entries
        echo   - Manual MT5 setup may be required
        echo.
    )
    
    echo To install:
    echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
    echo.
    echo To install with verbose logging:
    echo   msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi" /l*v install.log
    echo.
    echo To uninstall:
    echo   msiexec /x "%OUTPUT_DIR%\WhiteBeardPawnPlugin.msi"
    echo.
) else (
    echo ERROR: Installer file not created
    exit /b 1
)

pause
endlocal
exit /b 0

:FindWiXExe
set "WIX_EXE="
where wix >nul 2>nul
if %errorlevel%==0 (
    set "WIX_EXE=wix"
    goto :eof
)

if exist "%ProgramFiles%\WiX Toolset v4\bin\wix.exe" (
    set "WIX_EXE=%ProgramFiles%\WiX Toolset v4\bin\wix.exe"
    goto :eof
)

if exist "%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe" (
    set "WIX_EXE=%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe"
    goto :eof
)

REM Try dotnet tool
dotnet tool list -g | findstr /C:"wix" >nul 2>nul
if %errorlevel%==0 (
    set "WIX_EXE=dotnet wix"
)

goto :eof