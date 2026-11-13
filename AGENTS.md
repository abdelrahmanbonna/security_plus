# AGENTS.md — security_plus

Quick reference for AI assistants working on this repo. Read this first instead of exploring the codebase.

## What it is
Flutter plugin (pub.dev: `security_plus`, v4.1.0) that reports device security signals to Dart as `bool`s:
root (Android), jailbreak (iOS), emulator, developer mode, app on external storage, mock location.

- Android: Kotlin, package `com.absolutions.security_plus`
- iOS: Swift, **Swift Package Manager only** (no podspec, removed on purpose; don't add it back)
- Constraints: Dart `^3.11.0`, Flutter `>=3.41.0`. CI uses Flutter 3.41.6.

## Architecture (one MethodChannel, no federation)
```
lib/security_plus.dart          SecurityPlus (static getters) ──MethodChannel('security_plus')──┐
android/.../SecurityPlusPlugin.kt   onMethodCall `when` switch  ◄──────────────────────────────┤
ios/security_plus/Sources/security_plus/SecurityPlusPlugin.swift  handle(_:result:)  ◄───────────┘
```
- No platform interface or federated packages. `plugin_platform_interface` is in pubspec but **unused**.
- Each Dart getter calls `_channel.invokeMethod('<name>')` and casts the result to `bool`.
- Errors are not handled in Dart. `PlatformException` reaches the caller (the tests rely on this).

## Method contract
| Channel method | Dart getter | Android | iOS |
|---|---|---|---|
| `isRooted` | `SecurityPlus.isRooted` | ✅ RootBeer + Frida libs (`/proc/self/maps`) + Frida/Magisk procs (`ps`) + su paths | ❌ `notImplemented` |
| `isJailBroken` | `SecurityPlus.isJailBroken` | ❌ `notImplemented` | ✅ `cydia://` canOpenURL OR writable `/private/jailbreak.txt` |
| `isEmulator` | `SecurityPlus.isEmulator` | ✅ `Build.*` heuristics | ✅ `#if targetEnvironment(simulator)` |
| `isDevelopmentModeEnable` | `SecurityPlus.isDevelopmentModeEnable` | ✅ `Settings.Global.DEVELOPMENT_SETTINGS_ENABLED` | ❌ `notImplemented` (no public iOS API for Developer Mode) |
| `isMockLocationEnabled` | `SecurityPlus.isMockLocationEnabled` | ✅ AppOps `OPSTR_MOCK_LOCATION` + `Location.isFromMockProvider` (needs location permission) | ❌ `notImplemented` |
| `isOnExternalStorage` | `SecurityPlus.isOnExternalStorage` | ✅ `FLAG_EXTERNAL_STORAGE` / filesDir path | ❌ `notImplemented` |

Unsupported methods reply `notImplemented` on both platforms, which throws `MissingPluginException` in Dart. iOS `handle()` is a `switch` with a `default: result(FlutterMethodNotImplemented)`; keep that default so every call gets a reply.

## Adding or changing a check (do all of these)
1. `lib/security_plus.dart`: add a `static Future<bool> get xxx` that calls `invokeMethod('xxx')`. Add a doc comment saying which platforms support it.
2. Android `SecurityPlusPlugin.kt`: add a `"xxx" -> result.success(xxx())` branch to `onMethodCall`.
3. iOS `SecurityPlusPlugin.swift`: add a `case "xxx":` to the `switch` in `handle()`, or leave it to the `default` (`notImplemented`).
4. `test/security_plus_test.dart`: add a key to `mockResponses` in `setUp`, and a group with true/false/`PlatformException` tests (copy an existing group).
5. `example/lib/main.dart`: add state, call it, and show it. Gate platform-only checks with `Platform.isAndroid`.
6. `README.md` (usage + platform table), `CHANGELOG.md` (new top entry), `SECURITY.md` ("Latest" section).
7. If you add Android permissions: update `android/src/main/AndroidManifest.xml` and the README setup section.

## Releasing (version bump checklist)
Change the version in all of these places: `pubspec.yaml` `version:`, the top entry of `CHANGELOG.md`, the `SECURITY.md` "Version X (Latest)" heading, and the README install snippet (`security_plus: ^X`). Then run `flutter pub publish --dry-run` from a clean git tree.

## File map
| Path | Notes |
|---|---|
| `lib/security_plus.dart` | The whole public Dart API (one class, about 50 lines) |
| `android/build.gradle` | Groovy. AGP 8.7.0, Kotlin 1.9.22, compileSdk/targetSdk 35, minSdk 16, Java 11, NDK r26b, dependency `com.scottyab:rootbeer-lib:0.1.1` |
| `android/src/main/kotlin/.../SecurityPlusPlugin.kt` | All Android logic. Several private helpers are **unused** (`isDebuggerAttached`, `checkSuPaths`, `detectHooks`, `isSuperuserAppInstalled`, `isRunningInAPKMode`) |
| `android/src/main/AndroidManifest.xml` | FINE/COARSE/MOCK location permissions. Still has the legacy `package=` attribute and `<uses-sdk>` |
| `android/src/test/.../SecurityPlusPluginTest.kt` | Robolectric + Mockito, uses reflection on private methods. ⚠️ Robolectric/JUnit4 are **not** declared in `build.gradle`, and `useJUnitPlatform()` is set, so these tests probably don't compile or run as-is |
| `android/bin/` | ⚠️ Stale Eclipse/Buildship duplicate of `android/`, **tracked in git and shipped to pub.dev**. Never edit it; remove it and gitignore it if asked to clean up |
| `ios/security_plus/Package.swift` | swift-tools 5.9, iOS 12, depends on `FlutterFramework` (`path: "../FlutterFramework"`), products `security_plus` and `security-plus` |
| `ios/security_plus/Sources/security_plus/SecurityPlusPlugin.swift` | All iOS logic. Uses `import Flutter` |
| `ios/Assets/.gitkeep` | Leftover from the CocoaPods layout, unused |
| `test/security_plus_test.dart` | 20 Dart tests that mock the channel via `TestDefaultBinaryMessengerBinding` |
| `test/security_plus_test.mocks.dart` | Generated by mockito `@GenerateMocks([MethodChannel])`, **unused** by the tests. Regenerate with `dart run build_runner build` if needed |
| `example/` | Demo app using `permission_handler` (asks for location on Android) |
| `example/test/widget_test.dart` | ⚠️ **Fails**: it looks for template text `'Running on:'` that the app doesn't render |
| `.github/workflows/dart.yml` | Runs on push/PR to `main`: `flutter pub get` → `dart analyze` → `flutter test` (root package only) |
| `pubspec.yaml` | Plugin platforms: android (`package` + `pluginClass`), ios (`pluginClass`). Don't add a `swiftPackageManager:` key; Flutter finds `ios/security_plus/Package.swift` by folder convention |

## Commands
```bash
flutter test                          # root Dart unit tests (expected: +20 all pass)
flutter analyze                       # expect only example 'material.dart deprecated' infos
flutter pub publish --dry-run         # needs a clean git tree
cd example && flutter test            # currently fails (see above)
cd example && flutter build ios --no-codesign   # macOS only, SPM must be enabled
```
Gotchas:
- `flutter test` / `pub get` may auto-add an `analyzer: exclude:` block to `analysis_options.yaml` and `example/analysis_options.yaml`. Revert or commit that change on purpose.
- On Windows, if Android Studio's Dart process is running, Flutter's SDK self-update fails with "file in use". Close the IDE first.

## Conventions
- Keep the static-getter API style and channel name `security_plus`. Method names are a public contract shared by Dart, Kotlin and Swift. Renaming one means changing all three plus the tests.
- Native checks return plain `Boolean`/`Bool` and swallow exceptions (return `false`). Keep this best-effort behavior.
- Don't reintroduce CocoaPods. Changing the minimum Flutter/Dart version needs a CHANGELOG note.
