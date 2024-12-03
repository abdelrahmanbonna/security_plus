package com.absolutions.security_plus

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Before
import org.junit.Test
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import java.io.ByteArrayInputStream
import java.io.File
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.lang.reflect.Field

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE)
internal class SecurityPlusPluginTest {
    @Mock
    private lateinit var mockContext: Context
    
    @Mock
    private lateinit var mockPackageManager: PackageManager
    
    private lateinit var plugin: SecurityPlusPlugin
    
    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)
        plugin = SecurityPlusPlugin()
        // Use reflection to set the context
        val contextField = SecurityPlusPlugin::class.java.getDeclaredField("context")
        contextField.isAccessible = true
        contextField.set(plugin, mockContext)
        
        Mockito.`when`(mockContext.packageManager).thenReturn(mockPackageManager)
    }

    @Test
    fun `test checkFridaProcesses with no suspicious processes`() {
        val processOutput = "system_server\nandroid.process.media\ncom.android.phone"
        val process = Mockito.mock(Process::class.java)
        Mockito.`when`(process.inputStream).thenReturn(ByteArrayInputStream(processOutput.toByteArray()))
        
        // Use reflection to access private method
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("checkFridaProcesses")
        method.isAccessible = true
        
        assertFalse(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test checkFridaProcesses with suspicious process`() {
        val processOutput = "system_server\nfrida-server\ncom.android.phone"
        val process = Mockito.mock(Process::class.java)
        Mockito.`when`(process.inputStream).thenReturn(ByteArrayInputStream(processOutput.toByteArray()))
        
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("checkFridaProcesses")
        method.isAccessible = true
        
        assertTrue(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test checkSuspiciousFiles with no root files`() {
        // Mock File class behavior
        val mockFile = Mockito.mock(File::class.java)
        Mockito.`when`(mockFile.exists()).thenReturn(false)
        
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("checkSuspiciousFiles")
        method.isAccessible = true
        
        assertFalse(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test checkSuspiciousFiles with root file present`() {
        // Mock File class to return true for /system/bin/su
        val mockFile = Mockito.mock(File::class.java)
        Mockito.`when`(mockFile.exists()).thenReturn(true)
        
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("checkSuspiciousFiles")
        method.isAccessible = true
        
        assertTrue(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test isSuperuserAppInstalled with no root apps`() {
        val applications = listOf<ApplicationInfo>()
        Mockito.`when`(mockPackageManager.getInstalledApplications(PackageManager.GET_META_DATA))
            .thenReturn(applications)
            
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("isSuperuserAppInstalled", Context::class.java)
        method.isAccessible = true
        
        assertFalse(method.invoke(plugin, mockContext) as Boolean)
    }

    @Test
    fun `test isSuperuserAppInstalled with root app present`() {
        val appInfo = ApplicationInfo().apply {
            packageName = "com.topjohnwu.magisk"
        }
        val applications = listOf(appInfo)
        
        Mockito.`when`(mockPackageManager.getInstalledApplications(PackageManager.GET_META_DATA))
            .thenReturn(applications)
            
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("isSuperuserAppInstalled", Context::class.java)
        method.isAccessible = true
        
        assertTrue(method.invoke(plugin, mockContext) as Boolean)
    }

    @Test
    fun `test checkFridaLibraries with no suspicious libraries`() {
        val procMaps = "/system/lib/libc.so\n/system/lib/libandroid.so"
        val mockFile = Mockito.mock(File::class.java)
        Mockito.`when`(mockFile.readLines()).thenReturn(procMaps.split("\n"))
        
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("checkFridaLibraries")
        method.isAccessible = true
        
        assertFalse(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test checkFridaLibraries with frida library present`() {
        val procMaps = "/system/lib/libc.so\n/data/local/tmp/frida-agent.so"
        val mockFile = Mockito.mock(File::class.java)
        Mockito.`when`(mockFile.readLines()).thenReturn(procMaps.split("\n"))
        
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("checkFridaLibraries")
        method.isAccessible = true
        
        assertTrue(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test detectHooks with no hooks present`() {
        val method = SecurityPlusPlugin::class.java.getDeclaredMethod("detectHooks")
        method.isAccessible = true
        
        assertFalse(method.invoke(plugin) as Boolean)
    }

    @Test
    fun `test isRooted combines all checks`() {
        // Mock all individual check methods to return false
        val mockMethods = listOf(
            "checkFridaProcesses",
            "checkSuspiciousFiles",
            "checkSuPaths",
            "checkFridaLibraries",
            "detectHooks"
        )
        
        mockMethods.forEach { methodName ->
            val method = SecurityPlusPlugin::class.java.getDeclaredMethod(methodName)
            method.isAccessible = true
            // Mock to return false for all checks
            Mockito.`when`(method.invoke(plugin)).thenReturn(false)
        }
        
        assertFalse(plugin.isRooted())
    }

    @Test
    fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
        val plugin = SecurityPlusPlugin()

        val call = MethodCall("getPlatformVersion", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success("Android " + android.os.Build.VERSION.RELEASE)
    }
}
