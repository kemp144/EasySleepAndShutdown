import AppKit
import Carbon
import Foundation
import OSAKit

/// The action to perform when the timer fires.
enum SystemAction: String, CaseIterable, Identifiable {
    case sleep    = "sleep"
    case shutdown = "shutdown"
    var id: String { rawValue }

    var label: String {
        switch self {
        case .sleep:    return L.sleep
        case .shutdown: return L.shutdown
        }
    }

    var scriptHandlerName: String {
        switch self {
        case .sleep:    return "sleepSystem"
        case .shutdown: return "shutdownSystem"
        }
    }
}

enum ScriptManagerError: LocalizedError {
    case scriptsFolderUnavailable
    case scriptMissing
    case templateUnavailable
    case applescriptLanguageUnavailable
    case scriptInstallFailed(details: String)
    case scriptCompilationFailed(details: String)
    case scriptExportFailed(details: String)
    case scriptInitializationFailed(details: String)
    case scriptExecutionFailed(details: String)

    var errorDescription: String? {
        switch self {
        case .scriptsFolderUnavailable:
            return L.scriptsFolderUnavailableTitle
        case .scriptMissing:
            return L.setupRequiredTitle
        case .templateUnavailable:
            return L.sampleTemplateUnavailableTitle
        case .applescriptLanguageUnavailable:
            return L.sampleTemplateUnavailableTitle
        case .scriptInstallFailed:
            return L.exportFailedTitle
        case .scriptCompilationFailed:
            return L.scriptInvalidTitle
        case .scriptExportFailed:
            return L.exportFailedTitle
        case .scriptInitializationFailed:
            return L.scriptInvalidTitle
        case .scriptExecutionFailed:
            return L.actionUnavailableTitle
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .scriptsFolderUnavailable:
            return L.scriptsFolderUnavailableBody
        case .scriptMissing:
            return L.setupRequiredBody
        case .templateUnavailable:
            return L.sampleTemplateUnavailableBody
        case .applescriptLanguageUnavailable:
            return L.sampleTemplateUnavailableBody
        case .scriptInstallFailed:
            return L.scriptInstallFailedBody
        case .scriptCompilationFailed:
            return L.scriptInvalidBody
        case .scriptExportFailed:
            return L.exportFailedBody
        case .scriptInitializationFailed:
            return L.scriptInvalidBody
        case .scriptExecutionFailed:
            return L.actionUnavailableBody
        }
    }

    var debugDetails: String? {
        switch self {
        case let .scriptInstallFailed(details),
             let .scriptCompilationFailed(details),
             let .scriptExportFailed(details),
             let .scriptInitializationFailed(details),
             let .scriptExecutionFailed(details):
            return details
        case .scriptsFolderUnavailable,
             .scriptMissing,
             .templateUnavailable,
             .applescriptLanguageUnavailable:
            return nil
        }
    }
}

@MainActor
final class ScriptManager: ObservableObject {
    static let scriptFileName = "SystemActions.scpt"
    private static let bundledCompiledScriptExtension = "scpt"
    private static let bundledTemplateName = "SystemActions"
    private static let bundledTemplateExtension = "applescript"

    @Published private(set) var isInstalled: Bool = false
    @Published private(set) var scriptsFolderURL: URL?
    @Published private(set) var lastExportedScriptURL: URL?
    @Published private(set) var lastSetupMessage: String?
    @Published private(set) var lastError: ScriptManagerError?

    init() {
        refreshInstallationStatus()
    }

    func isScriptInstalled() -> Bool {
        do {
            let url = try installedScriptURL()
            let exists = FileManager.default.fileExists(atPath: url.path)
            isInstalled = exists
            lastError = nil
            return exists
        } catch let error as ScriptManagerError {
            isInstalled = false
            lastError = error
            return false
        } catch {
            isInstalled = false
            lastError = .scriptsFolderUnavailable
            return false
        }
    }

    func refreshInstallationStatus() {
        _ = isScriptInstalled()
    }

    func checkInstallationStatus() {
        if isScriptInstalled() {
            presentMessage(L.scriptDetectedMessage)
        } else {
            present(error: .scriptMissing)
        }
    }

    func openScriptsFolder() throws {
        let folderURL = try applicationScriptsDirectory()
        scriptsFolderURL = folderURL
        clearFeedback()

        if FileManager.default.fileExists(atPath: folderURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([folderURL])
        } else {
            NSWorkspace.shared.activateFileViewerSelecting([folderURL.deletingLastPathComponent()])
            presentMessage(L.scriptsFolderParentOpened)
        }
    }

    func exportBundledScript() throws -> URL? {
        let scriptsFolderURL = try applicationScriptsDirectory()
        let installedURL = try installedScriptURL()
        let fileManager = FileManager.default

        do {
            try fileManager.createDirectory(at: scriptsFolderURL, withIntermediateDirectories: true)
        } catch {
            throw ScriptManagerError.scriptExportFailed(details: error.localizedDescription)
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = Self.scriptFileName
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.directoryURL = scriptsFolderURL
        panel.prompt = L.saveScript
        panel.title = L.chooseSaveLocationTitle
        panel.message = L.chooseSaveLocationBody
        panel.showsTagField = false

        guard panel.runModal() == .OK, let destinationURL = panel.url else {
            return nil
        }

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
        } catch {
            throw ScriptManagerError.scriptExportFailed(details: error.localizedDescription)
        }

        do {
            if let bundledScriptURL = Bundle.main.url(forResource: Self.bundledTemplateName, withExtension: Self.bundledCompiledScriptExtension) {
                try fileManager.copyItem(at: bundledScriptURL, to: destinationURL)
            } else {
                let template = try loadTemplateSource()
                try compileTemplate(template, to: destinationURL)
            }
        } catch let error as ScriptManagerError {
            throw error
        } catch {
            throw ScriptManagerError.scriptExportFailed(details: error.localizedDescription)
        }

        do {
            if destinationURL.standardizedFileURL != installedURL.standardizedFileURL {
                if fileManager.fileExists(atPath: installedURL.path) {
                    try fileManager.removeItem(at: installedURL)
                }
                try fileManager.copyItem(at: destinationURL, to: installedURL)
            }
        } catch {
            throw ScriptManagerError.scriptInstallFailed(details: error.localizedDescription)
        }

        NSWorkspace.shared.activateFileViewerSelecting([destinationURL])

        lastExportedScriptURL = destinationURL
        refreshInstallationStatus()
        return destinationURL
    }

    func revealExportedScript() {
        guard let lastExportedScriptURL else {
            return
        }

        NSWorkspace.shared.activateFileViewerSelecting([lastExportedScriptURL])
    }

    func revealSetupLocations() {
        if let lastExportedScriptURL {
            NSWorkspace.shared.activateFileViewerSelecting([lastExportedScriptURL])
        }

        do {
            let folderURL = try applicationScriptsDirectory()
            if FileManager.default.fileExists(atPath: folderURL.path) {
                NSWorkspace.shared.activateFileViewerSelecting([folderURL])
            } else {
                NSWorkspace.shared.activateFileViewerSelecting([folderURL.deletingLastPathComponent()])
            }
        } catch {
            return
        }
    }

    func executeAction(_ action: SystemAction) async throws {
        let scriptURL = try installedScriptURL()
        guard FileManager.default.fileExists(atPath: scriptURL.path) else {
            isInstalled = false
            throw ScriptManagerError.scriptMissing
        }

        let task: NSUserAppleScriptTask
        do {
            task = try NSUserAppleScriptTask(url: scriptURL)
        } catch {
            throw ScriptManagerError.scriptInitializationFailed(details: error.localizedDescription)
        }

        let event = makeSubroutineEvent(handlerName: action.scriptHandlerName)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            task.execute(withAppleEvent: event) { _, error in
                if let error {
                    continuation.resume(throwing: ScriptManagerError.scriptExecutionFailed(details: error.localizedDescription))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func present(error: ScriptManagerError) {
        lastError = error
        lastSetupMessage = nil
    }

    func presentMessage(_ message: String) {
        lastSetupMessage = message
        lastError = nil
    }

    func clearFeedback() {
        lastSetupMessage = nil
        lastError = nil
    }

    private func applicationScriptsDirectory() throws -> URL {
        guard let folderURL = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask).first else {
            throw ScriptManagerError.scriptsFolderUnavailable
        }

        scriptsFolderURL = folderURL
        return folderURL
    }

    private func installedScriptURL() throws -> URL {
        try applicationScriptsDirectory().appendingPathComponent(Self.scriptFileName)
    }

    // The app exports a sample script and nudges saving directly into the Application Scripts
    // folder so setup completes in one step.
    private func loadTemplateSource() throws -> String {
        if let url = Bundle.main.url(forResource: Self.bundledTemplateName, withExtension: Self.bundledTemplateExtension),
           let source = try? String(contentsOf: url, encoding: .utf8),
           !source.isEmpty {
            return source
        }

        if !Self.fallbackTemplateSource.isEmpty {
            return Self.fallbackTemplateSource
        }

        throw ScriptManagerError.templateUnavailable
    }

    private func compileTemplate(_ source: String, to destinationURL: URL) throws {
        guard let language = OSALanguage(forName: "AppleScript") else {
            throw ScriptManagerError.applescriptLanguageUnavailable
        }

        let script = OSAScript(source: source, language: language)
        var compileError: NSDictionary?
        guard script.compileAndReturnError(&compileError) else {
            throw ScriptManagerError.scriptCompilationFailed(details: compileError?.description ?? "Unknown compilation error")
        }

        var writeError: NSDictionary?
        guard script.write(to: destinationURL, ofType: "com.apple.applescript.script", error: &writeError) else {
            throw ScriptManagerError.scriptExportFailed(details: writeError?.description ?? "Unknown export error")
        }
    }

    private func makeSubroutineEvent(handlerName: String) -> NSAppleEventDescriptor {
        let event = NSAppleEventDescriptor.appleEvent(
            withEventClass: AEEventClass(kASAppleScriptSuite),
            eventID: AEEventID(kASSubroutineEvent),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )

        event.setParam(NSAppleEventDescriptor(string: handlerName), forKeyword: AEKeyword(keyASSubroutineName))
        event.setParam(NSAppleEventDescriptor.list(), forKeyword: AEKeyword(keyDirectObject))
        return event
    }

    private static let fallbackTemplateSource = """
    on shutdownSystem()
        tell application \"System Events\" to shut down
    end shutdownSystem

    on sleepSystem()
        tell application \"System Events\" to sleep
    end sleepSystem
    """
}

/// Manages the countdown timer and executes the chosen action.
@MainActor
final class TimerManager: ObservableObject {
    // MARK: - Published state

    @Published var isRunning: Bool = false
    @Published var remainingSeconds: Int = 0
    @Published var selectedAction: SystemAction = .sleep
    @Published var selectedMinutes: Int = 15

    // MARK: - Private

    private var timer: Timer?
    private weak var statusItem: NSStatusItem?
    let scriptManager: ScriptManager

    let timeOptions: [Int] = [5, 10, 15, 20, 30, 45, 60, 90, 120]
    // MARK: - Init

    @MainActor
    init(statusItem: NSStatusItem? = nil, scriptManager: ScriptManager? = nil) {
        self.statusItem = statusItem
        self.scriptManager = scriptManager ?? ScriptManager()
    }

    func setStatusItem(_ item: NSStatusItem) {
        self.statusItem = item
    }

    // MARK: - Timer control

    func startFromUserIntent() {
        guard !isRunning else {
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
            Task { @MainActor [weak self] in
                self?.tick()
            }
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
            let img = NSImage(systemSymbolName: "powersleep", accessibilityDescription: "Easy Sleep & Shutdown")
            img?.isTemplate = true
            self?.statusItem?.button?.image = img
        }
    }

    private func executeAction() {
        let action = selectedAction
        cancel()

        Task { [weak self] in
            await self?.performAction(action)
        }
    }

    private func performAction(_ action: SystemAction) async {
        do {
            try await scriptManager.executeAction(action)
        } catch let error as ScriptManagerError {
            logScriptError(error, action: action)
            scriptManager.refreshInstallationStatus()
            showActionFailureAlert(for: action, error: error)
        } catch {
            NSLog("Unexpected script execution error for %@: %@", action.rawValue, error.localizedDescription)
            showActionFailureAlert(
                for: action,
                error: ScriptManagerError.scriptExecutionFailed(details: error.localizedDescription)
            )
        }
    }

    private func showActionFailureAlert(for action: SystemAction, error: ScriptManagerError) {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = L.actionFailedTitle(action)
            alert.informativeText = error.recoverySuggestion ?? L.actionUnavailableBody
            alert.alertStyle = .warning
            alert.addButton(withTitle: L.alertButton_ok)
            alert.runModal()
        }
    }

    private func logScriptError(_ error: ScriptManagerError, action: SystemAction) {
        if let details = error.debugDetails {
            NSLog("Script error for %@: %@", action.rawValue, details)
        } else {
            NSLog("Script error for %@: %@", action.rawValue, error.localizedDescription)
        }
    }
}
