import AppKit
import SwiftUI
import Combine

/// Sets up the status item and a regular app window for the SwiftUI UI.
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    private var statusItem: NSStatusItem!
    private var window: NSWindow!
    private var timerManager: TimerManager!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - App lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        timerManager = TimerManager()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        timerManager.setStatusItem(statusItem)

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "powersleep", accessibilityDescription: "Easy Sleep & Shutdown")
            image?.isTemplate = true
            button.image = image
            button.action = #selector(toggleWindow)
            button.target = self
        }

        let hostingController = NSHostingController(
            rootView: ContentView(timerManager: timerManager)
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 450),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Easy Sleep & Shutdown"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.delegate = self
        self.window = window
        window.center()

        timerManager.$isRunning
            .filter { $0 == true }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.closeWindow()
            }
            .store(in: &cancellables)
    }

    // MARK: - Window control

    @objc private func toggleWindow() {
        if window.isVisible {
            closeWindow()
        } else {
            openWindow()
        }
    }

    private func openWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.window.makeKeyAndOrderFront(nil)
        }
    }

    private func closeWindow() {
        window.orderOut(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        closeWindow()
        return false
    }

    @objc func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        false
    }
}
