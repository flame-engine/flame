import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flame_devtools/widgets/component_counter.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
import 'package:flame_devtools/widgets/game_loop_controls.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FlameDevTools());
}

class FlameDevTools extends StatelessWidget {
  const FlameDevTools({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: Column(
        children: [
          const GameLoopControls(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const ComponentCounter(),
              const DebugModeButton(),
            ].withSpacing(),
          ),
        ].withSpacing(),
      ),
    );
  }
}

extension on List<Widget> {
  List<Widget> withSpacing() {
    return expand((item) sync* {
      yield const SizedBox(width: 16, height: 16);
      yield item;
    }).skip(1).toList();
  }
}
