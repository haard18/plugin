@echo off
REM Simple Ultimate Build - Uses pre-created WiX file

echo ========================================
echo SIMPLE ULTIMATE Build
echo ========================================

REM Build C# Custom Actions
echo [1/3] Building CustomActions...
dotnet build CustomActions\CustomActions.csproj -c Release -o bin
if errorlevel 1 (
    echo FAILED: Could not build CustomActions
    pause
    exit /b 1
)

REM Copy DLL
echo [2/3] Copying CustomActions.dll...
copy bin\CustomActions.dll .

REM Build using the pre-created ultimate WiX file
echo [3/3] Building with Product_Ultimate.wxs...
wix build -o bin\WhiteBeardPawnPlugin_Ultimate.msi Product_Ultimate.wxs

if exist bin\WhiteBeardPawnPlugin_Ultimate.msi (
    echo.
    echo ========================================
    echo SUCCESS! ULTIMATE INSTALLER CREATED!
    echo ========================================
    echo Output: bin\WhiteBeardPawnPlugin_Ultimate.msi
    echo.
    dir bin\WhiteBeardPawnPlugin_Ultimate.msi | findstr WhiteBeardPawnPlugin_Ultimate.msi
    echo.
    echo Features:
    echo ✓ Plugin file installation
    echo ✓ Registry entries  
    echo ✓ Custom actions for MT5 deployment
    echo ✓ Clean WiX v4 syntax
    echo.
    echo To test install:
    echo   msiexec /i bin\WhiteBeardPawnPlugin_Ultimate.msi
    echo.
    echo To install with logging:
    echo   msiexec /i bin\WhiteBeardPawnPlugin_Ultimate.msi /l*v install.log
    echo.
) else (
    echo FAILED: Could not create installer
    echo Check for errors above
)

pause