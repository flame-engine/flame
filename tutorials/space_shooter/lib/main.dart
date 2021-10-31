import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'steps/1_getting_started/getting_started.dart';

void main() {
  final dashbook = Dashbook.dualTheme(
    light: ThemeData.light(),
    dark: ThemeData.dark(),
    initWithLight: false,
  );

  addGettingStarted(dashbook);

  runApp(dashbook);
}
