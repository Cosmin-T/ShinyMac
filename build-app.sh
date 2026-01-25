#!/bin/bash

# ShinyMac - Complete App Bundle Builder
# Creates a proper .app bundle with icon and Info.plist

set -e

APP_NAME="ShinyMac"
VERSION="1.0.4"
BUNDLE_ID="com.shinymac.app"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🔨 Building $APP_NAME v$VERSION..."

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

# Create app bundle structure
echo "📁 Creating app bundle structure..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile Swift code
echo "⚙️  Compiling Swift code..."
swiftc -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    main.swift \
    AppDelegate.swift \
    MainViewController.swift \
    LockManager.swift \
    TouchpadManager.swift \
    -framework Cocoa \
    -framework Carbon \
    -framework IOKit \
    -O

# Convert SVG to ICNS (requires rsvg-convert and iconutil)
echo "🎨 Creating app icon..."
if command -v rsvg-convert &> /dev/null; then
    # Create iconset directory
    ICONSET_DIR="$BUILD_DIR/$APP_NAME.iconset"
    mkdir -p "$ICONSET_DIR"
    
    # Generate all required icon sizes
    for size in 16 32 64 128 256 512 1024; do
        rsvg-convert -w $size -h $size icon.svg -o "$ICONSET_DIR/icon_${size}x${size}.png"
        if [ $size -le 512 ]; then
            size2x=$((size * 2))
            rsvg-convert -w $size2x -h $size2x icon.svg -o "$ICONSET_DIR/icon_${size}x${size}@2x.png"
        fi
    done
    
    # Convert to icns
    iconutil -c icns "$ICONSET_DIR" -o "$APP_BUNDLE/Contents/Resources/$APP_NAME.icns"
    rm -rf "$ICONSET_DIR"
    
    ICON_FILE="$APP_NAME.icns"
else
    echo "⚠️  rsvg-convert not found. Install with: brew install librsvg"
    echo "   Skipping icon creation..."
    ICON_FILE=""
fi

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>$ICON_FILE</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.14</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026. All rights reserved.</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
</dict>
</plist>
EOF

# Create PkgInfo
echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# Ad-hoc code signing (helps prevent "damaged" error)
echo "🔐 Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || echo "⚠️  Code signing skipped (codesign not available)"

echo "✅ App bundle created successfully!"
echo ""
echo "📦 Location: $APP_BUNDLE"
echo ""
echo "To test the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "To create a DMG:"
echo "  ./create-dmg.sh"
