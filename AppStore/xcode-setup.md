# Xcode Setup for Mac App Store Submission

## 1. Generate and open the Xcode project
If `xcodegen` is installed:
```
cd /Users/robertengel/GIT/EasySleepAndShutdown
./generate-xcodeproj.sh
open EasySleepAndShutdown.xcodeproj
```

If `xcodegen` is not installed yet:
```
brew install xcodegen
cd /Users/robertengel/GIT/EasySleepAndShutdown
./generate-xcodeproj.sh
open EasySleepAndShutdown.xcodeproj
```

Fallback for local development only:
```
open /Users/robertengel/GIT/EasySleepAndShutdown/Package.swift
```
Use the generated `.xcodeproj` for signing, archive, and App Store submission.

## 2. Signing & Capabilities
- Select the `EasySleepShutdown` scheme → Edit Scheme → Run → Info: set Build Config to Release
- Click the project in navigator → target `EasySleepShutdown`
- **Signing & Capabilities tab:**
  - Team: select your Apple Developer account
  - Bundle Identifier: `com.easysleepshutdown.app`  ← change to your own unique ID
  - Enable "Automatically manage signing"
  - Click "+ Capability" → add **App Sandbox**
  - Under App Sandbox, keep the standard sandbox enabled and do not add temporary exception entitlements
- Debug and Release should both stay sandboxed so the script-based setup flow matches the App Store build

## 3. Link the entitlements file
- Build Settings → search "Code Signing Entitlements"
- `Debug` should point to: `EasySleepShutdown.Debug.entitlements`
- `Release` should point to: `EasySleepShutdown.entitlements`
- The generated project already sets these values, but verify them once in Xcode

## 4. App Icon
- `Assets.xcassets` is already present in the repo
- Verify that `AppIcon` is selected and there are no missing macOS icon slots

## 5. Version & Build
- CFBundleShortVersionString: `1.0.0`  (display version, e.g., 1.0.0)
- CFBundleVersion: `1`                 (build number, increment each upload)

## 6. Archive & Upload
```
Product → Archive
```
After archive:
1. Distribute App → App Store Connect → Upload
2. Wait for processing (~5-15 min)
3. In App Store Connect → TestFlight: add internal testers first

## 7. App Store Connect setup
1. Create new app at appstoreconnect.apple.com
2. Bundle ID: same as above (`com.easysleepshutdown.app`)
3. Fill in all fields from `metadata.md`
4. Upload screenshots (see screenshot plan in metadata.md)
   Final prepared files live in `AppStore/screenshots`
5. Set Privacy Policy URL (required — even with no data collection)
6. Age Rating: answer all questions as "None" → results in 4+
7. Pricing: Free or paid — your choice

---

## Final Submission Checklist

- [ ] Xcode: Build succeeds with Release config and no warnings
- [ ] Xcode: Archive created successfully (Product → Archive)
- [ ] Xcode: Entitlements file linked in Build Settings
- [ ] Xcode: App Sandbox capability enabled
- [ ] Xcode: App icon all sizes present (no missing slots)
- [ ] Xcode: Bundle identifier is unique and registered in developer portal
- [ ] Xcode: Version 1.0.0 / Build 1 set
- [ ] Xcode: Generated `.xcodeproj` opened instead of the raw Swift Package for App Store work
- [ ] App Store Connect: App record created
- [ ] App Store Connect: All metadata filled (name, subtitle, description, keywords)
- [ ] App Store Connect: Screenshots uploaded for Mac (1280×800 or 1440×900)
- [ ] App Store Connect: Privacy Policy URL live and accessible
- [ ] App Store Connect: Build uploaded and processed
- [ ] TestFlight: Test internally — confirm sleep action works, cancel works, 1-min alert works
- [ ] TestFlight: Confirm the exported `SystemActions.scpt` script works after the user moves it into the Application Scripts folder
- [ ] Submit for Review: Add App Review Notes explaining the one-time user-installed script setup and `NSUserAppleScriptTask` execution flow
