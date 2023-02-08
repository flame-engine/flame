import 'package:flame/game.dart';
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/core/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class SettingsProvider extends StatefulWidget {
  const SettingsProvider({
    required this.child,
    this.game,
    super.key,
  });

  final Widget child;
  final Game? game;

  @override
  State<StatefulWidget> createState() => _SettingsProviderState();
}

class _SettingsProviderState extends State<SettingsProvider> {
  late final Settings _settings = Settings(onSettingsChange);

  void onSettingsChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return FlameStudioSettingsWidget(settings: _settings, child: widget.child);
  }

  @override
  void initState() {
    super.initState();
    _settings.controller.setGame(widget.game);
  }

  @override
  void didUpdateWidget(SettingsProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.game != oldWidget.game) {
      _settings.controller.setGame(widget.game);
    }
  }
}

@internal
class FlameStudioSettingsWidget extends InheritedWidget {
  const FlameStudioSettingsWidget({
    required this.settings,
    required super.child,
    super.key,
  });

  final Settings settings;
  GameController get controller => settings.controller;

  @override
  bool updateShouldNotify(FlameStudioSettingsWidget oldWidget) => true;
}
