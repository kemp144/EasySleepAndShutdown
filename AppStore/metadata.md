# App Store Connect — Easy Sleep & Shutdown

## App Name
Easy Sleep & Shutdown

## Subtitle (max 30 chars)
Sleep or shut down on a timer

## Description
Easy Sleep & Shutdown is a lightweight menu bar utility that puts your Mac to sleep or shuts it down after a delay you choose — without leaving anything running on your screen.

Set a timer for 5, 10, 15, 20, 30, 45, 60, 90, or 120 minutes, or type any custom duration. Then press Start and go. The app disappears from view and counts down silently in the menu bar. One minute before the action fires, you get an alert giving you the chance to cancel.

**How it works:**
- Click the menu bar icon to set Sleep or Shutdown and choose a delay
- Press Start — the popover closes, the countdown appears in the menu bar
- Click the icon again at any time to see how much time is left or cancel
- One minute before the action, an alert lets you confirm or cancel

**Designed for minimal interruption:**
- No Dock icon
- No main window
- No background services
- Zero configuration

Perfect for when you're watching a video, rendering something, or just want the Mac to sleep after you leave the room.

## Promotional Text (max 170 chars)
Put your Mac to sleep or shut it down automatically — set a timer from the menu bar and walk away. Simple, silent, zero clutter.

## Keywords (max 100 chars total)
sleep,shutdown,timer,menu bar,power,utility,schedule,auto sleep,countdown,menubar

## Support URL
https://your-website.com/support   ← replace with real URL

## Marketing URL (optional)
https://your-website.com           ← replace with real URL

## Privacy Policy URL (REQUIRED for App Store)
https://your-website.com/privacy   ← MUST be a real public URL before submission
Note: Even though the app collects no data, Apple requires a privacy policy URL.

## Age Rating
4+  (no objectionable content, no data collection)

## Category
Primary:   Utilities
Secondary: Productivity

## Copyright
© 2025 Easy Sleep & Shutdown. All rights reserved.

---

## Screenshot Plan (Mac App Store — 1280×800 or 1440×900)

| # | Scene | Caption idea |
|---|-------|--------------|
| 1 | Menu bar icon + popover open (Sleep selected, 15 min) | "Set a sleep timer in seconds" |
| 2 | Dropdown open showing all time options (5–120 min) | "Choose from presets or type any duration" |
| 3 | Custom input field with e.g. 25 min typed | "Need a custom time? Just type it." |
| 4 | Shutdown selected, 30 min, Start button highlighted | "Sleep or Shutdown — your choice" |
| 5 | Menu bar showing "💤 12:34" countdown | "Counts down silently in the menu bar" |
| 6 | Popover reopened during active timer (cancel view) | "Changed your mind? Cancel anytime." |
| 7 | 1-minute warning alert | "Get a heads-up one minute before it fires" |
| 8 | About panel open | "Lightweight. No Dock icon. No clutter." |

---

## App Review Notes

**How to test the app:**

1. Launch the app — it appears only in the menu bar (no Dock icon, no window).
2. Click the menu bar icon (powersleep symbol).
3. Select "Sleep" or "Shutdown" using the segmented control.
4. Choose a delay (e.g., 5 minutes) from the dropdown, or toggle "Custom" and type a number.
5. Press "Start Timer" — the popover closes and the menu bar shows a countdown (e.g., 💤 04:58).
6. To test cancellation: click the icon again, then press "Cancel".
7. To test the 1-minute warning: set a 1 or 2 minute timer and wait.

**Regarding Sleep and Shutdown:**
The app uses NSAppleScript to send Apple Events to System Events
(tell application "System Events" to sleep / shut down).
This requires the `com.apple.security.temporary-exception.apple-events` entitlement
targeting `com.apple.systemevents`, which is included in the entitlements file.
macOS will show a standard system password/permission prompt if required.

**Note for reviewers:** To test without actually sleeping/shutting down the review machine,
you may set a short timer and cancel it before it fires. The action only executes at t=0.

---

## Privacy Policy (minimum required content — host this at a public URL)

**Easy Sleep & Shutdown — Privacy Policy**

Easy Sleep & Shutdown does not collect, store, transmit, or share any personal data or usage information. The app operates entirely on-device. No analytics, no tracking, no network requests.

Contact: your-email@domain.com
