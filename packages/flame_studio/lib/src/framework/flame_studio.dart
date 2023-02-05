import 'package:flame_studio/src/framework/settings_store.dart';
import 'package:flutter/widgets.dart';

class FlameStudio extends StatefulWidget {
  const FlameStudio(this.child, {super.key});

  final Widget child;

  @override
  State<StatefulWidget> createState() => _FlameStudioState();
}

class _FlameStudioState extends State<FlameStudio> {
  final SettingsStore _settings = SettingsStore();

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
