import 'package:flame_studio/src/framework/settings_store.dart';
import 'package:flame_studio/src/framework/toolbar.dart';
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
    final headerHeight = 25.0;
    return Container(
      color: const Color(0xFF484848),
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, headerHeight + 20, 0, 0),
            child: widget.child,
          ),
          const Toolbar(),
        ],
      ),
      // child: Column(
      //   children: [
      //     const Toolbar(),
      //     Container(constraints: BoxConstraints(minHeight: 10),),
      //     Expanded(child: widget.child),
      //     const Toolbar(),
      //   ],
      // ),
    );
  }
}
