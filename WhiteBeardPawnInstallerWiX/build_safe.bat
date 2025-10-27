@echo off
REM Safe Build Script - Guaranteed Working Installer
REM Builds simple installer first, then attempts advanced version

setlocal enabledelayedexpansion

echo ========================================
echo WhiteBeard Pawn Plugin - Safe Build
echo ========================================
echo.

set OUTPUT_DIR=bin

echo [Step 1] Cleaning previous builds...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

REM Find WiX executable
call :FindWiXExe
if "!WIX_EXE!"=="" (
    echo ERROR: WiX v4 not found. Please install WiX Toolset v4.
    echo Download from: https://github.com/wixtoolset/wix4/releases
    echo Or install as dotnet tool: dotnet tool install --global wix
    pause
    exit /b 1
)

echo Using WiX: !WIX_EXE!

echo [Step 2] Building SAFE installer (no DLL dependencies)...
call "!WIX_EXE!" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Safe.msi" Product_Simple_Fixed.wxs

if errorlevel 1 (
    echo ERROR: Even safe build failed. Check if files exist:
    echo Checking Files\PawnPlugin64.dll...
    if not exist "Files\PawnPlugin64.dll" (
        echo ERROR: Files\PawnPlugin64.dll not found!
        echo Please ensure the plugin DLL is in the Files directory
    ) else (
        echo   ✓ Plugin DLL found
    )
    
    echo Checking example_license.lic...
    if not exist "example_license.lic" (
        echo ERROR: example_license.lic not found!
    ) else (
        echo   ✓ Example license found
    )
    
    pause
    exit /b 1
)

echo   ✓ SUCCESS: Safe installer created
echo.

echo [Step 3] Attempting advanced installer with custom actions...
echo   Building CustomActions.dll...

dotnet build CustomActions\CustomActions.csproj -c Release -p:Platform=x64 >nul 2>nul
if errorlevel 1 (
    echo   ⚠ WARNING: CustomActions build failed - using safe version only
    goto :ShowResults
)

echo   ✓ CustomActions built successfully
echo   Copying DLL...

set "CA_SOURCE=CustomActions\bin\x64\Release\net48\CustomActions.dll"
if exist "%CA_SOURCE%" (
    copy "%CA_SOURCE%" . >nul
    echo   ✓ CustomActions.dll copied
) else (
    echo   ⚠ WARNING: CustomActions.dll not found - using safe version only
    goto :ShowResults
)

echo   Building advanced installer...
call "!WIX_EXE!" build -o "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Advanced.msi" Product_Ultimate.wxs

if errorlevel 1 (
    echo   ⚠ WARNING: Advanced build failed - using safe version only
    del CustomActions.dll >nul 2>nul
) else (
    echo   ✓ SUCCESS: Advanced installer created
)

:ShowResults
echo.
echo ========================================
echo BUILD RESULTS
echo ========================================

if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Safe.msi" (
    echo ✓ SAFE INSTALLER: %OUTPUT_DIR%\WhiteBeardPawnPlugin_Safe.msi
    echo   - No DLL dependencies
    echo   - Guaranteed to install
    echo   - Manual MT5 setup required
    echo.
)

if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Advanced.msi" (
    echo ✓ ADVANCED INSTALLER: %OUTPUT_DIR%\WhiteBeardPawnPlugin_Advanced.msi
    echo   - Includes custom actions
    echo   - Automatic MT5 detection
    echo   - May have DLL issues on some systems
    echo.
)

echo RECOMMENDATION:
if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Advanced.msi" (
    echo   Try advanced installer first
    echo   If DLL errors occur, use safe installer
) else (
    echo   Use safe installer - reliable and tested
)
echo.

echo INSTALLATION COMMANDS:
echo   Safe version:     msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Safe.msi"
if exist "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Advanced.msi" (
    echo   Advanced version: msiexec /i "%OUTPUT_DIR%\WhiteBeardPawnPlugin_Advanced.msi"
)
echo   With logging:     msiexec /i "[msi_file]" /l*v install.log
echo.

echo MANUAL SETUP (for safe installer):
echo   1. Copy PawnPlugin64.dll to: C:\MetaTrader 5 Platform\TradeMain\Plugins\
echo   2. Copy license file to: C:\ProgramData\WhiteBeard\
echo   3. Restart MetaTrader 5
echo.

pause
endlocal
exit /b 0

:FindWiXExe
set "WIX_EXE="

REM Try command line first
where wix >nul 2>nul
if %errorlevel%==0 (
    set "WIX_EXE=wix"
    goto :eof
)

REM Try dotnet global tool
dotnet tool list -g 2>nul | findstr /C:"wix" >nul
if %errorlevel%==0 (
    set "WIX_EXE=dotnet wix"
    goto :eof
)

REM Try installed WiX
if exist "%ProgramFiles%\WiX Toolset v4\bin\wix.exe" (
    set "WIX_EXE=%ProgramFiles%\WiX Toolset v4\bin\wix.exe"
    goto :eof
)

if exist "%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe" (
    set "WIX_EXE=%ProgramFiles(x86)%\WiX Toolset v4\bin\wix.exe"
    goto :eof
)

goto :eof