import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var mainController: MainViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request accessibility permissions
        checkAccessibilityPermissions()
        
        // Create fullscreen black window
        createFullscreenWindow()
        
        // Create main controller
        mainController = MainViewController()
        mainController.appDelegate = self
        
        // Set window's content view
        window.contentView = mainController.view
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources
        mainController?.cleanup()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func createFullscreenWindow() {
        // Create NORMAL window (not fullscreen on launch)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.title = "ShinyMac"
        window.backgroundColor = .black
        window.isOpaque = true
        window.hasShadow = true
        
        // Make window float above other windows
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
    
    private func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "ShinyMac needs Accessibility permissions to lock your keyboard and trackpad.\n\nPlease grant permission in System Settings → Privacy & Security → Accessibility"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Quit")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            NSApp.terminate(nil)
        }
    }
    
    // Emergency unlock function
    func emergencyUnlock() {
        mainController?.emergencyUnlock()
    }
    
    // Set window level and fullscreen based on lock state
    func setWindowLevel(locked: Bool) {
        if locked {
            // When locked, go FULLSCREEN and stay on top
            // First set to borderless
            window.styleMask = [.borderless, .fullSizeContentView]
            window.level = .screenSaver
            
            // Then enter fullscreen
            if let screen = NSScreen.main {
                window.setFrame(screen.frame, display: true, animate: false)
            }
            
            // Make sure it's on top
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // When unlocked, return to normal window
            window.styleMask = [.titled, .closable, .miniaturizable]
            let normalFrame = NSRect(x: 0, y: 0, width: 800, height: 600)
            window.setFrame(normalFrame, display: true, animate: false)
            window.center()
            window.level = .floating
        }
    }
}
