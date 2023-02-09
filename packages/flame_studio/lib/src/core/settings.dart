import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/widgets/settings_provider.dart';
import 'package:flutter/widgets.dart';

class Settings {
  Settings(this._onChange) : controller = GameController(_onChange);

  static Settings of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<FlameStudioSettingsWidget>();
    return result!.settings;
  }

  final GameController controller;

  final void Function() _onChange;

  TextDirection get textDirection => TextDirection.ltr;

  Color get backdropColor => const Color(0xFF484848);
  Color get toolbarColor => const Color(0xFF303030);
  Color get panelColor => const Color(0xFF383838);

  double get buttonRadius => 5.0;
  Color get buttonColor => const Color(0xFF404040);
  Color get buttonHoverColor => const Color(0xFF606060);
  Color get buttonActiveColor => const Color(0xFFA0A0A0);
  Color get buttonDisabledColor => const Color(0x44404040);
  Color get buttonTextColor => const Color(0xFFffd78d);
  Color get buttonHoverTextColor => const Color(0xffffe95d);
  Color get buttonActiveTextColor => const Color(0xffffffff);
  Color get buttonDisabledTextColor => const Color(0x16ffffff);
}
