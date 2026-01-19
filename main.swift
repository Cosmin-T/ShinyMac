import Cocoa

// Custom NSApplication subclass to handle emergency ESC key
class CleanupBuddyApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        // Emergency exit with ESC key (for testing/safety)
        if event.type == .keyDown && event.keyCode == 53 { // ESC key
            if let appDelegate = delegate as? AppDelegate {
                print("🛑 ESC pressed - Emergency unlock!")
                appDelegate.emergencyUnlock()
                return
            }
        }
        
        // Pass event to normal handling
        super.sendEvent(event)
    }
}

// Initialize our custom application
let app = CleanupBuddyApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
