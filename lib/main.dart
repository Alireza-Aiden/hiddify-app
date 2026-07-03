import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:hiddify/bootstrap.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'dart:io';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    DartPingIOS.register();
  }
  // final widgetsBinding = SentryWidgetsFlutterBinding.ensureInitialized();
  // debugPaintSizeEnabled = true;

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent),
  );

  return await lazyBootstrap(widgetsBinding, Environment.dev);
}
