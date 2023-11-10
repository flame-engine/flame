import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

class ComponentTrackComponent<T> extends TextComponent {
  ComponentTrackComponent({
    required this.target,
    super.position,
  });

  final Component target;
  late String _label;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _label = T.toString();

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
      ),
    );

    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          text = '$_label: ${target.children.whereType<T>().length}';
        },
      ),
    );
  }
}
