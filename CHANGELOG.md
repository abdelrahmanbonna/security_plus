# Unreleased

## Changes

- `isEmulator` now works on iOS: returns `true` when running in the iOS Simulator.
- Fixed: on iOS, calling an unsupported check (`isRooted`, `isDevelopmentModeEnable`, `isMockLocationEnabled`, `isOnExternalStorage`) never completed. It now throws `MissingPluginException`, like unsupported checks on Android.

# 4.1.0

## Changes

- Added the `FlutterFramework` dependency to `Package.swift` (required by future Flutter versions).
- Raised minimum Flutter version to 3.41.0 and Dart SDK to 3.11.0.

# 4.0.0

## New Features

- Added support for iOS SPMs
- Upgrading to latest flutter and dart sdk
