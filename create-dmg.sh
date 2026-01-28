#!/bin/bash

# ShinyMac - DMG Creator
# Creates a distributable DMG file with drag-to-Applications layout

set -e

APP_NAME="ShinyMac"
VERSION="1.0.5"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_TEMP="$BUILD_DIR/dmg_temp"

echo "📀 Creating DMG for $APP_NAME v$VERSION..."

# Check if app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found. Run ./build-app.sh first!"
    exit 1
fi

# Clean previous DMG
if [ -f "$BUILD_DIR/$DMG_NAME" ]; then
    echo "🧹 Removing previous DMG..."
    rm "$BUILD_DIR/$DMG_NAME"
fi

# Method 1: Using create-dmg (if installed via npm/homebrew)
if command -v create-dmg &> /dev/null; then
    echo "✨ Using create-dmg tool..."
    
    # Clean up any previous temp directory
    rm -rf "$DMG_TEMP"
    
    # Create temporary directory with just the app
    mkdir -p "$DMG_TEMP"
    cp -R "$APP_BUNDLE" "$DMG_TEMP/"
    
    # Create DMG with correct syntax: create-dmg <output.dmg> <source_folder>
    # The --app-drop-link option creates the Applications symlink automatically
    create-dmg \
        --volname "$APP_NAME" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "$APP_NAME.app" 175 120 \
        --hide-extension "$APP_NAME.app" \
        --app-drop-link 425 120 \
        "$BUILD_DIR/$DMG_NAME" \
        "$DMG_TEMP"
    
    # Clean up
    rm -rf "$DMG_TEMP"
    
elif command -v hdiutil &> /dev/null; then
    # Method 2: Using hdiutil (built-in macOS tool)
    echo "🔧 Using hdiutil (macOS built-in)..."
    
    # Create temporary directory
    mkdir -p "$DMG_TEMP"
    
    # Copy app to temp directory
    cp -R "$APP_BUNDLE" "$DMG_TEMP/"
    
    # Create symbolic link to Applications folder
    ln -s /Applications "$DMG_TEMP/Applications"
    
    # Create DMG
    hdiutil create -volname "$APP_NAME" \
        -srcfolder "$DMG_TEMP" \
        -ov -format UDZO \
        "$BUILD_DIR/$DMG_NAME"
    
    # Clean up
    rm -rf "$DMG_TEMP"
    
else
    echo "❌ No DMG creation tool found!"
    echo ""
    echo "Install create-dmg with:"
    echo "  npm install -g create-dmg"
    echo "  OR"
    echo "  brew install create-dmg"
    exit 1
fi

# Verify DMG was created
if [ -f "$BUILD_DIR/$DMG_NAME" ]; then
    DMG_SIZE=$(du -h "$BUILD_DIR/$DMG_NAME" | cut -f1)
    echo ""
    echo "✅ DMG created successfully!"
    echo ""
    echo "📦 File: $BUILD_DIR/$DMG_NAME"
    echo "📏 Size: $DMG_SIZE"
    echo ""
    echo "To test the DMG:"
    echo "  open $BUILD_DIR/$DMG_NAME"
    echo ""
    echo "To distribute:"
    echo "  1. Test the DMG on a clean Mac"
    echo "  2. (Optional) Notarize with Apple Developer account"
    echo "  3. Share the DMG file"
else
    echo "❌ DMG creation failed!"
    exit 1
fi
