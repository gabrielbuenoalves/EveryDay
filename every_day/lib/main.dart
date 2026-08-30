import 'package:flutter/material.dart';

import 'app/di/app_dependencies.dart';
import 'app/every_day_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(EveryDayApp(dependencies: AppDependencies.bootstrap()));
}
