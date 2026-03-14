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
    static let alertButton_ok     = "OK"
    static let actionUnavailableTitle = isSerbianLike ? "Akcija nije dostupna" : "Action Unavailable"
    static let actionUnavailableBody = isSerbianLike
        ? "Instalirana skripta nije mogla da izvrši ovu akciju. Proverite da li je SystemActions.scpt u Application Scripts folderu i da li macOS dozvoljava skripti da koristi System Events."
        : "The installed script could not complete this action. Check that SystemActions.scpt is in the Application Scripts folder and that macOS allows the script to use System Events."
    static let setupRequiredTitle = isSerbianLike ? "Potrebna je jednokratna priprema" : "One-Time Setup Required"
    static let setupRequiredBody = isSerbianLike
        ? "Kliknite Izvezi skriptu i sačuvajte SystemActions.scpt u ponuđeni Scripts folder. Posle toga kliknite Continue. Ovo je potrebno samo jednom."
        : "Click Export Script and save SystemActions.scpt in the suggested Scripts folder. Then click Continue. This is only needed once."
    static let onboardingIntro = isSerbianLike
        ? "Sleep i Shutdown rade preko korisnički instalirane skripte. Sačuvajte je jednom u Scripts folder i nastavite u aplikaciju."
        : "Sleep and Shutdown use a user-installed script. Export it once, then continue into the app."
    static let prepareScript = isSerbianLike ? "Izvezi skriptu" : "Export Script"
    static let preparingScript = isSerbianLike ? "Izvozim skriptu…" : "Exporting Script…"
    static let prepareScriptSuccessMessage = isSerbianLike
        ? "Skripta je sačuvana. Kliknite Continue da otvorite aplikaciju."
        : "The script was saved. Click Continue to open the app."
    static let scriptInstalledMessage = isSerbianLike
        ? "SystemActions.scpt je uspešno izvezen."
        : "SystemActions.scpt was exported successfully."
    static let scriptDetectedMessage = isSerbianLike
        ? "SystemActions.scpt je pronađen u Scripts folderu. Setup je završen."
        : "SystemActions.scpt was found in the Scripts folder. Setup is complete."
    static let continueButton = isSerbianLike ? "Continue" : "Continue"
    static let saveScript = isSerbianLike ? "Sačuvaj" : "Save"
    static let chooseSaveLocationTitle = isSerbianLike ? "Sačuvaj SystemActions.scpt" : "Save SystemActions.scpt"
    static let chooseSaveLocationBody = isSerbianLike
        ? "Sačuvajte skriptu u predloženi Application Scripts folder, pa kliknite Continue."
        : "Save the script in the suggested Application Scripts folder, then click Continue."
    static let revealExportedScript = isSerbianLike ? "Prikaži izvezenu skriptu" : "Show Exported Script"
    static let openScriptsFolder = isSerbianLike ? "Otvori Scripts folder" : "Open Scripts Folder"
    static let refreshSetup = isSerbianLike ? "Proveri status skripte" : "Check Script Status"
    static let scriptsFolderLabel = isSerbianLike ? "Scripts folder" : "Scripts Folder"
    static let scriptsFolderUnavailableTitle = isSerbianLike ? "Folder nije dostupan" : "Folder Unavailable"
    static let scriptsFolderUnavailableBody = isSerbianLike
        ? "Aplikacija trenutno ne može da pronađe svoj Application Scripts folder. Zatvorite i ponovo otvorite aplikaciju, pa pokušajte ponovo."
        : "The app could not locate its Application Scripts folder right now. Close and reopen the app, then try again."
    static let scriptsFolderParentOpened = isSerbianLike
        ? "Otvoren je nadređeni folder. Ako Application Scripts folder još nije vidljiv, otvorite aplikaciju ponovo pa pokušajte još jednom."
        : "The parent folder was opened. If the Application Scripts folder is not visible yet, reopen the app and try again."
    static let exportFailedTitle = isSerbianLike ? "Izvoz nije uspeo" : "Export Failed"
    static let exportFailedBody = isSerbianLike
        ? "Skripta nije mogla da se izveze. Zatvorite i ponovo otvorite aplikaciju, pa pokušajte ponovo."
        : "The script could not be exported. Close and reopen the app, then try again."
    static let scriptInstallFailedBody = isSerbianLike
        ? "Aplikacija nije uspela da pripremi SystemActions.scpt za izvoz."
        : "The app could not prepare SystemActions.scpt for export."
    static let sampleTemplateUnavailableTitle = isSerbianLike ? "Primer skripte nije dostupan" : "Sample Script Unavailable"
    static let sampleTemplateUnavailableBody = isSerbianLike
        ? "Aplikacija trenutno ne može da pripremi primer skripte. Ponovo pokrenite aplikaciju i pokušajte još jednom."
        : "The app could not prepare the sample script right now. Relaunch the app and try again."
    static let scriptInvalidTitle = isSerbianLike ? "Skripta nije ispravna" : "Script Invalid"
    static let scriptInvalidBody = isSerbianLike
        ? "Pronađena skripta nije mogla da se učita. Izvezite novi primer skripte i zamenite postojeći fajl."
        : "The detected script could not be loaded. Export a fresh sample script and replace the existing file."
    static let readyStateCaption = isSerbianLike
        ? "Sistemske akcije će se izvršiti preko vaše instalirane skripte kada odbrojavanje istekne."
        : "System actions will run through your installed script when the countdown finishes."

    // About panel
    static let aboutTitle     = isSerbianLike ? "O aplikaciji"            : "About"
    static let aboutBody      = isSerbianLike
        ? "Easy Sleep & Shutdown pokreće tajmer koji koristi korisnički instaliranu skriptu za Sleep ili Shutdown nakon odabranog vremena. Odbrojavanje ostaje vidljivo u traci menija, a prozor možete ponovo otvoriti u bilo kom trenutku."
        : "Easy Sleep & Shutdown runs a timer that uses your installed script to sleep or shut down the Mac after the selected delay. The countdown stays visible in the menu bar, and you can reopen the window at any time."
    static let version        = isSerbianLike ? "Verzija"                 : "Version"

    static func willStartIn(_ minutes: Int) -> String {
        isSerbianLike
            ? "Aktiviraće se za \(minutes) min"
            : "Will trigger in \(minutes) min"
    }

    static func sleepingIn(_ action: SystemAction) -> String {
        switch action {
        case .sleep:    return isSerbianLike ? "Uspavljuje se za…" : "Sleeping in…"
        case .shutdown: return isSerbianLike ? "Gasi se za…"       : "Shutting down in…"
        }
    }

    static func actionFailedTitle(_ action: SystemAction) -> String {
        switch action {
        case .sleep:
            return isSerbianLike ? "Spavanje nije uspelo" : "Sleep Failed"
        case .shutdown:
            return isSerbianLike ? "Gašenje nije uspelo" : "Shutdown Failed"
        }
    }
}
