import Cocoa
import Carbon

class LockManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private(set) var isLocked = false
    
    // Unlock handler
    var unlockHandler: (() -> Void)?
    
    // CMD key state change handler (for visual feedback)
    var cmdKeyStateChanged: ((Bool, Bool) -> Void)?
    
    // Track command key states
    private var leftCmdPressed = false
    private var rightCmdPressed = false
    
    // Timer for 3-second hold requirement
    private var holdTimer: Timer?
    private var bothKeysHeldStartTime: Date?
    
    func setupEventTap() {
        // Get reference to self for callback
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        // Create event mask for all keyboard events including media/function keys
        // Type 14 = NSSystemDefined (media keys, function keys, etc.)
        let keyboardMask: CGEventMask = (1 << CGEventType.keyDown.rawValue) |
                                        (1 << CGEventType.keyUp.rawValue) |
                                        (1 << CGEventType.flagsChanged.rawValue) |
                                        (1 << 14)  // NSSystemDefined for media/function keys
        
        // Create event tap
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: keyboardMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }
                
                let manager = Unmanaged<LockManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleKeyboardEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: selfPointer
        )
        
        guard let tap = eventTap else {
            print("❌ Failed to create keyboard event tap")
            return
        }
        
        // Create run loop source
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        // Add to run loop
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
    }
    
    func lock(_ shouldLock: Bool) {
        isLocked = shouldLock
        
        if shouldLock {
            // Enable event tap
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
                print("Keyboard locked")
            }
        } else {
            // Disable event tap
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: false)
                print("Keyboard unlocked")
            }
            
            // Reset command key states
            leftCmdPressed = false
            rightCmdPressed = false
            bothKeysHeldStartTime = nil
            holdTimer?.invalidate()
        }
    }
    
    private func handleKeyboardEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // If not locked, pass through all events
        guard isLocked else {
            return Unmanaged.passRetained(event)
        }
        
        // Block NSSystemDefined events (type 14) - these are media keys and function keys
        if type.rawValue == 14 {
            print("🚫 Blocking media/function key (type 14)")
            return nil
        }
        
        // EMERGENCY UNLOCK: ESC key triggers immediate unlock
        // COMMENTED OUT - Uncomment if you need emergency unlock during testing
        /*
        if type == .keyDown && event.getIntegerValueField(.keyboardEventKeycode) == 53 {
            print("ESC key pressed - UNLOCKING IMMEDIATELY")
            // Cancel any timers
            holdTimer?.invalidate()
            holdTimer = nil
            bothKeysHeldStartTime = nil
            // Trigger unlock
            unlockHandler?()
            // Reset states
            leftCmdPressed = false
            rightCmdPressed = false
            cmdKeyStateChanged?(false, false)
            return nil  // Block the ESC key event itself
        }
        */
        
        // Handle flags changed (for modifier keys like Cmd)
        if type == .flagsChanged {
            let flags = event.flags
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            // Left Command: keyCode 55
            // Right Command: keyCode 54
            
            // THE FIX: Only update the state of the SPECIFIC key that triggered this event
            // Don't look at flags.contains(.maskCommand) because it's true if ANY cmd is pressed
            
            let cmdFlagPresent = flags.contains(.maskCommand)
            let wasLeftPressed = leftCmdPressed
            let wasRightPressed = rightCmdPressed
            
            if keyCode == 55 {
                // Left command key event
                if cmdFlagPresent && !wasLeftPressed {
                    // Left key pressed
                    leftCmdPressed = true
                    print("Left CMD pressed")
                } else if !cmdFlagPresent {
                    // Left key released (cmd flag gone means ALL cmd keys released)
                    leftCmdPressed = false
                    print("Left CMD released")
                } else if wasLeftPressed && cmdFlagPresent && wasRightPressed {
                    // SPECIAL CASE: Left was pressed, cmd flag still present, right was also pressed
                    // This means left was just released but right is still held
                    leftCmdPressed = false
                    print("Left CMD released (right still held)")
                }
            } else if keyCode == 54 {
                // Right command key event
                if cmdFlagPresent && !wasRightPressed {
                    // Right key pressed
                    rightCmdPressed = true
                    print("Right CMD pressed")
                } else if !cmdFlagPresent {
                    // Right key released (cmd flag gone means ALL cmd keys released)
                    rightCmdPressed = false
                    print("Right CMD released")
                } else if wasRightPressed && cmdFlagPresent && wasLeftPressed {
                    // SPECIAL CASE: Right was pressed, cmd flag still present, left was also pressed
                    // This means right was just released but left is still held
                    rightCmdPressed = false
                    print("Right CMD released (left still held)")
                }
            }
            
            // Always update visual state when any cmd key changes
            cmdKeyStateChanged?(leftCmdPressed, rightCmdPressed)
            print("Key states - Left: \(leftCmdPressed), Right: \(rightCmdPressed)")
            
            // Check if both command keys are pressed
            if leftCmdPressed && rightCmdPressed {
                // Both keys are now pressed
                if bothKeysHeldStartTime == nil {
                    // Just started holding both keys
                    bothKeysHeldStartTime = Date()
                    print("Both Command keys pressed - hold for 3 seconds...")
                    
                    // Use repeating timer that checks every 0.1 seconds
                    holdTimer?.invalidate()
                    holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                        guard let self = self else {
                            timer.invalidate()
                            return
                        }
                        
                        // Check if EITHER key is no longer pressed (based on our tracked state)
                        if !self.leftCmdPressed || !self.rightCmdPressed {
                            print("One key released - cancelling timer")
                            timer.invalidate()
                            self.holdTimer = nil
                            self.bothKeysHeldStartTime = nil
                            return
                        }
                        
                        // Check if 3 seconds elapsed
                        if let startTime = self.bothKeysHeldStartTime,
                           Date().timeIntervalSince(startTime) >= 3.0 {
                            print("3 seconds elapsed - unlocking")
                            timer.invalidate()
                            self.holdTimer = nil
                            self.unlockHandler?()
                            self.bothKeysHeldStartTime = nil
                            
                            // Reset key states and update visuals
                            self.leftCmdPressed = false
                            self.rightCmdPressed = false
                            self.cmdKeyStateChanged?(false, false)
                        }
                    }
                }
            } else {
                // Not both keys pressed
                // Only cancel timer if BOTH keys are released (no cmd flag at all)
                if !cmdFlagPresent && bothKeysHeldStartTime != nil {
                    print("Both keys released - cancelling timer")
                    holdTimer?.invalidate()
                    holdTimer = nil
                    bothKeysHeldStartTime = nil
                    leftCmdPressed = false
                    rightCmdPressed = false
                    cmdKeyStateChanged?(false, false)
                }
            }
        }
        
        // Block all keyboard events when locked
        return nil
    }
    
    func cleanup() {
        // Invalidate timer
        holdTimer?.invalidate()
        
        // Disable event tap
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        
        // Remove run loop source
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        
        eventTap = nil
        runLoopSource = nil
    }
}
