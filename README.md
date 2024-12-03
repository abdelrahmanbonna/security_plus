# Security Plus

A comprehensive Flutter security plugin that provides advanced security features for your Flutter applications, including root detection, emulator detection, and various security checks.

[![pub package](https://img.shields.io/pub/v/security_plus.svg)](https://pub.dev/packages/security_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🛡️ **Advanced Root Detection**
  - Multiple detection layers
  - Frida anti-tampering protection
  - Magisk detection
  - SuperSU detection
  - Common root app detection

- 📱 **Emulator Detection**
  - Comprehensive emulator environment checks
  - Build properties analysis
  - Hardware characteristics verification

- 🔒 **Security Checks**
  - Development mode detection
  - Mock location detection
  - External storage checks
  - Runtime integrity verification
  - System tampering detection

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  security_plus: ^3.0.0
```

## Platform Setup

### Android

1.Add the following permissions to your AndroidManifest.xml file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

2.Add permission_handler for runtime permission management:

```yaml
dependencies:
  permission_handler: ^10.4.3
```

### iOS

Add the following to your Info.plist file:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to verify device security.</string>
```

## Usage

### Import the package

```dart
import 'package:security_plus/security_plus.dart';
import 'package:permission_handler/permission_handler.dart';
```

### Handle Permissions and Security Checks

```dart
Future<void> checkDeviceSecurity() async {
  // Request location permission first
  if (Platform.isAndroid) {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      // Handle permission denied
      return;
    }
  }

  // Perform security checks
  try {
    final isRooted = await SecurityPlus.isRooted;
    final isEmulator = await SecurityPlus.isEmulator;
    final isDevelopmentMode = await SecurityPlus.isDevelopmentModeEnable;
    final isMockLocation = await SecurityPlus.isMockLocationEnabled;
    final isExternalStorage = await SecurityPlus.isOnExternalStorage;

    // Handle security check results
    if (isRooted || isEmulator || isMockLocation) {
      // Handle security risks
    }
  } catch (e) {
    // Handle errors
  }
}
```

### Individual Security Checks

#### Root Detection

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

#### Emulator Detection

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

#### Development Mode Check

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

#### Mock Location Check

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

#### External Storage Check

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

## Security Features

### Root Detection Mechanisms

The plugin employs multiple layers of root detection:

1. **RootBeer Integration**: Uses the advanced RootBeer library for base root detection
2. **Frida Detection**: Actively searches for Frida-related processes and libraries
3. **File System Checks**: Scans for common root-related files and directories
4. **Package Analysis**: Detects known root management applications
5. **Runtime Integrity**: Checks for system modifications and hooks

### Anti-Tampering Protection

- Process monitoring for known tampering tools
- Library injection detection
- System property verification
- Runtime integrity checks

## Example

Check out the [example](example) directory for a complete sample application demonstrating all features.

## Platform Support

| Android | iOS |
|:-------:|:---:|
|    ✅    |  🚧  |

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created and maintained by [Abdelrahman Bonna](https://github.com/abdelrahmanbonna).

## Acknowledgments

- [RootBeer](https://github.com/scottyab/rootbeer) - For root detection capabilities
- The Flutter team and community for their amazing work

## Disclaimer

This plugin provides security features but should not be considered as the sole security measure for your application. Always implement multiple layers of security and keep your security measures up to date.
