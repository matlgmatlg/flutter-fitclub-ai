import 'package:flutter/material.dart';
import 'strings.dart';

class AppLocalizations extends InheritedWidget {
  final Strings strings;

  const AppLocalizations({
    required this.strings,
    required Widget child,
  }) : super(child: child);

  static AppLocalizations of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLocalizations>()!;
  }

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) {
    return oldWidget.strings != strings;
  }
}
