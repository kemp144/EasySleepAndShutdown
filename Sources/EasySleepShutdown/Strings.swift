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
    static let quitApp        = isSerbianLike ? "Ugasi program"           : "Quit App"
    static let preparing      = isSerbianLike ? "Priprema…"               : "Preparing…"
    static let alertButton_ok     = "OK"
    static let automationDeniedTitle = isSerbianLike ? "Dozvola je potrebna" : "Permission Required"
    static let automationDeniedBody = isSerbianLike
        ? "Bez Automation dozvole shutdown tajmer ne može da pošalje sistemski zahtev za gašenje. Dozvolu možete odobriti u System Settings > Privacy & Security > Automation."
        : "Without Automation permission, the shutdown timer cannot send the system shutdown request. You can allow it in System Settings > Privacy & Security > Automation."
    static let sleepUnavailableTitle = isSerbianLike ? "Spavanje nije uspelo" : "Sleep Failed"
    static let sleepUnavailableBody = isSerbianLike
        ? "Sistemski sleep zahtev nije prošao. Proverite da li je macOS dozvolio ovu akciju."
        : "The system sleep request did not succeed. Verify that macOS allowed the action."
    static let shutdownUnavailableTitle = isSerbianLike ? "Gašenje nije uspelo" : "Shutdown Failed"
    static let shutdownUnavailableBody = isSerbianLike
        ? "Sistemski shutdown zahtev nije prošao. Proverite da li je build potpisan sa odgovarajućim entitlement-om i da li je macOS dozvolio ovu akciju."
        : "The system shutdown request did not succeed. Verify that the build is signed with the required entitlement and that macOS allowed the action."

    // About panel
    static let aboutTitle     = isSerbianLike ? "O aplikaciji"            : "About"
    static let aboutBody      = isSerbianLike
        ? "Easy Sleep & Shutdown pokreće tajmer koji uspavljuje ili gasi Mac nakon odabranog vremena. Odbrojavanje ostaje vidljivo u traci menija, a prozor možete ponovo otvoriti u bilo kom trenutku."
        : "Easy Sleep & Shutdown runs a timer that sleeps or shuts down your Mac after the selected delay. The countdown stays visible in the menu bar, and you can reopen the window at any time."
    static let version        = isSerbianLike ? "Verzija"                 : "Version"

    static func willStartIn(_ minutes: Int) -> String {
        isSerbianLike
            ? "Aktiviraće se za \(minutes) min"
            : "Will trigger in \(minutes) min"
    }

    static func sleepingIn(_ action: SleepAction) -> String {
        switch action {
        case .sleep:    return isSerbianLike ? "Uspavljuje se za…" : "Sleeping in…"
        case .shutdown: return isSerbianLike ? "Gasi se za…"       : "Shutting down in…"
        }
    }
}
