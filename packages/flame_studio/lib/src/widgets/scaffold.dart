import 'package:flame_studio/src/widgets/flame_studio_settings.dart';
import 'package:flame_studio/src/widgets/toolbar.dart';
import 'package:flutter/widgets.dart';

class Scaffold extends StatelessWidget {
  const Scaffold({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = FlameStudioSettings.of(context);
    return Container(
      color: const Color(0xFF484848),
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, settings.toolbarHeight + 20, 0, 0),
            child: child,
          ),
          const Toolbar(),
        ],
      ),
    );
  }
}
