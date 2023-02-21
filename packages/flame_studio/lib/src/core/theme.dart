import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final textDirectionProvider = Provider((ref) => TextDirection.ltr);

final themeProvider = Provider((ref) => Theme());

class Theme {
  final Color backdropColor = const Color(0xFF484848);
  final Color toolbarColor = const Color(0xFF303030);
  final Color panelColor = const Color(0xFF383838);

  final double buttonRadius = 5.0;
  final Color buttonColor = const Color(0xFF404040);
  final Color buttonHoverColor = const Color(0xFF606060);
  final Color buttonActiveColor = const Color(0xFFA0A0A0);
  final Color buttonDisabledColor = const Color(0x44404040);
  final Color buttonTextColor = const Color(0xFFffd78d);
  final Color buttonHoverTextColor = const Color(0xffffe95d);
  final Color buttonActiveTextColor = const Color(0xffffffff);
  final Color buttonDisabledTextColor = const Color(0x16ffffff);
}
