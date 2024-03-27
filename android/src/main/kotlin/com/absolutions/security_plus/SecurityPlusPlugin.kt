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
import android.location.LocationManager
import android.app.AppOpsManager
import android.os.Process
import android.provider.Settings

import androidx.core.content.ContextCompat
import android.Manifest

import android.os.Debug
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader

/** SecurityPlusPlugin */
class SecurityPlusPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "security_plus")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isRooted" -> result.success(isRooted())
            "isEmulator" -> result.success(isEmulator())
            "isOnExternalStorage" -> result.success(isOnExternalStorage(context))
            "isDevelopmentModeEnable" -> result.success(developmentModeCheck(context))
            "isMockLocationEnabled" -> result.success(isMockLocationEnabled(context))
            else -> result.notImplemented()
        }
    }

    fun isRooted(): Boolean {
        val rootBeer = RootBeer(context)
        val isRooted = rootBeer.isRooted
    
        // other indicators that are commonly used by Frida
        val isDebuggerAttached = Debug.isDebuggerConnected()
        val isEmulator = isEmulator()
        val isSuperuserAppInstalled = isSuperuserAppInstalled(context)
        val isRunningInAPKMode = isRunningInAPKMode()
    
        return isRooted || isDebuggerAttached || isSuperuserAppInstalled || isRunningInAPKMode
    }
    
    
    private fun isSuperuserAppInstalled(context: Context): Boolean {
        val packages: List<ApplicationInfo> = context.packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        for (packageInfo in packages) {
            if (packageInfo.packageName.equals("eu.chainfire.supersu", ignoreCase = true)
                || packageInfo.packageName.equals("com.koushikdutta.superuser", ignoreCase = true)
                || packageInfo.packageName.equals("com.topjohnwu.magisk", ignoreCase = true)) {
                return true
            }
        }
        return false
    }
    
    private fun isRunningInAPKMode(): Boolean {
        var cmdlineReader: BufferedReader? = null
        try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/bin/getprop", "ro.debuggable"))
            cmdlineReader = BufferedReader(InputStreamReader(process.inputStream))
            return cmdlineReader.readLine() == "1"
        } catch (t: Throwable) {
            t.printStackTrace()
        } finally {
            cmdlineReader?.close()
        }
        return false
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
                context.contentResolver,
                android.provider.Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED, 0
            ) != 0
        } else if (Integer.valueOf(Build.VERSION.SDK_INT) >= 17) {
            android.provider.Settings.Secure.getInt(
                context.contentResolver,
                android.provider.Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
            ) != 0
        } else false
    }
    
    fun isMockLocationEnabled(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // checking if the app have mock location permission
            val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            try {
                val isMockLocationEnabled = appOpsManager.checkOp(AppOpsManager.OPSTR_MOCK_LOCATION, Process.myUid(), context.packageName) == AppOpsManager.MODE_ALLOWED
                if (isMockLocationEnabled) {
                    return true
                }
            } catch (e: Exception) {
                // ignore
            }
        } else {
            // checking if mock location enabled in developer options
            try {
                val isMockLocationEnabled = !Settings.Secure.getString(context.contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION).isNullOrEmpty()
                if (isMockLocationEnabled) {
                    return true
                }
            } catch (e: Settings.SettingNotFoundException) {
                // ignore
            }
        }
    
        // checking on any other app
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val providers = locationManager.allProviders
        for (provider in providers) {
            if (LocationManager.GPS_PROVIDER == provider || LocationManager.NETWORK_PROVIDER == provider) {
                if (locationManager.isProviderEnabled(provider)) {
                    // gps or network enabled so we check if its providing mock location
                    val location = locationManager.getLastKnownLocation(provider)
                    if (location != null && location.isFromMockProvider) {
                        return true
                    }
                }
            }
        }
    
        return false
    }
    
    
    

    private fun isOnExternalStorage(context: Context): Boolean {
        val pm: PackageManager = context.packageManager
        try {
            val pi: PackageInfo = pm.getPackageInfo(context.packageName, 0)
            val ai: ApplicationInfo = pi.applicationInfo
            return ai.flags and ApplicationInfo.FLAG_EXTERNAL_STORAGE === ApplicationInfo.FLAG_EXTERNAL_STORAGE
        } catch (e: PackageManager.NameNotFoundException) {
            // ignore
        }

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
