# Xcode Setup for Mac App Store Submission

## 1. Open project in Xcode
```
open /Users/robertengel/GIT/EasySleepAndShutdown/Package.swift
```
Xcode will open the Swift Package. Let it resolve.

## 2. Signing & Capabilities
- Select the `EasySleepShutdown` scheme → Edit Scheme → Run → Info: set Build Config to Release
- Click the project in navigator → target `EasySleepShutdown`
- **Signing & Capabilities tab:**
  - Team: select your Apple Developer account
  - Bundle Identifier: `com.easysleepshutdown.app`  ← change to your own unique ID
  - Enable "Automatically manage signing"
  - Click "+ Capability" → add **App Sandbox**
  - Under App Sandbox, enable NO additional checkboxes (the apple-events exception is in the .entitlements file)

## 3. Link the entitlements file
- Build Settings → search "Code Signing Entitlements"
- Set value to: `EasySleepShutdown.entitlements`

## 4. App Icon
- Create an asset catalog: File → New → Asset Catalog → name it `Assets.xcassets`
- Add an `AppIcon` image set with all required macOS sizes:
  - 16x16 @1x, @2x
  - 32x32 @1x, @2x
  - 128x128 @1x, @2x
  - 256x256 @1x, @2x
  - 512x512 @1x, @2x
- Move `Assets.xcassets` into `Sources/EasySleepShutdown/`
- OR use a tool: https://www.appicon.co — upload a 1024x1024 PNG, download macOS set

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
- [ ] App Store Connect: App record created
- [ ] App Store Connect: All metadata filled (name, subtitle, description, keywords)
- [ ] App Store Connect: Screenshots uploaded for Mac (1280×800 or 1440×900)
- [ ] App Store Connect: Privacy Policy URL live and accessible
- [ ] App Store Connect: Build uploaded and processed
- [ ] TestFlight: Test internally — confirm sleep action works, cancel works, 1-min alert works
- [ ] Submit for Review: Add App Review Notes explaining NSAppleScript usage
