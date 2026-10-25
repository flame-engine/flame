import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final textDirectionProvider = Provider((ref) => TextDirection.ltr);

final themeProvider = Provider((ref) => Theme());

class Theme() {
  final Color backdropColor = const Color(0xFF484848);
  final Color toolbarColor = const Color(0xFF303030);
  final Color panelColor = const Color(0xFF383838);

  final double buttonRadius = 5.0;
  final Color buttonColor = const Color(0xFF404040);
  final Color buttonHoverColor = const Color(0xFF606060);
  final Color buttonActiveColor = const Color(0xFFA0A0A0);
  final Color buttonToggledColor = const Color(0xFF8A5A1E);
  final Color buttonDisabledColor = const Color(0x44404040);
  final Color buttonTextColor = const Color(0xFFffd78d);
  final Color buttonHoverTextColor = const Color(0xffffe95d);
  final Color buttonActiveTextColor = const Color(0xffffffff);
  final Color buttonDisabledTextColor = const Color(0x16ffffff);

  final double fontSize = 12.0;
  final Color textColor = const Color(0xFFE6E6E6);
  final Color dimTextColor = const Color(0xFF9A9A9A);
  final Color accentColor = const Color(0xFFC78938);
  final Color hoverColor = const Color(0x14FFFFFF);
  final Color tooltipColor = const Color(0xF0202020);

  final double tabBarHeight = 26.0;
  final Color tabBarColor = const Color(0xFF2C2C2C);
  final Color sectionHeaderColor = const Color(0xFF424242);

  final double rowHeight = 22.0;
  final Color fieldColor = const Color(0xFF2A2A2A);
  final Color fieldBorderColor = const Color(0xFF505050);

  final Color gizmoColor = const Color(0xFFFFA726);
  final Color gizmoXAxisColor = const Color(0xFFE5534B);
  final Color gizmoYAxisColor = const Color(0xFF57AB5A);
  final Color gizmoRotationColor = const Color(0xFF4A90E2);
  final Color gizmoActiveColor = const Color(0xFFFFEB3B);
  final Color gizmoHaloColor = const Color(0xB3000000);
}
