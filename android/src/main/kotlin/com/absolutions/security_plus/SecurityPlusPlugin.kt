package com.absolutions.security_plus

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import com.scottyab.rootbeer.RootBeer

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SecurityPlusPlugin */
class SecurityPlusPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "security_plus")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "isRooted") {
      val rootBeer = RootBeer(context)
      result.success(rootBeer.isRooted)
    }else if (call.method.equals("isEmulator")) {
      result.success(isEmulator());
    }else if (call.method.equals("isOnExternalStorage")) {
      result.success(isOnExternalStorage(context));
    }else if(call.method.equals("isDevelopmentModeEnable"))  {
      result.success(developmentModeCheck(context));
    }else {
      result.notImplemented();
    }
  }

  private fun isEmulator(): Boolean {
    return (Build.FINGERPRINT.startsWith("generic")
            || Build.FINGERPRINT.startsWith("unknown")
            || Build.MODEL.contains("google_sdk")
            || Build.MODEL.contains("Emulator")
            || Build.MODEL.contains("Android SDK built for x86")
            || Build.MANUFACTURER.contains("Genymotion")
            || Build.MODEL.startsWith("sdk_")
            || Build.DEVICE.startsWith("emulator")) || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith(
      "generic"
    ) || "google_sdk" == Build.PRODUCT
  }

  private fun developmentModeCheck(context: Context): Boolean {
    return if (Integer.valueOf(Build.VERSION.SDK_INT) == 16) {
      android.provider.Settings.Secure.getInt(
        context.getContentResolver(),
        android.provider.Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED, 0
      ) !== 0
    } else if (Integer.valueOf(Build.VERSION.SDK_INT) >= 17) {
      android.provider.Settings.Secure.getInt(
        context.getContentResolver(),
        android.provider.Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
      ) !== 0
    } else false
  }

  private fun isOnExternalStorage(context: Context): Boolean {
    // check for API level 8 and higher
    val pm: PackageManager = context.packageManager
    try {
      val pi: PackageInfo = pm.getPackageInfo(context.packageName, 0)
      val ai: ApplicationInfo = pi.applicationInfo
      return ai.flags and ApplicationInfo.FLAG_EXTERNAL_STORAGE === ApplicationInfo.FLAG_EXTERNAL_STORAGE
    } catch (e: PackageManager.NameNotFoundException) {
      // ignore
    }

    // check for API level 7 - check files dir
    try {
      val filesDir: String = context.filesDir.absolutePath
      if (filesDir.startsWith("/data/")) {
        return false
      } else if (filesDir.contains("/mnt/") || filesDir.contains("/sdcard/")) {
        return true
      }
    } catch (e: Throwable) {
      // ignore
    }
    return false
  }
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}