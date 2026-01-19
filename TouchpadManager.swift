import Cocoa
import Carbon
import IOKit.hid

class TouchpadManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var hidManager: IOHIDManager?
    private var gestureMonitor: Any?
    private var positionResetTimer: Timer?
    
    private(set) var isLocked = false
    private var lastMousePosition: CGPoint = .zero
    
    func setupEventTap() {
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        // Create comprehensive event mask for all mouse/trackpad events
        // Split into parts to avoid compiler timeout
        let movementMask: CGEventMask = (1 << CGEventType.mouseMoved.rawValue) |
                                        (1 << CGEventType.leftMouseDragged.rawValue) |
                                        (1 << CGEventType.rightMouseDragged.rawValue) |
                                        (1 << CGEventType.otherMouseDragged.rawValue)
        
        let clickMask: CGEventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                                     (1 << CGEventType.leftMouseUp.rawValue) |
                                     (1 << CGEventType.rightMouseDown.rawValue) |
                                     (1 << CGEventType.rightMouseUp.rawValue) |
                                     (1 << CGEventType.otherMouseDown.rawValue) |
                                     (1 << CGEventType.otherMouseUp.rawValue)
        
        let scrollMask: CGEventMask = (1 << CGEventType.scrollWheel.rawValue)
        
        let mouseMask = movementMask | clickMask | scrollMask
        
        // Create event tap
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mouseMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }
                
                let manager = Unmanaged<TouchpadManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleMouseEvent(event: event)
            },
            userInfo: selfPointer
        )
        
        guard let tap = eventTap else {
            print("Failed to create touchpad event tap")
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
            }
            
            // Setup HID-level blocking
            setupHIDBlocking()
            
            // Setup gesture blocking
            setupGestureBlocking()
            
            // Start position reset timer
            startPositionResetTimer()
            
            print("Trackpad locked")
        } else {
            // Disable event tap
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: false)
            }
            
            // Cleanup HID blocking
            cleanupHIDBlocking()
            
            // Cleanup gesture blocking
            cleanupGestureBlocking()
            
            // Stop position reset timer
            stopPositionResetTimer()
            
            print("Trackpad unlocked")
        }
    }
    
    private func handleMouseEvent(event: CGEvent) -> Unmanaged<CGEvent>? {
        // If not locked, pass through
        guard isLocked else {
            return Unmanaged.passRetained(event)
        }
        
        // Block all mouse/trackpad events when locked
        return nil
    }
    
    // MARK: - HID-level blocking
    
    private func setupHIDBlocking() {
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        
        guard let manager = hidManager else { return }
        
        // Match touchpad devices
        let matchingDict: [String: Any] = [
            kIOHIDDeviceUsagePageKey as String: kHIDPage_Digitizer,
            kIOHIDDeviceUsageKey as String: kHIDUsage_Dig_TouchPad
        ]
        
        IOHIDManagerSetDeviceMatching(manager, matchingDict as CFDictionary)
        
        // Register callback to block events
        IOHIDManagerRegisterInputValueCallback(manager, { _, _, _, _ in
            // Block all touchpad events
        }, nil)
        
        // Schedule and open with seize option
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeSeizeDevice))
    }
    
    private func cleanupHIDBlocking() {
        guard let manager = hidManager else { return }
        
        IOHIDManagerRegisterInputValueCallback(manager, nil, nil)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        
        hidManager = nil
    }
    
    // MARK: - Gesture blocking
    
    private func setupGestureBlocking() {
        let gestureMask: NSEvent.EventTypeMask = [
            .gesture, .magnify, .swipe, .rotate,
            .beginGesture, .endGesture, .smartMagnify,
            .pressure, .directTouch
        ]
        
        gestureMonitor = NSEvent.addGlobalMonitorForEvents(matching: gestureMask) { _ in
            // Block all gesture events
        }
    }
    
    private func cleanupGestureBlocking() {
        if let monitor = gestureMonitor {
            NSEvent.removeMonitor(monitor)
            gestureMonitor = nil
        }
    }
    
    // MARK: - Position reset timer
    
    private func startPositionResetTimer() {
        lastMousePosition = NSEvent.mouseLocation
        
        positionResetTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, self.isLocked else { return }
            
            // Force cursor to stay in place
            let currentPos = NSEvent.mouseLocation
            if currentPos != self.lastMousePosition {
                CGWarpMouseCursorPosition(self.lastMousePosition)
            }
        }
        
        RunLoop.current.add(positionResetTimer!, forMode: .common)
    }
    
    private func stopPositionResetTimer() {
        positionResetTimer?.invalidate()
        positionResetTimer = nil
    }
    
    func cleanup() {
        // Disable event tap
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        
        // Remove run loop source
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        
        // Cleanup HID and gestures
        cleanupHIDBlocking()
        cleanupGestureBlocking()
        stopPositionResetTimer()
        
        eventTap = nil
        runLoopSource = nil
    }
}
