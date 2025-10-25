#!/bin/bash
# Build script for WhiteBeard Pawn Plugin Installer (Linux/macOS)
# For Windows, use build.bat

set -e  # Exit on first error

echo "========================================"
echo "WhiteBeard Pawn Plugin Installer Build"
echo "========================================"
echo ""

# Set paths
OUTPUT_DIR="bin"
OBJ_DIR="obj"
DOTNET_BIN="dotnet"

echo "[1/5] Cleaning previous builds..."
rm -rf "$OUTPUT_DIR" "$OBJ_DIR"
mkdir -p "$OUTPUT_DIR" "$OBJ_DIR"

echo "[2/5] Building C# Custom Actions..."
$DOTNET_BIN build CustomActions/CustomActions.csproj -c Release -o "$OUTPUT_DIR"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build custom actions"
    exit 1
fi
echo "SUCCESS: Custom actions built"

echo "[3/5] Copying custom actions DLL..."
cp "$OUTPUT_DIR/CustomActions.dll" ./
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy CustomActions.dll"
    exit 1
fi

echo "[4/5] Compiling WiX source files..."
# Note: On macOS/Linux, you would need WiX tools compiled for your platform
# Alternatively, use WSL (Windows Subsystem for Linux) with Windows tools
echo "NOTE: WiX compilation requires Windows or WiX cross-platform tools"
echo "Please use build.bat on Windows or WSL for MSI compilation"

echo ""
echo "========================================"
echo "C# compilation complete!"
echo "========================================"
echo ""
echo "To build the MSI installer:"
echo "1. Transfer to a Windows machine"
echo "2. Run: build.bat"
echo "3. The MSI will be generated in bin/"
echo ""
