# EasySleepAndShutdown

A simple tool for scheduling sleep and shutdown operations on your computer.

## Features

- Easy scheduling of sleep/shutdown timers
- Simple and intuitive interface

## Getting Started

_Documentation coming soon._

## License

MIT


# todo
# App Store todo

0. [x] Apple Developer Program aktivan
1. [x] App Store Connect: napravi novi app record za macOS app
2. [ x] Napravi app ikonu (1024×1024 PNG, pa AppIcon set)
3. [x] Otvori projekat u Xcode-u (`EasySleepAndShutdown.xcodeproj`; fallback je `Package.swift` samo za lokalni dev)
4. [x] Postavi Bundle ID, Team, version 1.0.0, build 1
5. [x] Uključi App Sandbox i poveži EasySleepShutdown.entitlements
6. [ ] Proveri signing + Release build
7. [ ] Product → Archive
8. [ ] Distribute App → App Store Connect → Upload
9. [ ] App Store Connect: izaberi uploaded build za ovu verziju
10. [ ] Popuni metadata iz AppStore/metadata.md
11. [ ] Dodaj screenshots
12. [ ] Popuni App Privacy questionnaire
13. [ ] Postavi Privacy Policy URL
14. [ ] Podesi price/tax category + availability
15. [ ] Age rating proveri / potvrdi
16. [ ] TestFlight: interni test
17. [ ] Submit for Review + App Review Notes iz metadata.md

## Xcode project

Za App Store korake koristi generisani Xcode projekat, ne sirovi Swift Package prikaz:

```bash
brew install xcodegen
./generate-xcodeproj.sh
open EasySleepAndShutdown.xcodeproj
```
