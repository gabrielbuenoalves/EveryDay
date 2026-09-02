import 'package:flutter/material.dart';

class AppNavScope extends InheritedWidget {
  const AppNavScope({super.key, required this.select, required super.child});

  final void Function(String id) select;

  static void go(BuildContext context, String id) {
    final scope = context.findAncestorWidgetOfExactType<AppNavScope>();
    scope?.select(id);
  }

  @override
  bool updateShouldNotify(AppNavScope oldWidget) => select != oldWidget.select;
}
