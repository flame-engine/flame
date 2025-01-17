import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flame_devtools/widgets/component_tree.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
import 'package:flame_devtools/widgets/game_loop_controls.dart';
import 'package:flame_devtools/widgets/overlay_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const FlameDevTools());
}

class FlameDevTools extends StatelessWidget {
  const FlameDevTools({super.key});

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: ProviderScope(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GameLoopControls(),
                const DebugModeButton(),
              ].withSpacing(),
            ),
            const Expanded(child: ComponentTree()),
            const Flexible(child: OverlayNav()),
          ].withSpacing(),
        ),
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
