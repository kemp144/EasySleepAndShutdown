import AppKit
import SwiftUI
import Combine

/// Sets up the NSStatusItem (menu bar icon) and the NSPopover that contains the SwiftUI UI.
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var timerManager: TimerManager!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - App lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Create the shared timer manager.
        timerManager = TimerManager()

        // 2. Create the status bar item (fixed width = icon + optional countdown text).
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        timerManager.setStatusItem(statusItem)

        // Configure the button shown in the menu bar.
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "powersleep", accessibilityDescription: "Easy Sleep & Shutdown")
            image?.isTemplate = true   // adapts to light/dark menu bar automatically
            button.image = image
            button.action = #selector(togglePopover)
            button.target = self
        }

        // 3. Create and configure the popover.
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 260)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: ContentView(timerManager: timerManager)
        )

        // Zatvori popover čim timer krene — app radi tiho u pozadini.
        timerManager.$isRunning
            .filter { $0 == true }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.popover.performClose(nil) }
            .store(in: &cancellables)
    }

    // MARK: - Popover toggle

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}
