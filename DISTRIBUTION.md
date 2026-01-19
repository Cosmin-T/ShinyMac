# ShinyMac - Distribution Guide

## Building for Distribution

### Prerequisites

```bash
# Install icon conversion tool (optional but recommended)
brew install librsvg

# Install DMG creation tool (choose one)
npm install -g create-dmg
# OR
brew install create-dmg
```

### Build Steps

#### 1. Build the App Bundle

```bash
chmod +x build-app.sh
./build-app.sh
```

This creates `build/ShinyMac.app` with:
- Compiled binary
- App icon (if librsvg installed)
- Info.plist with metadata
- Proper bundle structure

#### 2. Test the App

```bash
open build/ShinyMac.app
```

Grant Accessibility permissions when prompted.

#### 3. Create DMG

```bash
chmod +x create-dmg.sh
./create-dmg.sh
```

This creates `build/ShinyMac-1.0.0.dmg`

---

## DMG Contents (2026 Best Practices)

### What's Included

✅ **ShinyMac.app** - The application bundle  
✅ **Applications symlink** - Drag-and-drop installation  
✅ **Custom icon** - Professional appearance  
✅ **Proper metadata** - Version, bundle ID, etc.

### What's NOT Included (Intentionally)

❌ **Installer (.pkg)** - Not needed for simple apps  
❌ **License agreement** - Adds friction  
❌ **README in DMG** - Keep it simple  

---

## Distribution Methods

### Method 1: Direct Download (Recommended)

**Pros:**
- Simple for users
- No platform fees
- Full control

**Steps:**
1. Upload `ShinyMac-1.0.0.dmg` to your website/GitHub
2. Users download and open DMG
3. Users drag app to Applications folder

### Method 2: GitHub Releases

```bash
# Create a release on GitHub
gh release create v1.0.0 build/ShinyMac-1.0.0.dmg \
    --title "ShinyMac v1.0.0" \
    --notes "Initial release"
```

### Method 3: Gumroad/Paid Distribution

1. Upload DMG to Gumroad
2. Set price (or free)
3. Gumroad handles delivery

---

## Code Signing & Notarization (Optional)

### Without Apple Developer Account ($0)

**What happens:**
- Users see "App from unidentified developer"
- Users must right-click → Open to bypass Gatekeeper
- App works fine after first open

**Workaround for users:**
```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine /Applications/ShinyMac.app
```

### With Apple Developer Account ($99/year)

**Benefits:**
- No Gatekeeper warnings
- Professional appearance
- Required for Mac App Store

**Steps:**

1. **Sign the app:**
```bash
codesign --deep --force --verify --verbose \
    --sign "Developer ID Application: Your Name" \
    build/ShinyMac.app
```

2. **Create DMG** (same as before)

3. **Notarize:**
```bash
# Submit for notarization
xcrun notarytool submit build/ShinyMac-1.0.0.dmg \
    --apple-id your@email.com \
    --team-id TEAMID \
    --password app-specific-password \
    --wait

# Staple the notarization
xcrun stapler staple build/ShinyMac-1.0.0.dmg
```

---

## File Structure

```
ShinyMac-1.0.0.dmg
├── ShinyMac.app/
│   ├── Contents/
│   │   ├── MacOS/
│   │   │   └── ShinyMac (binary)
│   │   ├── Resources/
│   │   │   └── ShinyMac.icns (icon)
│   │   ├── Info.plist (metadata)
│   │   └── PkgInfo
│   └── ...
└── Applications@ (symlink to /Applications)
```

---

## Testing Checklist

Before distributing:

- [ ] Test on a **clean Mac** (not your dev machine)
- [ ] Verify drag-to-Applications works
- [ ] Test app launches and requests permissions
- [ ] Test locking/unlocking functionality
- [ ] Test on different macOS versions (if possible)
- [ ] Check DMG opens without errors
- [ ] Verify icon displays correctly

---

## Common Issues

### "App is damaged and can't be opened"

**Cause:** Gatekeeper quarantine  
**Solution:** User runs:
```bash
xattr -d com.apple.quarantine /Applications/ShinyMac.app
```

### "App from unidentified developer"

**Cause:** Not code-signed  
**Solution:** User right-clicks → Open (first time only)

### Icon doesn't show

**Cause:** librsvg not installed during build  
**Solution:** Install librsvg and rebuild:
```bash
brew install librsvg
./build-app.sh
```

---

## Version Updates

To release a new version:

1. Update `VERSION` in `build-app.sh`
2. Rebuild: `./build-app.sh`
3. Create DMG: `./create-dmg.sh`
4. Distribute new DMG

---

## Recommended Distribution Flow (2026)

```
1. Build app bundle (build-app.sh)
2. Test locally
3. Create DMG (create-dmg.sh)
4. Test DMG on clean Mac
5. Upload to GitHub Releases / Website
6. Share download link
```

**No code signing needed** for free distribution!  
**No Mac App Store needed** for independent apps!  
**No installer needed** for simple drag-and-drop apps!

---

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/xcode/distributing-your-app-outside-the-mac-app-store)
- [create-dmg tool](https://github.com/sindresorhus/create-dmg)
- [Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

---

**Built with ❤️ for macOS**
