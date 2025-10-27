@echo off
REM ULTIMATE BUILD SCRIPT - Combines working minimal approach with custom actions

setlocal enabledelayedexpansion

echo ========================================
echo ULTIMATE WhiteBeard Pawn Plugin Build
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
copy bin\CustomActions.dll .

REM Create enhanced minimal WiX file with custom actions
echo [2/3] Creating enhanced installer...
echo ^<?xml version="1.0" encoding="UTF-8"?^> > ultimate.wxs
echo ^<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs"^> >> ultimate.wxs
echo   ^<Package >> ultimate.wxs
echo     Name="WhiteBeard Pawn Plugin" >> ultimate.wxs
echo     Language="1033" >> ultimate.wxs
echo     Version="1.0.0.0" >> ultimate.wxs
echo     Manufacturer="WhiteBeard" >> ultimate.wxs
echo     UpgradeCode="12345678-1234-1234-1234-123456789012"^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<SummaryInformation Description="WhiteBeard Pawn Plugin for MetaTrader 5" /^> >> ultimate.wxs
echo     ^<MajorUpgrade DowngradeErrorMessage="A newer version is already installed." /^> >> ultimate.wxs
echo     ^<MediaTemplate EmbedCab="yes" /^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<StandardDirectory Id="ProgramFilesFolder"^> >> ultimate.wxs
echo       ^<Directory Id="INSTALLFOLDER" Name="WhiteBeard Pawn Plugin" /^> >> ultimate.wxs
echo     ^</StandardDirectory^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<Feature Id="MainFeature" Title="WhiteBeard Pawn Plugin" Level="1"^> >> ultimate.wxs
echo       ^<ComponentRef Id="MainComponent" /^> >> ultimate.wxs
echo       ^<ComponentRef Id="RegistryComponent" /^> >> ultimate.wxs
echo     ^</Feature^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<Binary Id="CustomActionsBinary" SourceFile="CustomActions.dll" /^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<CustomAction >> ultimate.wxs
echo       Id="InstallPluginFilesAction" >> ultimate.wxs
echo       BinaryRef="CustomActionsBinary" >> ultimate.wxs
echo       DllEntry="InstallPluginFiles" >> ultimate.wxs
echo       Execute="deferred" >> ultimate.wxs
echo       Return="check" >> ultimate.wxs
echo       Impersonate="no" /^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<InstallExecuteSequence^> >> ultimate.wxs
echo       ^<Custom Action="InstallPluginFilesAction" After="InstallFiles" Condition="NOT Installed" /^> >> ultimate.wxs
echo     ^</InstallExecuteSequence^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<Property Id="LICENSE_PATH" /^> >> ultimate.wxs
echo     ^<Property Id="COMPANY_NAME" /^> >> ultimate.wxs
echo     ^<Property Id="COMPANY_EMAIL" /^> >> ultimate.wxs
echo     ^<Property Id="MT5_ROOT" /^> >> ultimate.wxs
echo. >> ultimate.wxs
echo   ^</Package^> >> ultimate.wxs
echo. >> ultimate.wxs
echo   ^<Fragment^> >> ultimate.wxs
echo     ^<Component Id="MainComponent" Directory="INSTALLFOLDER"^> >> ultimate.wxs
echo       ^<File Id="PluginDLL" Name="PawnPlugin64.dll" Source="Files\PawnPlugin64.dll" KeyPath="yes" /^> >> ultimate.wxs
echo     ^</Component^> >> ultimate.wxs
echo. >> ultimate.wxs
echo     ^<Component Id="RegistryComponent" Directory="INSTALLFOLDER"^> >> ultimate.wxs
echo       ^<RegistryValue >> ultimate.wxs
echo         Root="HKLM" >> ultimate.wxs
echo         Key="Software\WhiteBeard\PawnPlugin" >> ultimate.wxs
echo         Name="Installed" >> ultimate.wxs
echo         Value="1" >> ultimate.wxs
echo         Type="integer" >> ultimate.wxs
echo         KeyPath="yes" /^> >> ultimate.wxs
echo       ^<RegistryValue >> ultimate.wxs
echo         Root="HKLM" >> ultimate.wxs
echo         Key="Software\WhiteBeard\PawnPlugin" >> ultimate.wxs
echo         Name="Version" >> ultimate.wxs
echo         Value="1.0.0" >> ultimate.wxs
echo         Type="string" /^> >> ultimate.wxs
echo       ^<RegistryValue >> ultimate.wxs
echo         Root="HKLM" >> ultimate.wxs
echo         Key="Software\WhiteBeard\PawnPlugin" >> ultimate.wxs
echo         Name="InstallDir" >> ultimate.wxs
echo         Value="[INSTALLFOLDER]" >> ultimate.wxs
echo         Type="string" /^> >> ultimate.wxs
echo     ^</Component^> >> ultimate.wxs
echo   ^</Fragment^> >> ultimate.wxs
echo. >> ultimate.wxs
echo ^</Wix^> >> ultimate.wxs

REM Build the installer
echo [3/3] Building ultimate installer...
wix build -o bin\WhiteBeardPawnPlugin_Ultimate.msi ultimate.wxs

if exist bin\WhiteBeardPawnPlugin_Ultimate.msi (
    echo.
    echo ========================================
    echo SUCCESS! ULTIMATE INSTALLER CREATED!
    echo ========================================
    echo Output: bin\WhiteBeardPawnPlugin_Ultimate.msi
    echo File size:
    dir bin\WhiteBeardPawnPlugin_Ultimate.msi | findstr WhiteBeardPawnPlugin_Ultimate.msi
    echo.
    echo This installer includes:
    echo ✓ Plugin file installation
    echo ✓ Registry entries
    echo ✓ Custom actions for MT5 plugin deployment
    echo ✓ Proper WiX v4 syntax
    echo.
    echo To install:
    echo   msiexec /i bin\WhiteBeardPawnPlugin_Ultimate.msi
    echo.
) else (
    echo FAILED: Could not create ultimate installer
    echo Check the generated ultimate.wxs file for issues
    type ultimate.wxs
)

REM Keep the generated file for inspection
echo Generated WiX file saved as: ultimate.wxs

pause