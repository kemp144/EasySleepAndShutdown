import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject private var scriptManager: ScriptManager

    @State private var selectedAction: SystemAction
    @State private var selectedMinutes: Int
    @State private var customInput: String = ""
    @State private var useCustom: Bool = false
    @State private var showAbout: Bool = false
    @State private var isExportingScript: Bool = false
    @State private var hasDismissedOnboarding: Bool = false
    @State private var showContinueAfterExport: Bool = false

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        self.scriptManager = timerManager.scriptManager
        _selectedAction = State(initialValue: timerManager.selectedAction)
        _selectedMinutes = State(initialValue: timerManager.selectedMinutes)
    }

    // App version read from bundle (works in .app bundle, fallback for swift run)
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var customInputBinding: Binding<String> {
        Binding(
            get: { customInput },
            set: { newValue in
                let filtered = newValue.filter { $0.isNumber }
                customInput = filtered

                if let val = Int(filtered), val > 0 {
                    selectedMinutes = val
                }
            }
        )
    }


    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────────
            HStack {
                Text(L.appTitle)
                    .font(.headline)
                Spacer()
                Button {
                    showAbout.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help(L.aboutTitle)
                .accessibilityLabel(Text(L.aboutTitle))
            }
            .padding(.bottom, 12)

            if showAbout {
                aboutView.id("about")
            } else if !scriptManager.isInstalled && !hasDismissedOnboarding {
                onboardingView.id("onboarding")
            } else if timerManager.isRunning {
                activeView.id("active")
            } else {
                timerSetupView.id("setup")
            }
        }
        .padding(20)
        .frame(width: 336, alignment: .top)
        .onChange(of: useCustom) { enabled in
            guard enabled else { return }
            customInput = "\(selectedMinutes)"
        }
        .task {
            scriptManager.refreshInstallationStatus()
        }
    }

    // MARK: - Setup UI

    private var timerSetupView: some View {
        VStack(spacing: 14) {
            Picker("", selection: $selectedAction) {
                ForEach(SystemAction.allCases) { action in
                    Text(action.label).tag(action)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                HStack {
                    Text(L.manualLabel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Toggle("", isOn: $useCustom)
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                    Text(L.manualToggle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if useCustom {
                    HStack {
                        TextField(L.placeholder, text: customInputBinding)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { applyCustomInput() }
                        Text(L.min)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Picker("", selection: $selectedMinutes) {
                        ForEach(timerManager.timeOptions, id: \.self) { min in
                            Text("\(min) min").tag(min)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
            }

            Text(L.willStartIn(selectedMinutes))
                .font(.caption)
                .foregroundColor(.secondary)

            Text(L.readyStateCaption)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: startTimer) {
                Text(L.startTimer)
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
            .disabled(selectedMinutes <= 0)

            Button(action: quitApp) {
                Text(L.quitApp)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
    }

    private var onboardingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L.setupRequiredTitle)
                        .font(.headline)
                    Text(L.onboardingIntro)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(L.setupRequiredBody)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)

            if let folderURL = scriptManager.scriptsFolderURL {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L.scriptsFolderLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(folderURL.path)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            if let feedback = onboardingFeedback {
                Text(feedback)
                    .font(.caption)
                    .foregroundColor(scriptManager.lastError == nil ? .secondary : .red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if showContinueAfterExport {
                Button(action: continueIntoApp) {
                    Text(L.continueButton)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: prepareScript) {
                    Text(isExportingScript ? L.preparingScript : L.prepareScript)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isExportingScript)
            }

            Button(action: quitApp) {
                Text(L.quitApp)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
    }

    // MARK: - Active countdown UI (shown when user reopens popover)

    private var activeView: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text(L.sleepingIn(timerManager.selectedAction))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(formattedTime)
                    .font(.system(size: 48, weight: .thin, design: .monospaced))
            }

            Button(action: timerManager.cancel) {
                Text(L.cancel)
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)

            Button(action: quitApp) {
                Text(L.quitApp)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
    }

    // MARK: - About view

    private var aboutView: some View {
        VStack(spacing: 12) {
            Image(systemName: "powersleep")
                .font(.system(size: 36))
                .foregroundColor(.secondary)

            Text(L.aboutBody)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("\(L.version) \(appVersion)")
                .font(.caption2)
                .foregroundColor(.secondary)

            Button {
                showAbout = false
            } label: {
                Text("OK")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
    }

    // MARK: - Helpers

    private func applyCustomInput() {
        if let val = Int(customInput), val > 0 {
            selectedMinutes = val
        }
    }

    private func startTimer() {
        timerManager.selectedAction = selectedAction
        timerManager.selectedMinutes = selectedMinutes
        timerManager.startFromUserIntent()
    }

    private func prepareScript() {
        scriptManager.clearFeedback()
        isExportingScript = true

        Task { @MainActor in
            defer { isExportingScript = false }

            do {
                if try scriptManager.exportBundledScript() != nil {
                    scriptManager.refreshInstallationStatus()
                    if scriptManager.isInstalled {
                        scriptManager.presentMessage(L.prepareScriptSuccessMessage)
                        showContinueAfterExport = true
                    } else {
                        showContinueAfterExport = false
                        scriptManager.present(error: .scriptMissing)
                    }
                }
            } catch let error as ScriptManagerError {
                showContinueAfterExport = false
                scriptManager.present(error: error)
            } catch {
                showContinueAfterExport = false
                scriptManager.present(error: .scriptExportFailed(details: error.localizedDescription))
            }
        }
    }

    private func continueIntoApp() {
        scriptManager.refreshInstallationStatus()

        guard scriptManager.isInstalled else {
            scriptManager.revealSetupLocations()
            scriptManager.present(error: .scriptMissing)
            return
        }

        hasDismissedOnboarding = true
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private var formattedTime: String {
        let mins = timerManager.remainingSeconds / 60
        let secs = timerManager.remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private var onboardingFeedback: String? {
        if let error = scriptManager.lastError {
            let baseMessage = error.recoverySuggestion ?? error.errorDescription ?? ""

            if let details = error.debugDetails, !details.isEmpty {
                return "\(baseMessage)\n\nDetails: \(details)"
            }

            return baseMessage
        }

        return scriptManager.lastSetupMessage
    }
}
