# CleanupBuddy - Changelog

## Version 2.0 - UI & Behavior Fixes

### Fixed Issues

#### 1. ✅ Removed Emojis
- **Before**: Used emoji characters (🔒, ⌘) in UI
- **After**: Clean text-only interface
- Changed "🔒 Cleaning Mode Active" → "Cleaning Mode Active"
- Changed "⌘ Command keys" → "Command keys"

#### 2. ✅ Added Window Controls
- **Before**: Borderless fullscreen window (no close/minimize buttons)
- **After**: Normal window with title bar, close, and minimize buttons
- Window size: 800x600 (centered on screen)
- Title: "CleanupBuddy"
- Can now close, minimize, and move the window normally

#### 3. ✅ Fixed Command Key Unlock Behavior
- **Before**: Unlocked instantly when both Command keys pressed
- **After**: Requires holding BOTH Command keys for 3 seconds
- Shows console message: "Both Command keys pressed - hold for 3 seconds..."
- After 3 seconds: Triggers unlock countdown
- If keys released early: Cancels unlock attempt

#### 4. ✅ Added Button Press Feedback
- **Before**: No visual feedback when clicking buttons
- **After**: Buttons darken when pressed
- Created custom `PressableButton` class
- Normal state: Dark gray (#333333)
- Pressed state: Darker gray (#262626)
- Locked state: Orange (#FF6600)
- Locked pressed: Darker orange (#E65900)

### Technical Changes

#### AppDelegate.swift
```swift
// Changed from borderless fullscreen to normal window
window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
    styleMask: [.titled, .closable, .miniaturizable],
    backing: .buffered,
    defer: false
)
```

#### LockManager.swift
```swift
// Added 3-second hold timer
private var holdTimer: Timer?
private var bothKeysHeldStartTime: Date?

// Timer checks if both keys held for 3 seconds
holdTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { ... }
```

#### MainViewController.swift
```swift
// New custom button class with press feedback
class PressableButton: NSButton {
    override func mouseDown(with event: NSEvent) {
        self.layer?.backgroundColor = pressedColor.cgColor
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.layer?.backgroundColor = normalColor.cgColor
        super.mouseUp(with: event)
    }
}
```

### How to Use (Updated)

1. **Launch**: `./CleanupBuddy`
2. **Lock**: Click START button
3. **Unlock**: Hold BOTH Command keys (left + right) for 3 seconds
4. **Emergency**: Press ESC to unlock immediately
5. **Close**: Click the red X button (normal window controls)

### Next Steps

If you want to add SVG icons instead of text, we can:
1. Create lock/unlock icon assets
2. Use `NSImage` to load SVG files
3. Display icons next to or instead of text labels

Let me know if you want to implement SVG icons!
