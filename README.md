# Security Plus

A Flutter security plugin that detects risky device environments: root (Android), jailbreak (iOS), emulators, developer mode, mock location and apps installed on external storage.

[![pub package](https://img.shields.io/pub/v/security_plus.svg)](https://pub.dev/packages/security_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🛡️ **Root Detection (Android)**
  - [RootBeer](https://github.com/scottyab/rootbeer) base checks (su binaries, root management apps, dangerous props, busybox, …)
  - Frida detection: injected Frida libraries in `/proc/self/maps` and running Frida processes
  - Magisk detection: running `magisk` / `magiskd` processes
  - SuperSU / `su` binary detection in common system paths

- 🍎 **Jailbreak Detection (iOS)**
  - Cydia URL scheme check
  - Sandbox integrity check (tries to write outside the app sandbox)

- 📱 **Emulator / Simulator Detection**
  - Android: build properties analysis (`FINGERPRINT`, `MODEL`, `MANUFACTURER`, `BRAND`, `DEVICE`, `PRODUCT`)
  - iOS: iOS Simulator detection

- 🔒 **Other Security Checks (Android)**
  - Developer options (development mode) detection
  - Mock location detection
  - App installed on external storage detection

## Platform Support

| Check | Dart API | Android | iOS |
|---|---|:---:|:---:|
| Root | `SecurityPlus.isRooted` | ✅ | ❌ |
| Jailbreak | `SecurityPlus.isJailBroken` | ❌ | ✅ |
| Emulator / Simulator | `SecurityPlus.isEmulator` | ✅ | ✅ |
| Development mode | `SecurityPlus.isDevelopmentModeEnable` | ✅ | ❌ |
| Mock location | `SecurityPlus.isMockLocationEnabled` | ✅ | ❌ |
| External storage | `SecurityPlus.isOnExternalStorage` | ✅ | ❌ |

> [!WARNING]
> Calling a check on a platform that doesn't support it throws a `MissingPluginException`. Check `Platform.isAndroid` / `Platform.isIOS` from `dart:io` first.

## Requirements

| | Minimum |
|---|---|
| Flutter | 3.41.0 |
| Dart | 3.11.0 |
| Android | minSdk 16 (compileSdk / targetSdk 35) |
| iOS | 12.0, **Swift Package Manager only** |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  security_plus: ^4.1.0
```

## Platform Setup

### Android

1. **Permissions.** The plugin's manifest already declares these permissions, and they are merged into your app automatically:

   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_MOCK_LOCATION"/>
   ```

2. **Runtime location permission.** `isMockLocationEnabled` reads the last known location, so request location permission at runtime before calling it, for example with [permission_handler](https://pub.dev/packages/permission_handler):

   ```yaml
   dependencies:
     permission_handler: ^11.4.0
   ```

   The other Android checks don't need any runtime permission.

### iOS

This plugin is distributed for iOS via **Swift Package Manager only** (no CocoaPods podspec). Make sure Swift Package Manager is enabled for your Flutter project:

```bash
flutter config --enable-swift-package-manager
```

> [!NOTE]
> Apps that still build with CocoaPods only (Swift Package Manager disabled) can't build this plugin on iOS.

For the Cydia check in `isJailBroken` to work, list the `cydia` URL scheme in your `ios/Runner/Info.plist`. Without it, iOS always reports the scheme as unavailable, and only the sandbox check runs:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>cydia</string>
</array>
```

No location permission is needed on iOS for this plugin. Add `NSLocationWhenInUseUsageDescription` only if your app requests location itself.

## Usage

### Import the package

```dart
import 'dart:io';

import 'package:security_plus/security_plus.dart';
import 'package:permission_handler/permission_handler.dart';
```

### Handle Permissions and Security Checks

```dart
Future<void> checkDeviceSecurity() async {
  try {
    // Supported on both Android and iOS.
    final isEmulator = await SecurityPlus.isEmulator;

    if (Platform.isAndroid) {
      final isRooted = await SecurityPlus.isRooted;
      final isDevelopmentMode = await SecurityPlus.isDevelopmentModeEnable;
      final isExternalStorage = await SecurityPlus.isOnExternalStorage;

      // Mock location detection needs the location permission.
      final status = await Permission.location.request();
      final isMockLocation =
          status.isGranted && await SecurityPlus.isMockLocationEnabled;

      if (isRooted || isEmulator || isMockLocation) {
        // Handle security risks
      }
    } else if (Platform.isIOS) {
      final isJailBroken = await SecurityPlus.isJailBroken;

      if (isJailBroken || isEmulator) {
        // Handle security risks
      }
    }
  } on PlatformException catch (e) {
    // Native side reported an error (import 'package:flutter/services.dart')
  }
}
```

### Individual Security Checks

#### Root Detection (Android)

```dart
try {
  bool isRooted = await SecurityPlus.isRooted;
  if (isRooted) {
    // Handle rooted device
  }
} catch (e) {
  // Handle errors
}
```

#### Jailbreak Detection (iOS)

```dart
try {
  bool isJailBroken = await SecurityPlus.isJailBroken;
  if (isJailBroken) {
    // Handle jailbroken device
  }
} catch (e) {
  // Handle errors
}
```

#### Emulator / Simulator Detection (Android and iOS)

```dart
try {
  bool isEmulator = await SecurityPlus.isEmulator;
  if (isEmulator) {
    // Handle emulator detection
  }
} catch (e) {
  // Handle errors
}
```

#### Development Mode Check (Android)

Returns `true` when **Developer options** are enabled on the device.

```dart
try {
  bool isDevelopmentMode = await SecurityPlus.isDevelopmentModeEnable;
  if (isDevelopmentMode) {
    // Handle development mode
  }
} catch (e) {
  // Handle errors
}
```

#### Mock Location Check (Android)

Request location permission first (see [Platform Setup](#android)).

```dart
try {
  bool isMockLocation = await SecurityPlus.isMockLocationEnabled;
  if (isMockLocation) {
    // Handle mock location
  }
} catch (e) {
  // Handle errors
}
```

#### External Storage Check (Android)

Returns `true` when the app is installed on external storage (for example, an SD card).

```dart
try {
  bool isOnExternalStorage = await SecurityPlus.isOnExternalStorage;
  if (isOnExternalStorage) {
    // Handle external storage detection
  }
} catch (e) {
  // Handle errors
}
```

## How the checks work

All checks are best-effort heuristics. Native code catches its own errors and returns `false` when a check can't run.

### Root detection (Android)

`isRooted` returns `true` if any of these layers detects root:

1. **RootBeer**: the [RootBeer](https://github.com/scottyab/rootbeer) library's checks
2. **Frida libraries**: Frida agent/gadget libraries mapped into the app process (`/proc/self/maps`)
3. **Tampering processes**: running `frida`, `frida-server`, `frida-helper`, `frida-agent`, `magisk` or `magiskd` processes
4. **Root files**: `su` binaries and SuperSU / Superuser files in common system paths

### Jailbreak detection (iOS)

`isJailBroken` returns `true` if the device can open the `cydia://` URL scheme, or if the app can write to `/private/`, which is outside the app sandbox.

### Emulator / Simulator detection

- **Android:** `isEmulator` matches known emulator values in `android.os.Build` (for example, `generic` fingerprints, `google_sdk` / `sdk_` models and Genymotion).
- **iOS:** `isEmulator` returns `true` when the app runs in the iOS Simulator. This is a compile-time check (`targetEnvironment(simulator)`), so it is exact and uses no private API. It returns `false` on real devices, including iOS apps running on Apple silicon Macs.

### Mock location (Android)

`isMockLocationEnabled` checks whether this app is allowed to provide mock locations (AppOps on Android 6.0+, or the developer setting on older versions). It also checks whether the last known GPS or network location came from a mock provider.

## Example

Check out the [example](example) directory for a complete sample application demonstrating all features.

## Migrating to 4.x

- **4.0.0** moved iOS to Swift Package Manager and dropped CocoaPods support.
- **4.1.0** requires Flutter 3.41.0 / Dart 3.11.0 and adds the `FlutterFramework` Swift package dependency required by newer Flutter versions.

See the [CHANGELOG](CHANGELOG.md) for details.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue.

Before opening a pull request, run:

```bash
flutter analyze
flutter test
```

AI coding assistants should read [AGENTS.md](AGENTS.md) for the plugin's architecture and conventions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created and maintained by [Abdelrahman Bonna](https://github.com/abdelrahmanbonna).

## Acknowledgments

- [RootBeer](https://github.com/scottyab/rootbeer) - For root detection capabilities
- The Flutter team and community for their amazing work

## Disclaimer

This plugin provides security features but should not be considered as the sole security measure for your application. Always implement multiple layers of security and keep your security measures up to date.
