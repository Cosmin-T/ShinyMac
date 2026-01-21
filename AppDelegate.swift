import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var mainController: MainViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if app is quarantined or in a problematic location
        if isAppInProblematicLocation() {
            showInstallationDialog()
            return
        }
        
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
    
    private func isAppInProblematicLocation() -> Bool {
        let bundlePath = Bundle.main.bundlePath
        
        // Check if running from DMG or quarantined location
        if bundlePath.contains("/Volumes/") || 
           bundlePath.contains("/AppTranslocation/") ||
           bundlePath.contains(".dmg") {
            return true
        }
        
        // Check for quarantine attribute using xattr
        let task = Process()
        task.launchPath = "/usr/bin/xattr"
        task.arguments = ["-p", "com.apple.quarantine", bundlePath]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // If exit code is 0, quarantine attribute exists
            if task.terminationStatus == 0 {
                return true
            }
        } catch {
            // If we can't check, assume it's okay
        }
        
        return false
    }
    
    private func showInstallationDialog() {
        let alert = NSAlert()
        alert.messageText = "Please Install ShinyMac"
        alert.informativeText = """
        ShinyMac needs to be installed in your Applications folder to work properly.
        
        Please:
        1. Drag ShinyMac to your Applications folder
        2. Launch it from there
        
        (Running from a disk image or Downloads folder may cause issues)
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Applications Folder")
        alert.addButton(withTitle: "Continue Anyway")
        alert.addButton(withTitle: "Quit")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open Applications folder
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/Applications")
            NSApp.terminate(nil)
        } else if response == .alertSecondButtonReturn {
            // User wants to continue anyway - let them
            return
        } else {
            NSApp.terminate(nil)
        }
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
