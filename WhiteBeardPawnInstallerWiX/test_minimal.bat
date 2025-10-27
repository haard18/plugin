@echo off
REM Super simple build test - no complex UI

setlocal enabledelayedexpansion

echo ========================================
echo SIMPLE WhiteBeard Pawn Plugin Build
echo ========================================

REM Build C# Custom Actions
echo Building CustomActions...
dotnet build CustomActions\CustomActions.csproj -c Release -o bin
if errorlevel 1 (
    echo FAILED: Could not build CustomActions
    pause
    exit /b 1
)

REM Copy DLL
copy bin\CustomActions.dll .

REM Create minimal WiX file for testing
echo Creating minimal installer...
echo ^<?xml version="1.0" encoding="UTF-8"?^> > temp_minimal.wxs
echo ^<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs"^> >> temp_minimal.wxs
echo   ^<Package >> temp_minimal.wxs
echo     Name="WhiteBeard Pawn Plugin" >> temp_minimal.wxs
echo     Language="1033" >> temp_minimal.wxs
echo     Version="1.0.0.0" >> temp_minimal.wxs
echo     Manufacturer="WhiteBeard" >> temp_minimal.wxs
echo     UpgradeCode="12345678-1234-1234-1234-123456789012"^> >> temp_minimal.wxs
echo. >> temp_minimal.wxs
echo     ^<SummaryInformation Description="WhiteBeard Pawn Plugin for MetaTrader 5" /^> >> temp_minimal.wxs
echo     ^<MajorUpgrade DowngradeErrorMessage="A newer version is already installed." /^> >> temp_minimal.wxs
echo     ^<MediaTemplate EmbedCab="yes" /^> >> temp_minimal.wxs
echo. >> temp_minimal.wxs
echo     ^<StandardDirectory Id="ProgramFilesFolder"^> >> temp_minimal.wxs
echo       ^<Directory Id="INSTALLFOLDER" Name="WhiteBeard Pawn Plugin" /^> >> temp_minimal.wxs
echo     ^</StandardDirectory^> >> temp_minimal.wxs
echo. >> temp_minimal.wxs
echo     ^<Feature Id="MainFeature" Title="WhiteBeard Pawn Plugin" Level="1"^> >> temp_minimal.wxs
echo       ^<ComponentRef Id="MainComponent" /^> >> temp_minimal.wxs
echo     ^</Feature^> >> temp_minimal.wxs
echo. >> temp_minimal.wxs
echo   ^</Package^> >> temp_minimal.wxs
echo. >> temp_minimal.wxs
echo   ^<Fragment^> >> temp_minimal.wxs
echo     ^<Component Id="MainComponent" Directory="INSTALLFOLDER"^> >> temp_minimal.wxs
echo       ^<File Id="PluginDLL" Name="PawnPlugin64.dll" Source="Files\PawnPlugin64.dll" KeyPath="yes" /^> >> temp_minimal.wxs
echo     ^</Component^> >> temp_minimal.wxs
echo   ^</Fragment^> >> temp_minimal.wxs
echo. >> temp_minimal.wxs
echo ^</Wix^> >> temp_minimal.wxs

REM Try to build
wix build -o bin\WhiteBeardPawnPlugin_Minimal.msi temp_minimal.wxs

if exist bin\WhiteBeardPawnPlugin_Minimal.msi (
    echo.
    echo SUCCESS! Minimal installer created: bin\WhiteBeardPawnPlugin_Minimal.msi
    echo File size:
    dir bin\WhiteBeardPawnPlugin_Minimal.msi
) else (
    echo FAILED: Could not create minimal installer
    echo Check that:
    echo 1. WiX v4 is installed
    echo 2. Files\PawnPlugin64.dll exists
)

REM Clean up
del temp_minimal.wxs 2>nul

pause