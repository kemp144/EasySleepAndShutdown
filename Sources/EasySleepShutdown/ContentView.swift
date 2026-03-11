import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var timerManager: TimerManager

    @State private var selectedAction: SleepAction
    @State private var selectedMinutes: Int
    @State private var oneSecondTimer: Bool
    @State private var customInput: String = ""
    @State private var useCustom: Bool = false
    @State private var showAbout: Bool = false

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        _selectedAction = State(initialValue: timerManager.selectedAction)
        _selectedMinutes = State(initialValue: timerManager.selectedMinutes)
        _oneSecondTimer = State(initialValue: timerManager.oneSecondTimer)
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
            }
            .padding(.bottom, 12)

            if showAbout {
                aboutView
            } else if timerManager.isRunning {
                activeView
            } else {
                setupView
            }
        }
        .padding(20)
        .frame(width: 280)
        .onChange(of: useCustom) { enabled in
            guard enabled else { return }
            customInput = "\(selectedMinutes)"
        }
    }

    // MARK: - Setup UI

    private var setupView: some View {
        VStack(spacing: 14) {
            Picker("", selection: $selectedAction) {
                ForEach(SleepAction.allCases) { action in
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

            HStack {
                Text(L.testMode)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $oneSecondTimer)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
            }

            Text(oneSecondTimer ? L.willStartInOneSecond : L.willStartIn(selectedMinutes))
                .font(.caption)
                .foregroundColor(.secondary)

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
        timerManager.oneSecondTimer = oneSecondTimer
        timerManager.start()
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private var formattedTime: String {
        let mins = timerManager.remainingSeconds / 60
        let secs = timerManager.remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
