import 'package:flame_studio/src/widgets/ui_scaffold.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlameStudio extends StatelessWidget {
  const FlameStudio(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: UiScaffold(gameApp: child),
    );
  }
}
