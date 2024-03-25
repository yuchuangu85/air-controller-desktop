import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'app_bloc_observer.dart';

final logger = Logger(printer: PrettyPrinter());

void bootstrap() {
  Bloc.observer = AppBlocObserver();
  runApp(const App());
}
