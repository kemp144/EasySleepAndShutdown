import AppKit
import Foundation

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

/// Manages the countdown timer and executes the chosen action via NSAppleScript.
/// NSAppleScript is App Sandbox compatible with the apple-events temporary exception entitlement.
final class TimerManager: ObservableObject {

    // MARK: - Published state

    @Published var isRunning: Bool = false
    @Published var remainingSeconds: Int = 0
    @Published var selectedAction: SleepAction = .sleep
    @Published var selectedMinutes: Int = 15

    // MARK: - Private

    private var timer: Timer?
    private weak var statusItem: NSStatusItem?
    private var warningShown = false

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
        remainingSeconds = selectedMinutes * 60
        warningShown = false
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

    /// Izvršava akciju putem NSAppleScript.
    /// NSAppleScript je App Sandbox kompatibilan uz 'apple-events' temporary exception entitlement.
    /// Process() / osascript su zabranjeni pod App Sandbox i nisu dozvoljeni na Mac App Store-u.
    private func executeAction() {
        cancel()

        let source: String
        switch selectedAction {
        case .sleep:
            source = "tell application \"System Events\" to sleep"
        case .shutdown:
            source = "tell application \"System Events\" to shut down"
        }

        // NSAppleScript mora da se izvršava na main threadu.
        // Blokiranje je prihvatljivo jer sistem odmah prelazi u sleep/shutdown.
        DispatchQueue.main.async {
            var errorInfo: NSDictionary?
            let script = NSAppleScript(source: source)
            script?.executeAndReturnError(&errorInfo)
        }
    }
}
