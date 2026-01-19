#!/bin/bash

# ShinyMac Build Script
# Compiles Swift files into a standalone macOS application

set -e  # Exit on error

echo "🔨 Building ShinyMac..."

# Clean previous builds
if [ -f "ShinyMac" ]; then
    echo "🧹 Cleaning previous build..."
    rm -f ShinyMac
fi

# Also clean old CleanupBuddy binary
if [ -f "CleanupBuddy" ]; then
    rm -f CleanupBuddy
fi

# Compile all Swift files
echo "⚙️  Compiling Swift files..."
swiftc -o ShinyMac \
    main.swift \
    AppDelegate.swift \
    MainViewController.swift \
    LockManager.swift \
    TouchpadManager.swift \
    -framework Cocoa \
    -framework Carbon \
    -framework IOKit \
    -O

# Check if build succeeded
if [ -f "ShinyMac" ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📦 Binary created: ./ShinyMac"
    echo ""
    echo "To run:"
    echo "  ./ShinyMac"
    echo ""
    echo "⚠️  Note: You'll need to grant Accessibility permissions on first run"
    echo "   Go to: System Settings → Privacy & Security → Accessibility"
else
    echo "❌ Build failed!"
    exit 1
fi
