import AppKit

// Run as a regular app so the main window opens normally on launch.
NSApplication.shared.setActivationPolicy(.regular)

// Set up the delegate and run the event loop.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
