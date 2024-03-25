import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'app_bloc_observer.dart';
import 'constant.dart';

final logger = Logger(printer: PrettyPrinter());

Future<void> bootstrapDesktop() async {
  await _setUpWindowManager();
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}

Future<void> _setUpWindowManager() async {
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
        Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal);
    await windowManager.setMinimumSize(
        Size(Constant.minWindowWidth, Constant.minWindowHeight));
    await windowManager.setSize(
        Size(Constant.defaultWindowWidth, Constant.defaultWindowHeight));
    await windowManager.center();
    if (Platform.isMacOS || Platform.isWindows) {
      await windowManager.setHasShadow(true);
      await windowManager.setBrightness(Brightness.light);
    }
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });
}