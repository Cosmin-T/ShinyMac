# CleanupBuddy - Window Level Fix

## Issue: Window Hidden Behind Other Apps

**Problem**: The app window starts behind all other windows and cannot be brought to front.

**Root Cause**: Window level was set to `.normal` which places it behind other apps.

## Solution

### 1. Set Initial Window Level to Floating
```swift
// In AppDelegate.swift - createFullscreenWindow()
window.level = .floating
window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
```

**Effect**: Window now floats above normal windows when app launches.

### 2. Dynamic Window Level Based on Lock State

Added method to change window level when locking/unlocking:

```swift
// In AppDelegate.swift
func setWindowLevel(locked: Bool) {
    if locked {
        // When locked, stay on top of EVERYTHING
        window.level = .screenSaver
    } else {
        // When unlocked, float above normal windows
        window.level = .floating
    }
}
```

### 3. Call Window Level Changes

```swift
// In MainViewController.swift - lockEverything()
appDelegate?.setWindowLevel(locked: true)

// In MainViewController.swift - unlockEverything()
appDelegate?.setWindowLevel(locked: false)
```

## Window Levels Explained

macOS has different window levels (from lowest to highest):

| Level | Value | Usage | CleanupBuddy |
|-------|-------|-------|--------------|
| `.normal` | 0 | Regular app windows | ❌ Too low |
| `.floating` | 3 | Utility windows, always visible | ✅ Unlocked state |
| `.modalPanel` | 8 | Modal dialogs | - |
| `.popUpMenu` | 101 | Pop-up menus | - |
| `.screenSaver` | 1000 | Screen savers, critical alerts | ✅ Locked state |

## Behavior Now

### When App Launches
- Window level: `.floating`
- Appears **above** normal windows (Safari, Finder, etc.)
- Can still be hidden by full-screen apps
- Can be minimized/closed normally

### When Locked (START clicked)
- Window level: `.screenSaver`
- Appears **above everything** (even full-screen apps)
- Cannot be hidden or minimized
- Stays on top for cleaning

### When Unlocked
- Window level: `.floating`
- Returns to normal floating behavior
- Can be moved, minimized, closed

## Additional Fixes

### Removed All Emojis
- Print statements now use plain text
- Console output is cleaner
- Better for logging/debugging

**Before**:
```
🔒 Keyboard locked
⌘ Both Command keys pressed
🔓 Trackpad unlocked
```

**After**:
```
Keyboard locked
Both Command keys pressed
Trackpad unlocked
```

## Testing

1. **Launch app**: `./CleanupBuddy`
   - Should appear on top of other windows
   - Should be visible immediately

2. **Click START**:
   - Window should stay on top of EVERYTHING
   - Even full-screen apps won't hide it

3. **Hold both Command keys for 3 seconds**:
   - Countdown appears
   - Window unlocks
   - Returns to normal floating level

4. **Close window**:
   - Red X button works normally
   - App quits

## Summary

✅ Window now visible on launch  
✅ Floats above normal windows when unlocked  
✅ Stays on top of everything when locked  
✅ All emojis removed from code  
✅ Clean console output  

The app is now fully functional and visible!
