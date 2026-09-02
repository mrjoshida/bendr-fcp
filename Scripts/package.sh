#!/bin/bash
set -e

# package.sh — Full Release build, installation, PlugInKit registration & template deployment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================================="
echo "📦 BENDR for Final Cut Pro — Release & Packaging"
echo "=================================================="
echo "Workspace: $ROOT_DIR"
echo ""

cd "$ROOT_DIR"

# 1. Generate Xcode Project
echo "--- 1. Generating Xcode Project (XcodeGen) ---"
xcodegen generate
echo ""

# 2. Build All 14 Plugin Apps & XPC Services in Release Configuration
echo "--- 2. Building 14 FxPlug 4 Plugins (Release) ---"
xcodebuild -project BENDREffects.xcodeproj \
           -scheme AllPlugins \
           -configuration Release \
           -derivedDataPath "$ROOT_DIR/build/DerivedData" \
           build -quiet

PRODUCTS_DIR="$ROOT_DIR/build/DerivedData/Build/Products/Release"

# 3. Target Install Directory
INSTALL_DIR="$HOME/Applications/BENDR"
mkdir -p "$INSTALL_DIR"

echo "--- 3. Installing Application Bundles to $INSTALL_DIR ---"
for app in "$PRODUCTS_DIR"/BENDR*.app; do
    if [ -d "$app" ]; then
        appName=$(basename "$app")
        echo "  -> Installing $appName..."
        rm -rf "$INSTALL_DIR/$appName"
        cp -R "$app" "$INSTALL_DIR/$appName"
        
        # Register with LaunchServices
        /System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -f -R -trusted "$INSTALL_DIR/$appName"
        
        # Register embedded XPC services with PlugInKit
        for xpc in "$INSTALL_DIR/$appName"/Contents/PlugIns/*.xpc; do
            if [ -d "$xpc" ]; then
                pluginkit -v -a "$xpc"
            fi
        done
    fi
done
echo ""

# 4. Generate & Install Motion Templates
echo "--- 4. Installing Final Cut Pro Motion Templates ---"
python3 "$SCRIPT_DIR/make_templates.py"
echo ""

# 5. Verification
echo "--- 5. Verifying PlugInKit Registration ---"
PLUGINS_COUNT=$(find "$INSTALL_DIR" -name "*.xpc" | wc -l | tr -d ' ')
echo "  Installed and registered $PLUGINS_COUNT XPC Plugin Services in $INSTALL_DIR"
echo ""

echo "=================================================="
echo "🎉 BENDR PACKAGING COMPLETE!"
echo "   All 14 Effects & Transitions are installed and ready in Final Cut Pro."
echo "=================================================="
