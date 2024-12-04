import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:security_plus/security_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRooted = true,
      _isDev = false,
      _isExtStorage = false,
      _isEmulator = false;
  bool _isMockLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    if (Platform.isAndroid) {
      final locationStatus = await Permission.location.request();
      if (locationStatus.isGranted) {
        await _initializeSecurityChecks();
      } else {
        log('Location permission denied');
        // Handle permission denied case
      }
    } else {
      await _initializeSecurityChecks();
    }
  }

  Future<void> _initializeSecurityChecks() async {
    await isRooted();
    await isExtStorage();
    await isEmulator();
    await isDevelopment();
    await isMockLocationEnabled();
  }

  Future<void> isRooted() async {
    try {
      bool result = Platform.isAndroid
          ? await SecurityPlus.isRooted
          : await SecurityPlus.isJailBroken;
      setState(() {
        _isRooted = result;
      });
    } catch (e) {
      log('\x1B[31m${"=====error======"}\x1B[0m');
      log(e.toString());
    }
  }

  Future<void> isExtStorage() async {
    if (Platform.isAndroid) {
      try {
        bool result = await SecurityPlus.isOnExternalStorage;
        setState(() {
          _isExtStorage = result;
        });
      } catch (e) {
        log('\x1B[31m${"=====error======"}\x1B[0m');
        log(e.toString());
      }
    }
  }

  Future<void> isEmulator() async {
    try {
      bool result = await SecurityPlus.isEmulator;
      setState(() {
        _isEmulator = result;
      });
    } catch (e) {
      log('\x1B[31m${"=====error======"}\x1B[0m');
      log(e.toString());
    }
  }

  Future<void> isDevelopment() async {
    try {
      bool result = await SecurityPlus.isDevelopmentModeEnable;
      setState(() {
        _isDev = result;
      });
    } catch (e) {
      log('\x1B[31m${"=====error======"}\x1B[0m');
      log(e.toString());
    }
  }

  Future<void> isMockLocationEnabled() async {
    if (!Platform.isAndroid) return;
    try {
      bool result = await SecurityPlus.isMockLocationEnabled;
      setState(() {
        _isMockLocationEnabled = result;
      });
    } catch (e) {
      log('\x1B[31m${"=====error======"}\x1B[0m');
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Security Plus Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Device is ${_isRooted ? "" : "not"} rooted'),
              if (Platform.isAndroid) ...[
                Text('App is ${_isExtStorage ? "" : "not"} on external storage'),
                Text('Device is ${_isEmulator ? "" : "not"} an emulator'),
                Text('Device is ${_isDev ? "" : "not"} in development mode'),
                Text('Mock location is ${_isMockLocationEnabled ? "enabled" : "disabled"}'),
              ],
              ElevatedButton(
                onPressed: _checkPermissionsAndInitialize,
                child: const Text('Refresh Security Checks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
