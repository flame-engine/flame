import 'package:flame_studio/src/widgets/flame_studio_settings.dart';
import 'package:flame_studio/src/widgets/scaffold.dart';
import 'package:flutter/widgets.dart';

class FlameStudio extends StatelessWidget {
  const FlameStudio(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FlameStudioSettings(
      child: Scaffold(
        child: child,
      ),
    );
  }
}
