# security_plus

This is a Dart/Flutter plugin to know if the device security has been breached or not. For example it will let you know if the user rooted his device or not.

Please Note: [isRooted] and [isJailBroken] are both async functions which returns a boolean use them wisely.

## install:
```YAML
dependencies:
   security_plus: ^2.0.2
```
### Android
 1. Add the following to your AndroidManifest.xml file:
```XML
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```
### IOS
 1. Add the following to your Info.plist file:
```XML
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

## use:

```dart

// You could use [isRooted] to check if the android device is rooted or not 
  SecurityPlus.isRooted

// You could use [isJailBroken] to check if the IOS device is jail broken or not 
  SecurityPlus.isJailBroken

// You could use [isOnExternalStorage] to check if the Android device is running your app on external storage or not 
  SecurityPlus.isOnExternalStorage

// You could use [isEmulator] to check if the Android device is Emulator or not 
  SecurityPlus.isEmulator

// You could use [isDevelopmentModeEnable] to check if the Android device is in Development mode or not 
  SecurityPlus.isDevelopmentModeEnable

// You could use [isMockLocationEnabled] to check if the Android device is using a mock location method or not 
  SecurityPlus.isMockLocationEnabled
```

## Future Work

 - Adding SSL pinning (DIO)
 - Adding SSL pinning (HTTP)
 - Adding Mobile data detection

## Credits

Thanks to [abu](https://github.com/abu0306) for creating flutter_root_jailbreak which was the inspiration for this plugin. Also thanks for [MazenEmara](https://github.com/MazenEmara) for contributing to this project and being part of the team.