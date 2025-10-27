@echo off
REM Test build with simple WiX file

echo Testing simple WiX build...

REM Build C# first
dotnet build CustomActions\CustomActions.csproj -c Release -o bin
copy bin\CustomActions.dll .

REM Create dummy plugin file for testing
if not exist Files mkdir Files
echo dummy > Files\PawnPlugin64.dll

REM Try WiX build
wix build -o bin\WhiteBeardPawnPlugin_Simple.msi Product_Simple.wxs

if exist bin\WhiteBeardPawnPlugin_Simple.msi (
    echo SUCCESS: Simple build worked!
) else (
    echo FAILED: Simple build failed
)