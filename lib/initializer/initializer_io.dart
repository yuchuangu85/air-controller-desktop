import 'dart:io';

import 'package:air_controller/mobile/bootstrap_mobile.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../bootstrap.dart';
import '../constant.dart';

Future<bool> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    bootstrapDesktop();
  } else if (Platform.isAndroid) {
    bootstrapMobile();
  }
  return true;
}

