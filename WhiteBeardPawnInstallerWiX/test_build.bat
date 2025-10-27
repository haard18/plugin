@echo off
REM Quick test build script to verify fixes

echo Testing CustomActions build...
dotnet build CustomActions\CustomActions.csproj -c Release -o bin
if errorlevel 1 (
    echo FAILED: CustomActions build failed
    exit /b 1
)

echo Testing CustomActions.dll copy...
copy bin\CustomActions.dll .
if errorlevel 1 (
    echo FAILED: Could not copy CustomActions.dll
    exit /b 1
)

echo SUCCESS: Basic build components work
echo You can now run the full build.bat script