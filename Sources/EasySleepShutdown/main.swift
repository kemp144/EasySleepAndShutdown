import AppKit

// Hide from the Dock programmatically (equivalent to LSUIElement = true in Info.plist).
// This works for both `swift run` and the final .app bundle.
NSApplication.shared.setActivationPolicy(.accessory)

// Set up the delegate and run the event loop.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
