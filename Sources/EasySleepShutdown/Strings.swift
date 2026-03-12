import Foundation

/// Centralized in-code localization for the menu bar app.
/// This keeps the existing project structure intact while expanding language coverage.
enum L {
    enum Language: Hashable {
        case en
        case ja
        case de
        case fr
        case it
        case es
        case pt
        case nl
        case sv
        case da
        case nb
        case fi
        case zhHant
        case zhHans
        case ko
        case sr

        static func resolve(preferredLanguages: [String] = Locale.preferredLanguages) -> Language {
            for identifier in preferredLanguages {
                let normalized = identifier.replacingOccurrences(of: "_", with: "-").lowercased()

                if normalized.hasPrefix("zh") {
                    if normalized.contains("hant")
                        || normalized.hasSuffix("-tw")
                        || normalized.hasSuffix("-hk")
                        || normalized.hasSuffix("-mo") {
                        return .zhHant
                    }

                    return .zhHans
                }

                if normalized.hasPrefix("nb")
                    || normalized.hasPrefix("no")
                    || normalized.hasPrefix("nn") {
                    return .nb
                }

                if normalized.hasPrefix("sr")
                    || normalized.hasPrefix("hr")
                    || normalized.hasPrefix("bs") {
                    return .sr
                }

                let languageCode = normalized.split(separator: "-").first.map(String.init) ?? normalized

                switch languageCode {
                case "en": return .en
                case "ja": return .ja
                case "de": return .de
                case "fr": return .fr
                case "it": return .it
                case "es": return .es
                case "pt": return .pt
                case "nl": return .nl
                case "sv": return .sv
                case "da": return .da
                case "fi": return .fi
                case "ko": return .ko
                default: continue
                }
            }

            return .en
        }
    }

    struct Table {
        let sleep: String
        let shutdown: String
        let manualLabel: String
        let manualToggle: String
        let placeholder: String
        let minuteUnit: String
        let startTimer: String
        let cancel: String
        let quitApp: String
        let preparing: String
        let okButton: String
        let automationDeniedTitle: String
        let automationDeniedBody: String
        let sleepUnavailableTitle: String
        let sleepUnavailableBody: String
        let shutdownUnavailableTitle: String
        let shutdownUnavailableBody: String
        let aboutTitle: String
        let aboutBody: String
        let version: String
        let presetMinutesFormat: String
        let willStartInFormat: String
        let sleepingIn: String
        let shuttingDownIn: String
    }

    private static let appName = "Easy Sleep & Shutdown"

    private static let tables: [Language: Table] = [
        .en: Table(
            sleep: "Sleep",
            shutdown: "Shutdown",
            manualLabel: "Time (min)",
            manualToggle: "Custom",
            placeholder: "e.g. 25",
            minuteUnit: "min",
            startTimer: "Start Timer",
            cancel: "Cancel",
            quitApp: "Quit App",
            preparing: "Preparing…",
            okButton: "OK",
            automationDeniedTitle: "Permission Required",
            automationDeniedBody: "Without Automation permission, the shutdown timer cannot send the system shutdown request. You can allow it in System Settings > Privacy & Security > Automation.",
            sleepUnavailableTitle: "Sleep Failed",
            sleepUnavailableBody: "The system sleep request did not succeed. Verify that macOS allowed this action.",
            shutdownUnavailableTitle: "Shutdown Failed",
            shutdownUnavailableBody: "The system shutdown request did not succeed. Verify that the build is signed with the required entitlement and that macOS allowed this action.",
            aboutTitle: "About",
            aboutBody: "Easy Sleep & Shutdown runs a timer that sleeps or shuts down your Mac after the selected delay. The countdown stays visible in the menu bar, and you can reopen the window at any time.",
            version: "Version",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Will trigger in %d min",
            sleepingIn: "Sleeping in…",
            shuttingDownIn: "Shutting down in…"
        ),
        .ja: Table(
            sleep: "スリープ",
            shutdown: "システム終了",
            manualLabel: "時間（分）",
            manualToggle: "カスタム",
            placeholder: "例: 25",
            minuteUnit: "分",
            startTimer: "タイマーを開始",
            cancel: "キャンセル",
            quitApp: "アプリを終了",
            preparing: "準備中…",
            okButton: "OK",
            automationDeniedTitle: "権限が必要です",
            automationDeniedBody: "Automation 権限がないため、シャットダウンタイマーはシステム終了要求を送信できません。System Settings > Privacy & Security > Automation で許可してください。",
            sleepUnavailableTitle: "スリープできませんでした",
            sleepUnavailableBody: "システムのスリープ要求に失敗しました。macOS でこの操作が許可されているか確認してください。",
            shutdownUnavailableTitle: "システム終了できませんでした",
            shutdownUnavailableBody: "システム終了要求に失敗しました。必要な entitlement でビルドされていることと、この操作が macOS で許可されていることを確認してください。",
            aboutTitle: "このアプリについて",
            aboutBody: "Easy Sleep & Shutdown は、指定した時間後に Mac をスリープまたはシステム終了させるタイマーを実行します。カウントダウンはメニューバーに表示され続け、ウィンドウはいつでも再表示できます。",
            version: "バージョン",
            presetMinutesFormat: "%d 分",
            willStartInFormat: "%d分後に実行",
            sleepingIn: "スリープまで…",
            shuttingDownIn: "終了まで…"
        ),
        .de: Table(
            sleep: "Ruhezustand",
            shutdown: "Ausschalten",
            manualLabel: "Zeit (Min.)",
            manualToggle: "Benutzerdefiniert",
            placeholder: "z. B. 25",
            minuteUnit: "Min.",
            startTimer: "Timer starten",
            cancel: "Abbrechen",
            quitApp: "App beenden",
            preparing: "Wird vorbereitet…",
            okButton: "OK",
            automationDeniedTitle: "Berechtigung erforderlich",
            automationDeniedBody: "Ohne Automatisierungsberechtigung kann der Ausschalt-Timer die Systemanforderung zum Ausschalten nicht senden. Sie können sie in den Systemeinstellungen unter Datenschutz & Sicherheit > Automation erlauben.",
            sleepUnavailableTitle: "Ruhezustand fehlgeschlagen",
            sleepUnavailableBody: "Die Anfrage, den Mac in den Ruhezustand zu versetzen, war nicht erfolgreich. Prüfen Sie, ob macOS diese Aktion zugelassen hat.",
            shutdownUnavailableTitle: "Ausschalten fehlgeschlagen",
            shutdownUnavailableBody: "Die Systemanforderung zum Ausschalten war nicht erfolgreich. Prüfen Sie, ob der Build mit dem erforderlichen Entitlement signiert ist und ob macOS diese Aktion zugelassen hat.",
            aboutTitle: "Über diese App",
            aboutBody: "Easy Sleep & Shutdown startet einen Timer, der Ihren Mac nach der gewählten Verzögerung in den Ruhezustand versetzt oder ausschaltet. Der Countdown bleibt in der Menüleiste sichtbar, und Sie können das Fenster jederzeit wieder öffnen.",
            version: "Version",
            presetMinutesFormat: "%d Min.",
            willStartInFormat: "Wird in %d Min. ausgeführt",
            sleepingIn: "Ruhezustand in…",
            shuttingDownIn: "Ausschalten in…"
        ),
        .fr: Table(
            sleep: "Veille",
            shutdown: "Éteindre",
            manualLabel: "Temps (min)",
            manualToggle: "Personnalisé",
            placeholder: "ex. 25",
            minuteUnit: "min",
            startTimer: "Démarrer le minuteur",
            cancel: "Annuler",
            quitApp: "Quitter l’app",
            preparing: "Préparation…",
            okButton: "OK",
            automationDeniedTitle: "Autorisation requise",
            automationDeniedBody: "Sans autorisation d’automatisation, le minuteur d’arrêt ne peut pas envoyer la demande d’extinction au système. Vous pouvez l’autoriser dans Réglages Système > Confidentialité et sécurité > Automatisation.",
            sleepUnavailableTitle: "Échec de la mise en veille",
            sleepUnavailableBody: "La demande de mise en veille du système n’a pas abouti. Vérifiez que macOS autorise cette action.",
            shutdownUnavailableTitle: "Échec de l’extinction",
            shutdownUnavailableBody: "La demande d’extinction du système n’a pas abouti. Vérifiez que le build est signé avec l’entitlement requis et que macOS autorise cette action.",
            aboutTitle: "À propos",
            aboutBody: "Easy Sleep & Shutdown lance un minuteur qui met votre Mac en veille ou l’éteint après le délai choisi. Le compte à rebours reste visible dans la barre des menus, et vous pouvez rouvrir la fenêtre à tout moment.",
            version: "Version",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Déclenchement dans %d min",
            sleepingIn: "Mise en veille dans…",
            shuttingDownIn: "Extinction dans…"
        ),
        .it: Table(
            sleep: "Stop",
            shutdown: "Spegni",
            manualLabel: "Tempo (min)",
            manualToggle: "Personalizzato",
            placeholder: "es. 25",
            minuteUnit: "min",
            startTimer: "Avvia timer",
            cancel: "Annulla",
            quitApp: "Esci dall'app",
            preparing: "Preparazione…",
            okButton: "OK",
            automationDeniedTitle: "Autorizzazione richiesta",
            automationDeniedBody: "Senza l’autorizzazione Automazione, il timer di spegnimento non può inviare la richiesta di spegnimento al sistema. Puoi consentirla in Impostazioni di Sistema > Privacy e sicurezza > Automazione.",
            sleepUnavailableTitle: "Stop non riuscito",
            sleepUnavailableBody: "La richiesta di stop del sistema non è riuscita. Verifica che macOS abbia consentito questa azione.",
            shutdownUnavailableTitle: "Spegnimento non riuscito",
            shutdownUnavailableBody: "La richiesta di spegnimento del sistema non è riuscita. Verifica che la build sia firmata con l’entitlement richiesto e che macOS abbia consentito questa azione.",
            aboutTitle: "Informazioni",
            aboutBody: "Easy Sleep & Shutdown avvia un timer che mette in stop o spegne il tuo Mac dopo il ritardo selezionato. Il conto alla rovescia resta visibile nella barra dei menu e puoi riaprire la finestra in qualsiasi momento.",
            version: "Versione",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Si attiverà tra %d min",
            sleepingIn: "Stop tra…",
            shuttingDownIn: "Spegnimento tra…"
        ),
        .es: Table(
            sleep: "Reposo",
            shutdown: "Apagar",
            manualLabel: "Tiempo (min)",
            manualToggle: "Personalizado",
            placeholder: "p. ej. 25",
            minuteUnit: "min",
            startTimer: "Iniciar temporizador",
            cancel: "Cancelar",
            quitApp: "Salir de la app",
            preparing: "Preparando…",
            okButton: "OK",
            automationDeniedTitle: "Permiso requerido",
            automationDeniedBody: "Sin permiso de Automatización, el temporizador de apagado no puede enviar la solicitud de apagado del sistema. Puedes permitirlo en Configuración del Sistema > Privacidad y seguridad > Automatización.",
            sleepUnavailableTitle: "No se pudo activar el reposo",
            sleepUnavailableBody: "La solicitud de reposo del sistema no se completó correctamente. Verifica que macOS haya permitido esta acción.",
            shutdownUnavailableTitle: "No se pudo apagar",
            shutdownUnavailableBody: "La solicitud de apagado del sistema no se completó correctamente. Verifica que la compilación esté firmada con el entitlement requerido y que macOS haya permitido esta acción.",
            aboutTitle: "Acerca de",
            aboutBody: "Easy Sleep & Shutdown ejecuta un temporizador que pone en reposo o apaga tu Mac después del tiempo seleccionado. La cuenta atrás permanece visible en la barra de menús y puedes volver a abrir la ventana en cualquier momento.",
            version: "Versión",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Se activará en %d min",
            sleepingIn: "Reposo en…",
            shuttingDownIn: "Apagado en…"
        ),
        .pt: Table(
            sleep: "Repouso",
            shutdown: "Desligar",
            manualLabel: "Tempo (min)",
            manualToggle: "Personalizado",
            placeholder: "ex.: 25",
            minuteUnit: "min",
            startTimer: "Iniciar temporizador",
            cancel: "Cancelar",
            quitApp: "Sair da app",
            preparing: "A preparar…",
            okButton: "OK",
            automationDeniedTitle: "Permissão necessária",
            automationDeniedBody: "Sem permissão de Automação, o temporizador de encerramento não consegue enviar o pedido de desligamento do sistema. Pode autorizá-lo em Definições do Sistema > Privacidade e Segurança > Automação.",
            sleepUnavailableTitle: "Falha ao entrar em repouso",
            sleepUnavailableBody: "O pedido de repouso do sistema não foi concluído. Verifique se o macOS permitiu esta ação.",
            shutdownUnavailableTitle: "Falha ao desligar",
            shutdownUnavailableBody: "O pedido de desligamento do sistema não foi concluído. Verifique se a build está assinada com o entitlement necessário e se o macOS permitiu esta ação.",
            aboutTitle: "Acerca da app",
            aboutBody: "Easy Sleep & Shutdown executa um temporizador que coloca o Mac em repouso ou o desliga após o atraso selecionado. A contagem decrescente permanece visível na barra de menus, e pode reabrir a janela a qualquer momento.",
            version: "Versão",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Será executado em %d min",
            sleepingIn: "Repouso em…",
            shuttingDownIn: "Desligar em…"
        ),
        .nl: Table(
            sleep: "Sluimerstand",
            shutdown: "Afsluiten",
            manualLabel: "Tijd (min)",
            manualToggle: "Aangepast",
            placeholder: "bijv. 25",
            minuteUnit: "min",
            startTimer: "Timer starten",
            cancel: "Annuleren",
            quitApp: "App afsluiten",
            preparing: "Voorbereiden…",
            okButton: "OK",
            automationDeniedTitle: "Toestemming vereist",
            automationDeniedBody: "Zonder automatiseringstoestemming kan de uitschakeltimer het systeemverzoek om af te sluiten niet verzenden. Je kunt dit toestaan in Systeeminstellingen > Privacy en beveiliging > Automatisering.",
            sleepUnavailableTitle: "Sluimerstand mislukt",
            sleepUnavailableBody: "Het systeemverzoek om in sluimerstand te gaan is niet geslaagd. Controleer of macOS deze actie heeft toegestaan.",
            shutdownUnavailableTitle: "Afsluiten mislukt",
            shutdownUnavailableBody: "Het systeemverzoek om af te sluiten is niet geslaagd. Controleer of de build is ondertekend met het vereiste entitlement en of macOS deze actie heeft toegestaan.",
            aboutTitle: "Over",
            aboutBody: "Easy Sleep & Shutdown start een timer die je Mac na de gekozen vertraging in sluimerstand zet of afsluit. Het aftellen blijft zichtbaar in de menubalk en je kunt het venster op elk moment opnieuw openen.",
            version: "Versie",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Wordt uitgevoerd over %d min",
            sleepingIn: "Sluimerstand over…",
            shuttingDownIn: "Afsluiten over…"
        ),
        .sv: Table(
            sleep: "Vila",
            shutdown: "Stäng av",
            manualLabel: "Tid (min)",
            manualToggle: "Anpassad",
            placeholder: "t.ex. 25",
            minuteUnit: "min",
            startTimer: "Starta timer",
            cancel: "Avbryt",
            quitApp: "Avsluta appen",
            preparing: "Förbereder…",
            okButton: "OK",
            automationDeniedTitle: "Behörighet krävs",
            automationDeniedBody: "Utan Automatisering-behörighet kan avstängningstimern inte skicka systembegäran om avstängning. Du kan tillåta detta i Systeminställningar > Integritet och säkerhet > Automatisering.",
            sleepUnavailableTitle: "Vila misslyckades",
            sleepUnavailableBody: "Systembegäran om vila lyckades inte. Kontrollera att macOS tillät den här åtgärden.",
            shutdownUnavailableTitle: "Avstängning misslyckades",
            shutdownUnavailableBody: "Systembegäran om avstängning lyckades inte. Kontrollera att bygget är signerat med rätt entitlement och att macOS tillät den här åtgärden.",
            aboutTitle: "Om appen",
            aboutBody: "Easy Sleep & Shutdown startar en timer som sätter din Mac i vila eller stänger av den efter vald fördröjning. Nedräkningen förblir synlig i menyraden och du kan öppna fönstret igen när som helst.",
            version: "Version",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Startar om %d min",
            sleepingIn: "Vila om…",
            shuttingDownIn: "Stänger av om…"
        ),
        .da: Table(
            sleep: "Dvale",
            shutdown: "Sluk",
            manualLabel: "Tid (min)",
            manualToggle: "Brugerdefineret",
            placeholder: "f.eks. 25",
            minuteUnit: "min",
            startTimer: "Start timer",
            cancel: "Annuller",
            quitApp: "Afslut app",
            preparing: "Forbereder…",
            okButton: "OK",
            automationDeniedTitle: "Tilladelse påkrævet",
            automationDeniedBody: "Uden Automatisering-tilladelse kan sluk-timeren ikke sende systemanmodningen om at slukke. Du kan tillade det i Systemindstillinger > Privatliv og sikkerhed > Automatisering.",
            sleepUnavailableTitle: "Dvale mislykkedes",
            sleepUnavailableBody: "Systemanmodningen om dvale lykkedes ikke. Kontroller, at macOS har tilladt denne handling.",
            shutdownUnavailableTitle: "Slukning mislykkedes",
            shutdownUnavailableBody: "Systemanmodningen om slukning lykkedes ikke. Kontroller, at buildet er signeret med det nødvendige entitlement, og at macOS har tilladt denne handling.",
            aboutTitle: "Om",
            aboutBody: "Easy Sleep & Shutdown starter en timer, som sætter din Mac i dvale eller slukker den efter den valgte forsinkelse. Nedtællingen forbliver synlig i menulinjen, og du kan åbne vinduet igen når som helst.",
            version: "Version",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Udføres om %d min",
            sleepingIn: "Dvale om…",
            shuttingDownIn: "Slukker om…"
        ),
        .nb: Table(
            sleep: "Dvale",
            shutdown: "Slå av",
            manualLabel: "Tid (min)",
            manualToggle: "Tilpasset",
            placeholder: "f.eks. 25",
            minuteUnit: "min",
            startTimer: "Start tidtaker",
            cancel: "Avbryt",
            quitApp: "Avslutt app",
            preparing: "Forbereder…",
            okButton: "OK",
            automationDeniedTitle: "Tillatelse kreves",
            automationDeniedBody: "Uten Automatisering-tillatelse kan ikke avslåingstimeren sende systemforespørselen om å slå av. Du kan tillate dette i Systeminnstillinger > Personvern og sikkerhet > Automatisering.",
            sleepUnavailableTitle: "Dvale mislyktes",
            sleepUnavailableBody: "Systemforespørselen om dvale lyktes ikke. Kontroller at macOS tillot denne handlingen.",
            shutdownUnavailableTitle: "Nedstenging mislyktes",
            shutdownUnavailableBody: "Systemforespørselen om å slå av lyktes ikke. Kontroller at builden er signert med nødvendig entitlement, og at macOS tillot denne handlingen.",
            aboutTitle: "Om appen",
            aboutBody: "Easy Sleep & Shutdown starter en tidtaker som setter Macen i dvale eller slår den av etter valgt forsinkelse. Nedtellingen forblir synlig i menylinjen, og du kan åpne vinduet igjen når som helst.",
            version: "Versjon",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Starter om %d min",
            sleepingIn: "Dvale om…",
            shuttingDownIn: "Slår av om…"
        ),
        .fi: Table(
            sleep: "Nukkumaan",
            shutdown: "Sammuta",
            manualLabel: "Aika (min)",
            manualToggle: "Mukautettu",
            placeholder: "esim. 25",
            minuteUnit: "min",
            startTimer: "Käynnistä ajastin",
            cancel: "Peruuta",
            quitApp: "Sulje appi",
            preparing: "Valmistellaan…",
            okButton: "OK",
            automationDeniedTitle: "Lupa vaaditaan",
            automationDeniedBody: "Ilman Automaatio-oikeutta sammutusajastin ei voi lähettää järjestelmän sammutuspyyntöä. Voit sallia sen kohdassa Järjestelmäasetukset > Tietosuoja ja suojaus > Automaatio.",
            sleepUnavailableTitle: "Nukkumaan siirtyminen epäonnistui",
            sleepUnavailableBody: "Järjestelmän nukkumispyyntö epäonnistui. Varmista, että macOS salli tämän toiminnon.",
            shutdownUnavailableTitle: "Sammutus epäonnistui",
            shutdownUnavailableBody: "Järjestelmän sammutuspyyntö epäonnistui. Varmista, että build on allekirjoitettu vaaditulla entitlementilla ja että macOS salli tämän toiminnon.",
            aboutTitle: "Tietoja",
            aboutBody: "Easy Sleep & Shutdown käynnistää ajastimen, joka laittaa Macisi nukkumaan tai sammuttaa sen valitun viiveen jälkeen. Laskuri pysyy näkyvissä valikkorivillä, ja voit avata ikkunan uudelleen milloin tahansa.",
            version: "Versio",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Käynnistyy %d min kuluttua",
            sleepingIn: "Siirtyy nukkumaan…",
            shuttingDownIn: "Sammuu…"
        ),
        .zhHant: Table(
            sleep: "睡眠",
            shutdown: "關機",
            manualLabel: "時間（分鐘）",
            manualToggle: "自訂",
            placeholder: "例如 25",
            minuteUnit: "分鐘",
            startTimer: "開始計時",
            cancel: "取消",
            quitApp: "結束 App",
            preparing: "準備中…",
            okButton: "OK",
            automationDeniedTitle: "需要權限",
            automationDeniedBody: "若沒有自動化權限，關機計時器無法送出系統關機請求。你可以在「系統設定 > 隱私權與安全性 > 自動化」中允許。",
            sleepUnavailableTitle: "睡眠失敗",
            sleepUnavailableBody: "系統睡眠請求未成功。請確認 macOS 已允許此操作。",
            shutdownUnavailableTitle: "關機失敗",
            shutdownUnavailableBody: "系統關機請求未成功。請確認此 build 已使用必要 entitlement 簽署，且 macOS 已允許此操作。",
            aboutTitle: "關於",
            aboutBody: "Easy Sleep & Shutdown 會在你選定的延遲時間後啟動計時器，讓 Mac 進入睡眠或關機。倒數會持續顯示在選單列中，你也可以隨時重新開啟視窗。",
            version: "版本",
            presetMinutesFormat: "%d 分鐘",
            willStartInFormat: "%d 分鐘後執行",
            sleepingIn: "即將進入睡眠…",
            shuttingDownIn: "即將關機…"
        ),
        .zhHans: Table(
            sleep: "睡眠",
            shutdown: "关机",
            manualLabel: "时间（分钟）",
            manualToggle: "自定义",
            placeholder: "例如 25",
            minuteUnit: "分钟",
            startTimer: "开始计时",
            cancel: "取消",
            quitApp: "退出 App",
            preparing: "准备中…",
            okButton: "OK",
            automationDeniedTitle: "需要权限",
            automationDeniedBody: "如果没有自动化权限，关机计时器将无法发送系统关机请求。你可以在“系统设置 > 隐私与安全性 > 自动化”中允许。",
            sleepUnavailableTitle: "睡眠失败",
            sleepUnavailableBody: "系统睡眠请求未成功。请确认 macOS 已允许此操作。",
            shutdownUnavailableTitle: "关机失败",
            shutdownUnavailableBody: "系统关机请求未成功。请确认该 build 已使用所需 entitlement 签名，并且 macOS 已允许此操作。",
            aboutTitle: "关于",
            aboutBody: "Easy Sleep & Shutdown 会在所选延迟时间后启动计时器，让 Mac 进入睡眠或关机。倒计时会持续显示在菜单栏中，你也可以随时重新打开窗口。",
            version: "版本",
            presetMinutesFormat: "%d 分钟",
            willStartInFormat: "%d 分钟后执行",
            sleepingIn: "即将睡眠…",
            shuttingDownIn: "即将关机…"
        ),
        .ko: Table(
            sleep: "잠자기",
            shutdown: "종료",
            manualLabel: "시간 (분)",
            manualToggle: "직접 입력",
            placeholder: "예: 25",
            minuteUnit: "분",
            startTimer: "타이머 시작",
            cancel: "취소",
            quitApp: "앱 종료",
            preparing: "준비 중…",
            okButton: "OK",
            automationDeniedTitle: "권한 필요",
            automationDeniedBody: "자동화 권한이 없으면 종료 타이머가 시스템 종료 요청을 보낼 수 없습니다. 시스템 설정 > 개인정보 보호 및 보안 > 자동화에서 허용할 수 있습니다.",
            sleepUnavailableTitle: "잠자기 실패",
            sleepUnavailableBody: "시스템 잠자기 요청이 성공하지 않았습니다. macOS가 이 작업을 허용했는지 확인하세요.",
            shutdownUnavailableTitle: "종료 실패",
            shutdownUnavailableBody: "시스템 종료 요청이 성공하지 않았습니다. 빌드가 필요한 entitlement로 서명되었는지, 그리고 macOS가 이 작업을 허용했는지 확인하세요.",
            aboutTitle: "앱 정보",
            aboutBody: "Easy Sleep & Shutdown은 선택한 지연 시간 후 Mac을 잠자기 상태로 전환하거나 종료하는 타이머를 실행합니다. 카운트다운은 메뉴 막대에 계속 표시되며, 창은 언제든지 다시 열 수 있습니다.",
            version: "버전",
            presetMinutesFormat: "%d분",
            willStartInFormat: "%d분 후 실행",
            sleepingIn: "잠자기까지…",
            shuttingDownIn: "종료까지…"
        ),
        .sr: Table(
            sleep: "Spavanje",
            shutdown: "Gašenje",
            manualLabel: "Vreme (min)",
            manualToggle: "Ručno",
            placeholder: "npr. 25",
            minuteUnit: "min",
            startTimer: "Pokreni tajmer",
            cancel: "Otkaži",
            quitApp: "Ugasi program",
            preparing: "Priprema…",
            okButton: "OK",
            automationDeniedTitle: "Dozvola je potrebna",
            automationDeniedBody: "Bez Automation dozvole shutdown tajmer ne može da pošalje sistemski zahtev za gašenje. Dozvolu možete odobriti u System Settings > Privacy & Security > Automation.",
            sleepUnavailableTitle: "Spavanje nije uspelo",
            sleepUnavailableBody: "Sistemski sleep zahtev nije prošao. Proverite da li je macOS dozvolio ovu akciju.",
            shutdownUnavailableTitle: "Gašenje nije uspelo",
            shutdownUnavailableBody: "Sistemski shutdown zahtev nije prošao. Proverite da li je build potpisan sa odgovarajućim entitlement-om i da li je macOS dozvolio ovu akciju.",
            aboutTitle: "O aplikaciji",
            aboutBody: "Easy Sleep & Shutdown pokreće tajmer koji uspavljuje ili gasi Mac nakon odabranog vremena. Odbrojavanje ostaje vidljivo u traci menija, a prozor možete ponovo otvoriti u bilo kom trenutku.",
            version: "Verzija",
            presetMinutesFormat: "%d min",
            willStartInFormat: "Aktiviraće se za %d min",
            sleepingIn: "Uspavljuje se za…",
            shuttingDownIn: "Gasi se za…"
        )
    ]

    private static var currentLanguage: Language {
        Language.resolve()
    }

    private static var current: Table {
        tables[currentLanguage] ?? tables[.en]!
    }

    static let appTitle = appName
    static let menuBarAccessibilityDescription = appName

    static var sleep: String { current.sleep }
    static var shutdown: String { current.shutdown }
    static var manualLabel: String { current.manualLabel }
    static var manualToggle: String { current.manualToggle }
    static var placeholder: String { current.placeholder }
    static var minuteUnit: String { current.minuteUnit }
    static var startTimer: String { current.startTimer }
    static var cancel: String { current.cancel }
    static var quitApp: String { current.quitApp }
    static var preparing: String { current.preparing }
    static var okButton: String { current.okButton }
    static var automationDeniedTitle: String { current.automationDeniedTitle }
    static var automationDeniedBody: String { current.automationDeniedBody }
    static var sleepUnavailableTitle: String { current.sleepUnavailableTitle }
    static var sleepUnavailableBody: String { current.sleepUnavailableBody }
    static var shutdownUnavailableTitle: String { current.shutdownUnavailableTitle }
    static var shutdownUnavailableBody: String { current.shutdownUnavailableBody }
    static var aboutTitle: String { current.aboutTitle }
    static var aboutBody: String { current.aboutBody }
    static var version: String { current.version }

    static func presetMinutes(_ minutes: Int) -> String {
        String(format: current.presetMinutesFormat, locale: Locale.current, minutes)
    }

    static func willStartIn(_ minutes: Int) -> String {
        String(format: current.willStartInFormat, locale: Locale.current, minutes)
    }

    static func sleepingIn(_ action: SleepAction) -> String {
        switch action {
        case .sleep:
            return current.sleepingIn
        case .shutdown:
            return current.shuttingDownIn
        }
    }
}
