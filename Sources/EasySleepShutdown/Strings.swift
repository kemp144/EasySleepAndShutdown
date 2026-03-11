import Foundation

/// Detektuje sistem jezik i vraća odgovarajuće stringove.
/// Podržava srpski (sr, hr, bs) i engleski (sve ostalo).
enum L {
    private static var isSerbianLike: Bool = {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("sr") || preferred.hasPrefix("hr") || preferred.hasPrefix("bs")
    }()

    static let appTitle       = isSerbianLike ? "Lako spavanje i gašenje" : "Easy Sleep & Shutdown"
    static let sleep          = isSerbianLike ? "Spavanje"                : "Sleep"
    static let shutdown       = isSerbianLike ? "Gašenje"                 : "Shutdown"
    static let manualLabel    = isSerbianLike ? "Vreme (min)"             : "Time (min)"
    static let manualToggle   = isSerbianLike ? "Ručno"                   : "Custom"
    static let placeholder    = isSerbianLike ? "npr. 25"                 : "e.g. 25"
    static let min            = "min"
    static let startTimer     = isSerbianLike ? "Pokreni tajmer"          : "Start Timer"
    static let cancel         = isSerbianLike ? "Otkaži"                  : "Cancel"
    static let continueText   = isSerbianLike ? "Nastavi"                 : "Continue"
    static let alertButton_ok     = "OK"
    static let alertButton_cancel = isSerbianLike ? "Otkaži tajmer"       : "Cancel Timer"
    static let alertTitle     = appTitle
    static let automationSetupTitle = appTitle
    static let automationSetupBody = isSerbianLike
        ? "Easy Sleep & Shutdown treba Automation dozvolu za kontrolu aplikacije System Events kako bi mogao da uspava ili ugasi Mac kada tajmer istekne."
        : "Easy Sleep & Shutdown needs Automation permission to control System Events so it can sleep or shut down your Mac when the timer ends."
    static let automationDeniedTitle = isSerbianLike ? "Dozvola je potrebna" : "Permission Required"
    static let automationDeniedBody = isSerbianLike
        ? "Bez Automation dozvole tajmer ne moze da izvrsi sleep ili shutdown akciju. Dozvolu mozete odobriti u System Settings > Privacy & Security > Automation."
        : "Without Automation permission, the timer cannot perform sleep or shutdown. You can allow it in System Settings > Privacy & Security > Automation."
    static let sandboxNotice  = isSerbianLike
        ? "Gašenje u sandbox modu može zahtevati potvrdu sistema."
        : "Shutdown in sandboxed builds may require system confirmation."
    static let shutdownNotice = isSerbianLike
        ? "macOS će prikazati dijalog za potvrdu."
        : "macOS will show a shutdown confirmation."
    static let sandboxAlertTitle = isSerbianLike ? "Tajmer završen" : "Timer Finished"
    static let sandboxAlertBody = isSerbianLike
        ? "App Sandbox blokira automatsko uspavljivanje i gašenje sistema. Ovaj build može samo da vas podseti da ručno pokrenete akciju."
        : "App Sandbox blocks automatic system sleep and shutdown. This build can only remind you to trigger the action manually."

    // About panel
    static let aboutTitle     = isSerbianLike ? "O aplikaciji"            : "About"
    static let aboutBody      = isSerbianLike
        ? "Easy Sleep & Shutdown pokreće tajmer koji uspavljuje ili gasi Mac nakon odabranog vremena. Radi tiho iz trake menija — bez Dock ikone, bez prozora."
        : "Easy Sleep & Shutdown runs a timer that sleeps or shuts down your Mac after the selected delay. It runs silently from the menu bar — no Dock icon, no windows."
    static let version        = isSerbianLike ? "Verzija"                 : "Version"

    static func willStartIn(_ minutes: Int) -> String {
        isSerbianLike
            ? "Aktiviraće se za \(minutes) min"
            : "Will trigger in \(minutes) min"
    }

    static func alertBody(_ action: SleepAction) -> String {
        let actionName = action == .sleep
            ? (isSerbianLike ? "Spavanje" : "Sleep")
            : (isSerbianLike ? "Gašenje"  : "Shutdown")
        return isSerbianLike
            ? "\(actionName) za 1 minutu!"
            : "\(actionName) in 1 minute!"
    }

    static func sleepingIn(_ action: SleepAction) -> String {
        switch action {
        case .sleep:    return isSerbianLike ? "Uspavljuje se za…" : "Sleeping in…"
        case .shutdown: return isSerbianLike ? "Gasi se za…"       : "Shutting down in…"
        }
    }
}
