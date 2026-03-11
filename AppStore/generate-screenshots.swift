#!/usr/bin/env swift

import AppKit
import SwiftUI

struct ScreenshotScene {
    let filename: String
    let badge: String
    let title: String
    let subtitle: String
    let gradientTop: Color
    let gradientBottom: Color
    let accent: Color
    let preview: AnyView
}

struct AppStoreScreenshotGenerator {
    private static let canvasSize = CGSize(width: 1440, height: 900)

    static func run() throws {
        NSApplication.shared.setActivationPolicy(.prohibited)

        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let outputURL = rootURL.appendingPathComponent("AppStore/screenshots", isDirectory: true)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let existingFiles = try FileManager.default.contentsOfDirectory(at: outputURL, includingPropertiesForKeys: nil)
        for fileURL in existingFiles where fileURL.pathExtension.lowercased() == "png" {
            try FileManager.default.removeItem(at: fileURL)
        }

        for scene in scenes {
            let imageURL = outputURL.appendingPathComponent(scene.filename)
            let view = AppStorePoster(scene: scene)
            try save(view: view, to: imageURL, size: canvasSize)
            print("generated \(imageURL.path)")
        }
    }

    private static var scenes: [ScreenshotScene] {
        [
            ScreenshotScene(
                filename: "01-sleep-setup.png",
                badge: "Sleep Timer",
                title: "Set a sleep timer in one click",
                subtitle: "Choose Sleep, pick a preset, and arm the countdown in seconds.",
                gradientTop: Color(hex: 0xFFF1D6),
                gradientBottom: Color(hex: 0xD8ECFF),
                accent: Color(hex: 0x205C4B),
                preview: AnyView(
                    AppWindowCard {
                        SetupPreview(
                            selectedAction: .sleep,
                            selectedMinutes: 15,
                            useCustom: false,
                            customValue: "15",
                            showPresetMenu: false
                        )
                    }
                )
            ),
            ScreenshotScene(
                filename: "02-preset-picker.png",
                badge: "Preset Durations",
                title: "Choose from quick presets",
                subtitle: "From 5 minutes to 2 hours, common delays are already ready to go.",
                gradientTop: Color(hex: 0xFDE9D8),
                gradientBottom: Color(hex: 0xD9E8FF),
                accent: Color(hex: 0x255D99),
                preview: AnyView(
                    AppWindowCard {
                        SetupPreview(
                            selectedAction: .shutdown,
                            selectedMinutes: 15,
                            useCustom: false,
                            customValue: "15",
                            showPresetMenu: true
                        )
                    }
                )
            ),
            ScreenshotScene(
                filename: "03-custom-duration.png",
                badge: "Custom Entry",
                title: "Need a custom time? Just type it.",
                subtitle: "Switch to Custom mode and enter exactly the number of minutes you want.",
                gradientTop: Color(hex: 0xFEE7DC),
                gradientBottom: Color(hex: 0xE1F4EA),
                accent: Color(hex: 0x7C3E0A),
                preview: AnyView(
                    AppWindowCard {
                        SetupPreview(
                            selectedAction: .sleep,
                            selectedMinutes: 25,
                            useCustom: true,
                            customValue: "25",
                            showPresetMenu: false
                        )
                    }
                )
            ),
            ScreenshotScene(
                filename: "04-shutdown-mode.png",
                badge: "Shutdown Mode",
                title: "Sleep or Shutdown. Your choice.",
                subtitle: "Use the same workflow for a full shutdown when you need it.",
                gradientTop: Color(hex: 0xFCE3D5),
                gradientBottom: Color(hex: 0xF7E3E1),
                accent: Color(hex: 0x8A2C2C),
                preview: AnyView(
                    AppWindowCard {
                        SetupPreview(
                            selectedAction: .shutdown,
                            selectedMinutes: 30,
                            useCustom: false,
                            customValue: "30",
                            showPresetMenu: false
                        )
                    }
                )
            ),
            ScreenshotScene(
                filename: "05-menu-bar-countdown.png",
                badge: "Menu Bar",
                title: "The countdown stays visible",
                subtitle: "Keep an eye on the remaining time right from the macOS menu bar.",
                gradientTop: Color(hex: 0xE9F7F2),
                gradientBottom: Color(hex: 0xD8E7FF),
                accent: Color(hex: 0x124E66),
                preview: AnyView(
                    MenuBarScene(
                        timerLabel: "14:42",
                        panelTime: "14:42"
                    )
                )
            ),
            ScreenshotScene(
                filename: "06-cancel-anytime.png",
                badge: "Active Timer",
                title: "Changed your mind? Cancel anytime.",
                subtitle: "Reopen the window during an active timer and stop it with one click.",
                gradientTop: Color(hex: 0xF6E6D7),
                gradientBottom: Color(hex: 0xDAF0EA),
                accent: Color(hex: 0x6C2436),
                preview: AnyView(
                    AppWindowCard {
                        ActivePreview(
                            actionLabel: "Sleeping in...",
                            time: "12:34"
                        )
                    }
                )
            ),
            ScreenshotScene(
                filename: "07-shutdown-countdown.png",
                badge: "Shutdown Active",
                title: "Keep control while shutdown is armed",
                subtitle: "Reopen the window and cancel the shutdown countdown before it fires.",
                gradientTop: Color(hex: 0xF9E4DA),
                gradientBottom: Color(hex: 0xE2EAFF),
                accent: Color(hex: 0x8A2C2C),
                preview: AnyView(
                    AppWindowCard {
                        ActivePreview(
                            actionLabel: "Shutting down in...",
                            time: "09:55"
                        )
                    }
                )
            ),
            ScreenshotScene(
                filename: "08-about.png",
                badge: "About",
                title: "Small, focused, and easy to understand",
                subtitle: "A lightweight utility with a clear workflow and no unnecessary complexity.",
                gradientTop: Color(hex: 0xF6E4D8),
                gradientBottom: Color(hex: 0xE1F0FF),
                accent: Color(hex: 0x284B63),
                preview: AnyView(
                    AppWindowCard {
                        AboutScreenPreview()
                    }
                )
            ),
            ScreenshotScene(
                filename: "09-two-modes.png",
                badge: "Two Modes",
                title: "Two actions. One simple flow.",
                subtitle: "Switch between Sleep and Shutdown without learning a different workflow.",
                gradientTop: Color(hex: 0xF5E6D8),
                gradientBottom: Color(hex: 0xDCEBFB),
                accent: Color(hex: 0x355C7D),
                preview: AnyView(
                    DualModeScene()
                )
            ),
            ScreenshotScene(
                filename: "10-lightweight-control.png",
                badge: "Lightweight",
                title: "Tiny app. Clear controls. No clutter.",
                subtitle: "A compact utility that stays out of the way until you need to start or cancel a timer.",
                gradientTop: Color(hex: 0xEEE5D8),
                gradientBottom: Color(hex: 0xDEEAF4),
                accent: Color(hex: 0x476C5E),
                preview: AnyView(
                    QuickControlScene()
                )
            )
        ]
    }

    private static func save<V: View>(view: V, to url: URL, size: CGSize) throws {
        let hostingView = NSHostingView(rootView: view.frame(width: size.width, height: size.height))
        hostingView.frame = CGRect(origin: .zero, size: size)
        hostingView.appearance = NSAppearance(named: .aqua)
        hostingView.layoutSubtreeIfNeeded()

        guard let bitmap = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
            throw NSError(domain: "AppStoreScreenshotGenerator", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Unable to create bitmap for \(url.lastPathComponent)"
            ])
        }

        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)

        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "AppStoreScreenshotGenerator", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Unable to encode PNG for \(url.lastPathComponent)"
            ])
        }

        try pngData.write(to: url, options: .atomic)
    }
}

struct AppStorePoster: View {
    let scene: ScreenshotScene

    var body: some View {
        ZStack {
            background

            HStack(alignment: .center, spacing: 72) {
                VStack(alignment: .leading, spacing: 24) {
                    Text(scene.badge.uppercased())
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .tracking(2)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.65))
                        .clipShape(Capsule())

                    Text(scene.title)
                        .font(.system(size: 78, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(scene.subtitle)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 14) {
                        InfoPill(text: "macOS utility")
                        InfoPill(text: "No clutter")
                        InfoPill(text: "Menu bar countdown")
                    }

                    Spacer()
                }
                .frame(width: 600, alignment: .leading)

                scene.preview
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .padding(.horizontal, 88)
            .padding(.vertical, 72)
        }
        .frame(width: 1440, height: 900)
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [scene.gradientTop, scene.gradientBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(scene.accent.opacity(0.18))
                .frame(width: 540, height: 540)
                .blur(radius: 12)
                .offset(x: 360, y: -220)

            RoundedRectangle(cornerRadius: 120, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .frame(width: 460, height: 460)
                .rotationEffect(.degrees(20))
                .offset(x: -440, y: 260)

            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                .frame(width: 1220, height: 720)
                .blendMode(.softLight)
        }
    }
}

struct InfoPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundStyle(Color.black.opacity(0.68))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.45))
            .clipShape(Capsule())
    }
}

enum PreviewTheme {
    static let window = Color(hex: 0x17181B)
    static let windowBar = Color(hex: 0x151619)
    static let control = Color(hex: 0x303237)
    static let controlMuted = Color(hex: 0x25272B)
    static let border = Color.white.opacity(0.10)
    static let textPrimary = Color.white.opacity(0.90)
    static let textSecondary = Color.white.opacity(0.62)
    static let accentBlue = Color(hex: 0x2C80FF)
    static let accentGreen = Color(hex: 0x31D158)
    static let accentRed = Color(hex: 0xFF454A)
}

struct AppWindowCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Circle().fill(Color(hex: 0xFF5F57)).frame(width: 12, height: 12)
                Circle().fill(Color(hex: 0xFEBC2E)).frame(width: 12, height: 12)
                Circle().fill(Color(hex: 0x28C840)).frame(width: 12, height: 12)
                Spacer()
                Text("Easy Sleep & Shutdown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PreviewTheme.textPrimary)
                Spacer()
                Color.clear.frame(width: 44, height: 12)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(PreviewTheme.windowBar)

            content
                .padding(.horizontal, 34)
                .padding(.vertical, 28)
                .background(PreviewTheme.window)
        }
        .frame(width: 560)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(PreviewTheme.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 28, x: 0, y: 18)
    }
}

struct ContentHeader: View {
    var body: some View {
        HStack {
            Text("Easy Sleep & Shutdown")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(PreviewTheme.textPrimary)
            Spacer()
            Image(systemName: "info.circle")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(PreviewTheme.textSecondary)
        }
    }
}

struct TogglePreview: View {
    let isOn: Bool

    var body: some View {
        Capsule()
            .fill(isOn ? PreviewTheme.accentBlue : Color.white.opacity(0.14))
            .frame(width: 72, height: 34)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(Color.white.opacity(0.92))
                    .frame(width: 28, height: 28)
                    .padding(3)
            }
    }
}

struct MenuFieldPreview: View {
    let text: String
    let width: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(PreviewTheme.control)
            .frame(width: width, height: 54)
            .overlay(
                HStack {
                    Text(text)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(PreviewTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(PreviewTheme.textPrimary)
                }
                .padding(.horizontal, 18)
            )
    }
}

struct TextFieldPreview: View {
    let text: String

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.clear)
            .frame(width: 430, height: 58)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(PreviewTheme.accentBlue, lineWidth: 5)
            )
            .overlay(
                HStack(spacing: 0) {
                    Text(text)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(PreviewTheme.textPrimary)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(PreviewTheme.accentBlue)
                        .frame(width: 3, height: 30)
                        .padding(.leading, 2)
                    Spacer()
                }
                .padding(.horizontal, 16)
            )
    }
}

struct SetupPreview: View {
    enum AppAction {
        case sleep
        case shutdown
    }

    let selectedAction: AppAction
    let selectedMinutes: Int
    let useCustom: Bool
    let customValue: String
    let showPresetMenu: Bool

    private let options = [5, 10, 15, 20, 30, 45, 60, 90, 120]

    var body: some View {
        ZStack {
            mainContent

            if showPresetMenu {
                DropdownOverlay(options: options, selectedMinutes: selectedMinutes)
                    .offset(x: -18, y: 82)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var mainContent: some View {
        VStack(spacing: 18) {
            ContentHeader()

            HStack(spacing: 0) {
                SegmentChip(title: "Sleep", isSelected: selectedAction == .sleep)
                SegmentChip(title: "Shutdown", isSelected: selectedAction == .shutdown)
            }
            .frame(width: 340)
            .padding(4)
            .background(PreviewTheme.control)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            HStack(alignment: .center) {
                Text("Time (min)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(PreviewTheme.textSecondary)

                Spacer()

                HStack(spacing: 14) {
                    TogglePreview(isOn: useCustom)
                    Text("Custom")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(PreviewTheme.textSecondary)
                }
            }
            .frame(width: 470)

            if useCustom {
                HStack(spacing: 14) {
                    TextFieldPreview(text: customValue)
                    Text("min")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(PreviewTheme.textSecondary)
                }
            } else {
                MenuFieldPreview(text: "\(selectedMinutes) min", width: 210)
            }

            Text("Will trigger in \(selectedMinutes) min")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PreviewTheme.textSecondary)

            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(PreviewTheme.accentGreen)
                    .frame(width: 470, height: 60)
                    .overlay(
                        Text("Start Timer")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.white)
                    )

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PreviewTheme.control)
                    .frame(width: 470, height: 52)
                    .overlay(
                        Text("Quit App")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(PreviewTheme.textPrimary)
                    )
            }
        }
    }
}

struct DropdownOverlay: View {
    let options: [Int]
    let selectedMinutes: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.82),
                            Color(hex: 0x28313A).opacity(0.86),
                            Color.black.opacity(0.86)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            PreviewTheme.accentGreen.opacity(0.28),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 12)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { minute in
                    HStack(spacing: 10) {
                        if minute == selectedMinutes {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.92))
                                .frame(width: 20)
                        } else {
                            Color.clear.frame(width: 20, height: 14)
                        }

                        Text("\(minute) min")
                            .font(.system(size: 18, weight: minute == selectedMinutes ? .semibold : .medium))
                            .foregroundStyle(Color.white.opacity(0.92))

                        Spacer(minLength: 0)
                    }
                    .frame(width: 150)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .frame(width: 190, height: 455)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.30), radius: 24, x: 0, y: 16)
    }
}

struct SegmentChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(isSelected ? Color.white : PreviewTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? PreviewTheme.accentBlue : Color.clear)
            )
    }
}

struct ActivePreview: View {
    let actionLabel: String
    let time: String

    var body: some View {
        VStack(spacing: 24) {
            ContentHeader()

            VStack(spacing: 10) {
                Text(actionLabel)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(PreviewTheme.textSecondary)

                Text(time)
                    .font(.system(size: 86, weight: .thin, design: .monospaced))
                    .foregroundStyle(PreviewTheme.textPrimary)
            }
            .padding(.top, 6)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PreviewTheme.accentRed)
                .frame(width: 470, height: 60)
                .overlay(
                    Text("Cancel")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                )

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(PreviewTheme.control)
                .frame(width: 470, height: 52)
                .overlay(
                    Text("Quit App")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(PreviewTheme.textPrimary)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct AboutPreview: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "powersleep")
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(PreviewTheme.textSecondary)

            Text("Easy Sleep & Shutdown runs a timer that sleeps or shuts down your Mac after the selected delay. The countdown stays visible in the menu bar, and you can reopen the window at any time.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PreviewTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 420)

            Text("Version 1.0.0")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(PreviewTheme.textSecondary)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(PreviewTheme.accentBlue)
                .frame(width: 470, height: 52)
                .overlay(
                    Text("OK")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Color.white)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct AboutScreenPreview: View {
    var body: some View {
        VStack(spacing: 22) {
            ContentHeader()
            AboutPreview()
        }
    }
}

struct MenuBarScene: View {
    let timerLabel: String
    let panelTime: String

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x00142C), Color(hex: 0x031B3B), Color(hex: 0x08111D)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 610, height: 560)

            Rectangle()
                .fill(Color.black.opacity(0.55))
                .frame(width: 610, height: 54)
                .overlay(alignment: .trailing) {
                    HStack(spacing: 12) {
                        VStack(spacing: -5) {
                            Text("z")
                            Text("z")
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(PreviewTheme.accentBlue)

                        Text(timerLabel)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.92))
                    }
                    .padding(.trailing, 20)
                }

            AppWindowCard {
                ActivePreview(actionLabel: "Sleeping in...", time: panelTime)
            }
            .offset(y: 56)
        }
    }
}

struct DualModeScene: View {
    var body: some View {
        HStack(spacing: 22) {
            AppWindowCard {
                SetupPreview(
                    selectedAction: .sleep,
                    selectedMinutes: 15,
                    useCustom: false,
                    customValue: "15",
                    showPresetMenu: false
                )
            }
            .scaleEffect(0.62)

            AppWindowCard {
                SetupPreview(
                    selectedAction: .shutdown,
                    selectedMinutes: 30,
                    useCustom: false,
                    customValue: "30",
                    showPresetMenu: false
                )
            }
            .scaleEffect(0.62)
        }
    }
}

struct QuickControlScene: View {
    var body: some View {
        VStack(spacing: 18) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x01152B), Color(hex: 0x031D40)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 520, height: 58)
                .overlay(alignment: .trailing) {
                    HStack(spacing: 10) {
                        VStack(spacing: -5) {
                            Text("z")
                            Text("z")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(PreviewTheme.accentBlue)

                        Text("22:10")
                            .font(.system(size: 17, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.92))
                    }
                    .padding(.trailing, 18)
                }

            AppWindowCard {
                ActivePreview(actionLabel: "Sleeping in...", time: "22:10")
            }
            .scaleEffect(0.92)
        }
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

try AppStoreScreenshotGenerator.run()
