import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:security_plus/security_plus.dart';

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
    isRooted();
    isExtStorage();
    isEmulator();
    isDevelopment();
    isMockLocationEnabled();
  }

  Future<void> isRooted() async {
    try {
      bool result = Platform.isAndroid
          ? await SecurityPlus.isRooted
          : await SecurityPlus.isJailBroken;
      _isRooted = result;
    } catch (e) {
      log('\x1B[31m${"=====error======"}\x1B[0m');
    }

    setState(() {});
  }

  Future<void> isExtStorage() async {
    if (Platform.isAndroid) {
      try {
        bool result = await SecurityPlus.isOnExternalStorage;
        _isExtStorage = result;
      } catch (e) {
        log('\x1B[31m${"=====error======"}\x1B[0m');
      }
    }

    setState(() {});
  }

  Future<void> isEmulator() async {
    if (Platform.isAndroid) {
      try {
        bool result = await SecurityPlus.isEmulator;
        _isEmulator = result;
      } catch (e) {
        log('\x1B[31m${"=====error======"}\x1B[0m');
      }
    }

    setState(() {});
  }

  Future<void> isMockLocationEnabled() async {
    if (Platform.isAndroid) {
      try {
        bool result = await SecurityPlus.isMockLocationEnabled;
        _isMockLocationEnabled = result;
      } catch (e) {
        log('\x1B[31m${"=====error======"}\x1B[0m');
      }
    }

    setState(() {});
  }

  Future<void> isDevelopment() async {
    if (Platform.isAndroid) {
      try {
        bool result = await SecurityPlus.isDevelopmentModeEnable;
        _isDev = result;
      } catch (e) {
        log('\x1B[31m${"=====error======"}\x1B[0m');
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rooted || JailBroken'),
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Center(
                  child: Platform.isAndroid
                      ? Text('Android is rooted : $_isRooted\n')
                      : Text('iOS is is jail broken : $_isRooted\n'),
                ),
              ),
              if (Platform.isAndroid)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Center(
                      child:
                          Text('Android is Emulator device : $_isEmulator\n')),
                ),
              if (Platform.isAndroid)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Center(
                      child: Text('Android is Development mode : $_isDev\n')),
                ),
              if (Platform.isAndroid)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Center(
                      child: Text(
                          'Android is on External Storage : $_isExtStorage\n')),
                ),
              if (Platform.isAndroid)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Center(
                    child: Text(
                        'Mock Location Enabled: $_isMockLocationEnabled\n'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
