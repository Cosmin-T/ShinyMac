# CleanupBuddy - Quick Start Guide

## 🚀 Run the App

```bash
./CleanupBuddy
```

## 🔐 First Time Setup

1. When you first run the app, macOS will ask for **Accessibility permissions**
2. Click "Open System Settings"
3. Toggle ON the switch next to CleanupBuddy
4. Restart the app: `./CleanupBuddy`

## 🎮 How to Use

### Lock Everything
1. Click the big **START** button
2. Button turns **ORANGE** = Everything is locked! 🔒
3. Clean your keyboard and trackpad safely

### Unlock
**Method 1: Both Command Keys**
- Press **Left ⌘** + **Right ⌘** at the same time
- 3-second countdown appears
- Unlocks when countdown hits 0

**Method 2: Emergency Exit**
- Press **ESC** key
- Instantly unlocks everything
- Perfect for testing!

## ⚠️ Safety Features

- **Auto-unlock**: Unlocks after 5 minutes automatically
- **ESC always works**: Emergency exit is always available
- **Visual feedback**: Orange = locked, Gray = unlocked

## 🛠️ Rebuild

```bash
./build.sh
```

## 📝 Edit in Vim/Zed

All files are plain Swift - edit with any text editor:
- `main.swift` - App entry point
- `AppDelegate.swift` - Window setup
- `MainViewController.swift` - UI and buttons
- `LockManager.swift` - Keyboard locking
- `TouchpadManager.swift` - Trackpad locking

## 🎨 Customize

Want different colors? Edit `MainViewController.swift`:
```swift
// Line ~90 - Orange locked color
NSColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)

// Line ~95 - Gray unlocked color  
NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
```

Want longer countdown? Edit `MainViewController.swift`:
```swift
// Line ~148
countdown = 3  // Change to 5, 10, etc.
```

---

**That's it! Enjoy your clean keyboard! 🧼✨**
