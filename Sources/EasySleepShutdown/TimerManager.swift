import AppKit
import Foundation
import IOKit
import IOKit.pwr_mgt
import Security

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
    private enum DefaultsKey {
        static let automationPermissionConfirmed = "automationPermissionConfirmed"
    }

    // MARK: - Published state

    @Published var isRunning: Bool = false
    @Published var remainingSeconds: Int = 0
    @Published var selectedAction: SleepAction = .sleep
    @Published var selectedMinutes: Int = 15
    @Published var oneSecondTimer: Bool = false

    // MARK: - Private

    private var timer: Timer?
    private weak var statusItem: NSStatusItem?
    private var warningShown = false
    private var automationPermissionConfirmed = UserDefaults.standard.bool(
        forKey: DefaultsKey.automationPermissionConfirmed
    )
    private let isSandboxed = SandboxState.isEnabled

    let timeOptions: [Int] = [5, 10, 15, 20, 30, 45, 60, 90, 120]
    // MARK: - Init

    init(statusItem: NSStatusItem? = nil) {
        self.statusItem = statusItem
    }

    func setStatusItem(_ item: NSStatusItem) {
        self.statusItem = item
    }

    // MARK: - Timer control

    func start() {
        guard prepareAutomationPermissionIfNeeded(for: selectedAction) else {
            return
        }

        remainingSeconds = oneSecondTimer ? 1 : selectedMinutes * 60
        warningShown = false
        isRunning = true
        updateMenuBarTitle()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func preloadAutomationPermissionIfNeeded() {
        _ = prepareAutomationPermissionIfNeeded(for: selectedAction)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = 0
        warningShown = false
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

        if remainingSeconds == 60 && !warningShown {
            warningShown = true
            showWarningAlert()
        }
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
            let img = NSImage(systemSymbolName: "powersleep", accessibilityDescription: "Easy Sleep & Shutdown")
            img?.isTemplate = true
            self?.statusItem?.button?.image = img
        }
    }

    private func showWarningAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            NSApplication.shared.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = L.alertTitle
            alert.informativeText = L.alertBody(self.selectedAction)
            alert.alertStyle = .warning
            alert.addButton(withTitle: L.alertButton_ok)
            alert.addButton(withTitle: L.alertButton_cancel)
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                self.cancel()
            }
        }
    }

    private func prepareAutomationPermissionIfNeeded(for action: SleepAction) -> Bool {
        guard action == .sleep else {
            return true
        }

        guard !isSandboxed else {
            return true
        }

        if automationPermissionConfirmed {
            return true
        }

        if Thread.isMainThread {
            return requestAutomationPermission()
        }

        var granted = false
        DispatchQueue.main.sync {
            granted = requestAutomationPermission()
        }
        return granted
    }

    private func requestAutomationPermission() -> Bool {
        NSApplication.shared.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = L.automationSetupTitle
        alert.informativeText = L.automationSetupBody
        alert.alertStyle = .informational
        alert.addButton(withTitle: L.continueText)
        alert.addButton(withTitle: L.cancel)

        guard alert.runModal() == .alertFirstButtonReturn else {
            return false
        }

        var errorInfo: NSDictionary?
        let script = NSAppleScript(source: "tell application \"System Events\" to activate")
        script?.executeAndReturnError(&errorInfo)

        if errorInfo == nil {
            automationPermissionConfirmed = true
            UserDefaults.standard.set(true, forKey: DefaultsKey.automationPermissionConfirmed)
            return true
        }

        showAutomationPermissionDeniedAlert()
        return false
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
            showSandboxFallbackAlert()
            return
        }
        let result = IOPMSleepSystem(port)
        IOServiceClose(port)
        if result != kIOReturnSuccess {
            // IOKit failed — fall back to AppleScript (non-sandbox) or alert
            if !isSandboxed {
                runAppleScript("tell application \"System Events\" to sleep")
            } else {
                showSandboxFallbackAlert()
            }
        }
    }

    /// Shutdown sends the Apple Event directly to loginwindow.
    /// macOS will show a confirmation dialog before proceeding.
    private func performShutdown() {
        let sent = runAppleScript(
            "tell application \"System Events\" to shut down"
        )
        if !sent {
            showShutdownUnavailableAlert()
        }
    }

    private func showAutomationPermissionDeniedAlert() {
        let alert = NSAlert()
        alert.messageText = L.automationDeniedTitle
        alert.informativeText = L.automationDeniedBody
        alert.alertStyle = .warning
        alert.addButton(withTitle: L.alertButton_ok)
        alert.runModal()
    }

    private func showSandboxFallbackAlert() {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = L.sandboxAlertTitle
            alert.informativeText = L.sandboxAlertBody
            alert.alertStyle = .informational
            alert.addButton(withTitle: L.alertButton_ok)
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
            alert.addButton(withTitle: L.alertButton_ok)
            alert.runModal()
        }
    }

    @discardableResult
    private func runAppleScript(_ source: String) -> Bool {
        var success = false
        let work = {
            var errorInfo: NSDictionary?
            let script = NSAppleScript(source: source)
            script?.executeAndReturnError(&errorInfo)
            success = (errorInfo == nil)
        }
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync { work() }
        }
        return success
    }
}

private enum SandboxState {
    static var isEnabled: Bool {
        guard let task = SecTaskCreateFromSelf(nil) else {
            return false
        }

        let entitlement = SecTaskCopyValueForEntitlement(
            task,
            "com.apple.security.app-sandbox" as CFString,
            nil
        )

        return entitlement as? Bool == true
    }
}
