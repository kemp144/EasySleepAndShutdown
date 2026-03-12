# App Review Notes

## Core behavior

Easy Sleep & Shutdown is a macOS utility that lets the user schedule either Sleep or Shutdown after a chosen delay.

- Sleep uses macOS power management APIs.
- Shutdown is only triggered after the user explicitly selects `Shutdown` and starts the timer.
- When the user starts a shutdown timer, macOS may display the standard Automation permission prompt. The app uses this permission only to send the system shutdown request requested by the user.

## How to test

1. Launch the app.
2. Verify the main window opens and the menu bar icon appears.
3. Select either `Sleep` or `Shutdown`.
4. Pick a preset delay or enable the custom duration toggle and enter a value.
5. Click `Start Timer`.
6. Reopen the app from the menu bar icon and click `Cancel` to confirm cancellation works.

## Reviewer-safe path

To avoid actually sleeping or shutting down the review machine:

1. Start a short timer.
2. Confirm the countdown appears in the menu bar.
3. Reopen the window from the menu bar.
4. Click `Cancel` before the timer reaches zero.

## Permission explanation

The `NSAppleEventsUsageDescription` prompt is shown only for the Shutdown flow. It is required because the app sends the system shutdown Apple Event after the user explicitly asks for Shutdown.

## Important note

The app does not collect user data, does not require sign-in, and does not perform background network activity.
