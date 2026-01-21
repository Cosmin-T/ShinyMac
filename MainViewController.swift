import Cocoa

// Custom button with visual press feedback
class PressableButton: NSButton {
    private var normalColor: NSColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private var pressedColor: NSColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    
    override func mouseDown(with event: NSEvent) {
        // Visual feedback on press
        self.layer?.backgroundColor = pressedColor.cgColor
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        // Restore normal color
        self.layer?.backgroundColor = normalColor.cgColor
        super.mouseUp(with: event)
    }
    
    func setNormalColor(_ color: NSColor) {
        normalColor = color
        self.layer?.backgroundColor = color.cgColor
    }
    
    func setPressedColor(_ color: NSColor) {
        pressedColor = color
    }
}

class MainViewController: NSViewController {
    weak var appDelegate: AppDelegate?
    
    private let lockManager = LockManager()
    private let touchpadManager = TouchpadManager()
    
    private var startButton: PressableButton!
    private var statusLabel: NSTextField!
    private var statusIndicator: NSView!  // Visual status indicator (circle)
    private var instructionLabel: NSTextField!
    private var countdownLabel: NSTextField!
    
    // CMD key visual indicators
    private var leftCmdKey: NSView!
    private var rightCmdKey: NSView!
    private var leftCmdLabel: NSTextField!
    private var rightCmdLabel: NSTextField!
    
    private var countdownTimer: Timer?
    private var countdown = 3
    private var safetyTimer: Timer?
    
    // Hold countdown timer (shows while holding CMD keys)
    private var holdCountdownTimer: Timer?
    private var holdCountdown = 3
    
    private var isLocked = false
    
    override func loadView() {
        // Create main view with black background (normal size initially)
        view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        setupUI()
        setupManagers()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        // Reposition UI when view resizes (for fullscreen transition)
        repositionUI()
    }
    
    private func repositionUI() {
        let viewFrame = view.frame
        let centerX = viewFrame.width / 2
        let centerY = viewFrame.height / 2
        
        // Reposition all elements to stay centered
        statusLabel.frame = NSRect(x: centerX - 300, y: centerY + 150, width: 600, height: 60)
        
        let indicatorSize: CGFloat = 16
        statusIndicator.frame = NSRect(x: centerX + 150, y: centerY + 175, width: indicatorSize, height: indicatorSize)
        
        instructionLabel.frame = NSRect(x: centerX - 400, y: centerY + 50, width: 800, height: 80)
        startButton.frame = NSRect(x: centerX - 120, y: centerY - 30, width: 240, height: 60)
        countdownLabel.frame = NSRect(x: centerX - 200, y: centerY - 120, width: 400, height: 60)
        
        // CMD keys at bottom
        let keyY: CGFloat = 100
        let keyWidth: CGFloat = 120
        let keyHeight: CGFloat = 60
        let keySpacing: CGFloat = 60
        
        leftCmdKey.frame = NSRect(x: centerX - keyWidth - keySpacing/2, y: keyY, width: keyWidth, height: keyHeight)
        rightCmdKey.frame = NSRect(x: centerX + keySpacing/2, y: keyY, width: keyWidth, height: keyHeight)
    }
    
    private func setupUI() {
        // Use view frame instead of screen frame
        let viewFrame = view.frame
        
        // Calculate center position
        let centerX = viewFrame.width / 2
        let centerY = viewFrame.height / 2
        
        // Status label (top)
        statusLabel = NSTextField(frame: NSRect(x: centerX - 300, y: centerY + 150, width: 600, height: 60))
        statusLabel.stringValue = "ShinyMac"
        statusLabel.font = NSFont.systemFont(ofSize: 48, weight: .bold)
        statusLabel.textColor = .white
        statusLabel.alignment = .center
        statusLabel.isBezeled = false
        statusLabel.isEditable = false
        statusLabel.backgroundColor = .clear
        view.addSubview(statusLabel)
        
        // Status indicator (circle) - positioned next to title
        let indicatorSize: CGFloat = 16
        statusIndicator = NSView(frame: NSRect(x: centerX + 150, y: centerY + 175, width: indicatorSize, height: indicatorSize))
        statusIndicator.wantsLayer = true
        statusIndicator.layer?.backgroundColor = NSColor(white: 0.4, alpha: 0.6).cgColor  // Gray when inactive
        statusIndicator.layer?.cornerRadius = indicatorSize / 2  // Make it circular
        view.addSubview(statusIndicator)
        
        // Instruction label
        instructionLabel = NSTextField(frame: NSRect(x: centerX - 400, y: centerY + 50, width: 800, height: 80))
        instructionLabel.stringValue = "Click START to lock keyboard and trackpad\nHold both Command keys for 3 seconds to unlock"
        instructionLabel.font = NSFont.systemFont(ofSize: 18, weight: .regular)
        instructionLabel.textColor = NSColor(white: 0.7, alpha: 1.0)
        instructionLabel.alignment = .center
        instructionLabel.isBezeled = false
        instructionLabel.isEditable = false
        instructionLabel.backgroundColor = .clear
        view.addSubview(instructionLabel)
        
        // Start/Unlock button - Semi-transparent, no border
        startButton = PressableButton(frame: NSRect(x: centerX - 120, y: centerY - 30, width: 240, height: 60))
        startButton.title = "START"
        startButton.font = NSFont.systemFont(ofSize: 24, weight: .medium)
        startButton.isBordered = false
        startButton.bezelStyle = .regularSquare  // Remove default bezel
        startButton.target = self
        startButton.action = #selector(startButtonClicked)
        
        // Semi-transparent flat style - NO BORDER
        startButton.wantsLayer = true
        startButton.layer?.masksToBounds = true
        startButton.setNormalColor(NSColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 0.4))  // Semi-transparent
        startButton.setPressedColor(NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 0.6))
        startButton.layer?.cornerRadius = 8
        startButton.layer?.borderWidth = 0  // NO BORDER
        
        view.addSubview(startButton)
        
        // CMD Key indicators - Positioned at bottom of screen
        let keyY: CGFloat = 100  // Bottom of screen
        let keyWidth: CGFloat = 120
        let keyHeight: CGFloat = 60
        let keySpacing: CGFloat = 60
        
        // Left CMD key
        leftCmdKey = NSView(frame: NSRect(x: centerX - keyWidth - keySpacing/2, y: keyY, width: keyWidth, height: keyHeight))
        leftCmdKey.wantsLayer = true
        leftCmdKey.layer?.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.5).cgColor
        leftCmdKey.layer?.cornerRadius = 6
        leftCmdKey.layer?.borderWidth = 0
        leftCmdKey.isHidden = true
        view.addSubview(leftCmdKey)
        
        leftCmdLabel = NSTextField(frame: NSRect(x: 0, y: (keyHeight - 20) / 2, width: keyWidth, height: 20))
        leftCmdLabel.stringValue = "⌘ Left"
        leftCmdLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        leftCmdLabel.textColor = NSColor(white: 0.7, alpha: 1.0)
        leftCmdLabel.alignment = .center
        leftCmdLabel.isBezeled = false
        leftCmdLabel.isEditable = false
        leftCmdLabel.backgroundColor = .clear
        leftCmdKey.addSubview(leftCmdLabel)
        
        // Right CMD key
        rightCmdKey = NSView(frame: NSRect(x: centerX + keySpacing/2, y: keyY, width: keyWidth, height: keyHeight))
        rightCmdKey.wantsLayer = true
        rightCmdKey.layer?.backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.5).cgColor
        rightCmdKey.layer?.cornerRadius = 6
        rightCmdKey.layer?.borderWidth = 0
        rightCmdKey.isHidden = true
        view.addSubview(rightCmdKey)
        
        rightCmdLabel = NSTextField(frame: NSRect(x: 0, y: (keyHeight - 20) / 2, width: keyWidth, height: 20))
        rightCmdLabel.stringValue = "⌘ Right"
        rightCmdLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        rightCmdLabel.textColor = NSColor(white: 0.7, alpha: 1.0)
        rightCmdLabel.alignment = .center
        rightCmdLabel.isBezeled = false
        rightCmdLabel.isEditable = false
        rightCmdLabel.backgroundColor = .clear
        rightCmdKey.addSubview(rightCmdLabel)
        
        // Countdown label (hidden initially) - Positioned BELOW button
        countdownLabel = NSTextField(frame: NSRect(x: centerX - 200, y: centerY - 120, width: 400, height: 60))
        countdownLabel.stringValue = ""
        countdownLabel.font = NSFont.systemFont(ofSize: 48, weight: .bold)
        countdownLabel.textColor = NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange
        countdownLabel.alignment = .center
        countdownLabel.isBezeled = false
        countdownLabel.isEditable = false
        countdownLabel.backgroundColor = .clear
        countdownLabel.isHidden = true
        view.addSubview(countdownLabel)
        
        // ESC hint label removed - no emergency unlock needed
    }
    
    private func setupManagers() {
        // Setup event taps
        lockManager.setupEventTap()
        touchpadManager.setupEventTap()
        
        // Set unlock handler - unlock immediately after 3-second hold
        lockManager.unlockHandler = { [weak self] in
            self?.unlockEverything()
        }
        
        // Set CMD key highlight handlers
        lockManager.cmdKeyStateChanged = { [weak self] leftPressed, rightPressed in
            self?.updateCmdKeyVisuals(leftPressed: leftPressed, rightPressed: rightPressed)
        }
    }
    
    private func updateCmdKeyVisuals(leftPressed: Bool, rightPressed: Bool) {
        let orangeColor = NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
        let normalColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.5)
        
        // Update left CMD key
        leftCmdKey.layer?.backgroundColor = (leftPressed ? orangeColor : normalColor).cgColor
        leftCmdLabel.textColor = leftPressed ? .white : NSColor(white: 0.7, alpha: 1.0)
        
        // Update right CMD key
        rightCmdKey.layer?.backgroundColor = (rightPressed ? orangeColor : normalColor).cgColor
        rightCmdLabel.textColor = rightPressed ? .white : NSColor(white: 0.7, alpha: 1.0)
        
        // Start/stop hold countdown timer
        if leftPressed && rightPressed {
            startHoldCountdown()
        } else {
            stopHoldCountdown()
        }
    }
    
    private func startHoldCountdown() {
        // Only start if not already running
        if holdCountdownTimer != nil {
            return
        }
        
        // Show countdown while holding both keys
        holdCountdown = 3
        countdownLabel.stringValue = "\(holdCountdown)"
        countdownLabel.isHidden = false
        
        holdCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.holdCountdown -= 1
            
            if self.holdCountdown > 0 {
                self.countdownLabel.stringValue = "\(self.holdCountdown)"
            } else {
                timer.invalidate()
                self.holdCountdownTimer = nil
                // Timer will be hidden when unlock happens
            }
        }
    }
    
    private func stopHoldCountdown() {
        holdCountdownTimer?.invalidate()
        holdCountdownTimer = nil
        countdownLabel.isHidden = true
        holdCountdown = 3  // Reset countdown
    }
    
    @objc private func startButtonClicked() {
        if isLocked {
            // Already locked, start unlock countdown
            startUnlockCountdown()
        } else {
            // Lock everything
            lockEverything()
        }
    }
    
    private func lockEverything() {
        isLocked = true
        
        // Lock keyboard and trackpad
        lockManager.lock(true)
        touchpadManager.lock(true)
        
        // Set window to stay on top
        appDelegate?.setWindowLevel(locked: true)
        
        // Update UI - Keep same style, just change text
        startButton.title = "LOCKED"
        // Keep same color as START button
        
        // HIDE title when locked, but KEEP indicator visible and turn it ORANGE
        statusLabel.isHidden = true
        statusIndicator.isHidden = false
        statusIndicator.layer?.backgroundColor = NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.9).cgColor
        
        instructionLabel.stringValue = "Hold both Command keys for 3 seconds to unlock"
        
        // Show CMD key indicators
        leftCmdKey.isHidden = false
        rightCmdKey.isHidden = false
        
        // Start safety timer (auto-unlock after 8 minutes)
        safetyTimer = Timer.scheduledTimer(withTimeInterval: 480.0, repeats: false) { [weak self] _ in
            print("⚠️ Safety timeout - auto-unlocking!")
            self?.unlockEverything()
        }
        
        print("Everything locked!")
    }
    
    private func startUnlockCountdown() {
        // Cancel any existing countdown
        countdownTimer?.invalidate()
        
        countdown = 3
        countdownLabel.stringValue = "\(countdown)"
        countdownLabel.isHidden = false
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.countdown -= 1
            
            if self.countdown > 0 {
                self.countdownLabel.stringValue = "\(self.countdown)"
            } else {
                timer.invalidate()
                self.countdownLabel.isHidden = true
                self.unlockEverything()
            }
        }
    }
    
    private func unlockEverything() {
        isLocked = false
        
        // Cancel timers
        countdownTimer?.invalidate()
        safetyTimer?.invalidate()
        
        // Unlock keyboard and trackpad
        lockManager.lock(false)
        touchpadManager.lock(false)
        
        // Reset window level to normal floating
        appDelegate?.setWindowLevel(locked: false)
        
        // Update UI
        startButton.title = "START"
        
        // SHOW title and indicator when unlocked
        statusLabel.isHidden = false
        statusIndicator.isHidden = false
        statusIndicator.layer?.backgroundColor = NSColor(white: 0.4, alpha: 0.6).cgColor
        
        instructionLabel.stringValue = "Click START to lock keyboard and trackpad\nHold both Command keys for 3 seconds to unlock"
        
        countdownLabel.isHidden = true
        
        // Hide CMD key indicators
        leftCmdKey.isHidden = true
        rightCmdKey.isHidden = true
        
        print("Everything unlocked!")
    }
    
    func emergencyUnlock() {
        if isLocked {
            print("Emergency unlock triggered!")
            unlockEverything()
        }
    }
    
    func cleanup() {
        // Cancel timers
        countdownTimer?.invalidate()
        safetyTimer?.invalidate()
        holdCountdownTimer?.invalidate()
        
        // Cleanup managers
        lockManager.cleanup()
        touchpadManager.cleanup()
    }
}
