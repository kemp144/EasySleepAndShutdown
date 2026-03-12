import AppKit
import Carbon
import Foundation
import IOKit
import IOKit.pwr_mgt

/// The action to perform when the timer fires.
enum SleepAction: String, CaseIterable, Identifiable {
    case sleep    = "sleep"
    case shutdown = "shutdown"
    var id: String { rawValue }
    var label: String {
        switch self {
        case .sleep:    return L.sleep
        case .shutdown: return L.shutdown
        }
    }
}

/// Manages the countdown timer and executes the chosen action.
final class TimerManager: ObservableObject {
    // MARK: - Published state

    @Published var isRunning: Bool = false
    @Published var isPreparingStart: Bool = false
    @Published var remainingSeconds: Int = 0
    @Published var selectedAction: SleepAction = .sleep
    @Published var selectedMinutes: Int = 15

    // MARK: - Private

    private var timer: Timer?
    private weak var statusItem: NSStatusItem?

    let timeOptions: [Int] = [5, 10, 15, 20, 30, 45, 60, 90, 120]
    // MARK: - Init

    init(statusItem: NSStatusItem? = nil) {
        self.statusItem = statusItem
    }

    func setStatusItem(_ item: NSStatusItem) {
        self.statusItem = item
    }

    // MARK: - Timer control

    func startFromUserIntent() {
        guard !isRunning, !isPreparingStart else {
            return
        }

        if selectedAction == .shutdown {
            isPreparingStart = true
            requestShutdownPermission { [weak self] granted in
                guard let self else { return }
                self.isPreparingStart = false

                guard granted else {
                    return
                }

                self.start()
            }
            return
        }

        start()
    }

    func start() {
        timer?.invalidate()
        timer = nil
        remainingSeconds = max(1, selectedMinutes) * 60
        isRunning = true
        updateMenuBarTitle()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = 0
        resetMenuBarTitle()
    }

    // MARK: - Private helpers

    private func tick() {
        guard remainingSeconds > 0 else {
            executeAction()
            return
        }

        remainingSeconds -= 1
        updateMenuBarTitle()
    }

    private func updateMenuBarTitle() {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        let emoji = selectedAction == .sleep ? "💤" : "⏼"
        let title = String(format: "%@ %02d:%02d", emoji, mins, secs)
        DispatchQueue.main.async { [weak self] in
            self?.statusItem?.button?.title = title
            self?.statusItem?.button?.image = nil
        }
    }

    private func resetMenuBarTitle() {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem?.button?.title = ""
            let img = NSImage(systemSymbolName: "powersleep", accessibilityDescription: L.menuBarAccessibilityDescription)
            img?.isTemplate = true
            self?.statusItem?.button?.image = img
        }
    }

    private func executeAction() {
        cancel()

        switch selectedAction {
        case .sleep:
            performSleep()
        case .shutdown:
            performShutdown()
        }
    }

    /// Sleep via IOKit — works even inside App Sandbox.
    private func performSleep() {
        let port = IOPMFindPowerManagement(mach_port_t(0))
        guard port != 0 else {
            showSleepUnavailableAlert()
            return
        }
        let result = IOPMSleepSystem(port)
        IOServiceClose(port)
        if result != kIOReturnSuccess {
            showSleepUnavailableAlert()
        }
    }

    /// Force shutdown by sending kAEShutDown Apple Event to loginwindow.
    /// Closes all apps without asking to save, then shuts down immediately.
    private func performShutdown() {
        // First, force-quit all user applications so nothing blocks shutdown
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            // Skip system processes and our own app
            guard app.activationPolicy == .regular,
                  app.bundleIdentifier != Bundle.main.bundleIdentifier else { continue }
            app.forceTerminate()
        }

        // Short delay to let apps terminate, then send shutdown event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.loginwindow")

            let event = NSAppleEventDescriptor.appleEvent(
                withEventClass: AEEventClass(kCoreEventClass),
                eventID: AEEventID(kAEShutDown),
                targetDescriptor: target,
                returnID: AEReturnID(kAutoGenerateReturnID),
                transactionID: AETransactionID(kAnyTransactionID)
            )

            var replyEvent = AppleEvent()
            let sendErr = AESendMessage(
                event.aeDesc!,
                &replyEvent,
                AESendMode(kAENoReply),
                kAEDefaultTimeout
            )
            AEDisposeDesc(&replyEvent)

            if sendErr != noErr {
                NSLog("AESendMessage shutdown failed: %d", sendErr)
                self?.showShutdownUnavailableAlert()
            } else {
                NSLog("Shutdown Apple Event sent successfully")
            }
        }
    }

    private func showAutomationPermissionDeniedAlert() {
        let alert = NSAlert()
        alert.messageText = L.automationDeniedTitle
        alert.informativeText = L.automationDeniedBody
        alert.alertStyle = .warning
        alert.addButton(withTitle: L.okButton)
        alert.runModal()
    }

    private func showSleepUnavailableAlert() {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = L.sleepUnavailableTitle
            alert.informativeText = L.sleepUnavailableBody
            alert.alertStyle = .warning
            alert.addButton(withTitle: L.okButton)
            alert.runModal()
        }
    }

    private func showShutdownUnavailableAlert() {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = L.shutdownUnavailableTitle
            alert.informativeText = L.shutdownUnavailableBody
            alert.alertStyle = .warning
            alert.addButton(withTitle: L.okButton)
            alert.runModal()
        }
    }

    private func requestShutdownPermission(completion: @escaping (Bool) -> Void) {
        let target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.loginwindow")

        guard let aeDesc = target.aeDesc else {
            DispatchQueue.main.async { [weak self] in
                self?.showShutdownUnavailableAlert()
                completion(false)
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let status = AEDeterminePermissionToAutomateTarget(
                aeDesc,
                AEEventClass(kCoreEventClass),
                AEEventID(kAEShutDown),
                true
            )

            DispatchQueue.main.async {
                switch status {
                case noErr:
                    completion(true)
                case OSStatus(errAEEventNotPermitted), OSStatus(errAEEventWouldRequireUserConsent):
                    self?.showAutomationPermissionDeniedAlert()
                    completion(false)
                default:
                    NSLog("Automation permission check failed: %d", status)
                    self?.showShutdownUnavailableAlert()
                    completion(false)
                }
            }
        }
    }
}
