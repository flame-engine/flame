import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flame_devtools/widgets/component_tree.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
import 'package:flame_devtools/widgets/game_loop_controls.dart';
import 'package:flame_devtools/widgets/overlay_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const FlameDevTools());
}

class const FlameDevTools({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: ProviderScope(
        child: Column(
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                GameLoopControls(),
                DebugModeButton(),
              ],
            ),
            Expanded(child: ComponentTree()),
            OverlayNavigation(),
          ],
        ),
      ),
    );
  }
}
