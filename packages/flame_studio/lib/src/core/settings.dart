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
}
