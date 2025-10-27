@echo off
REM Test the fixed Product_Fixed.wxs

echo Testing fixed Product_Fixed.wxs...

REM Quick build
dotnet build CustomActions\CustomActions.csproj -c Release -o bin
copy bin\CustomActions.dll .

REM Test build
wix build -o bin\WhiteBeardPawnPlugin_Fixed.msi Product_Fixed.wxs

if exist bin\WhiteBeardPawnPlugin_Fixed.msi (
    echo SUCCESS! Product_Fixed.wxs works!
    dir bin\WhiteBeardPawnPlugin_Fixed.msi | findstr WhiteBeardPawnPlugin_Fixed.msi
) else (
    echo FAILED: Product_Fixed.wxs still has issues
)

pause