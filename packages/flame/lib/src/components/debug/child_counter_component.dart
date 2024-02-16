import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

/// A debug component that shows the number of children of a given type from
/// a target component.
///
/// Add it to the game to start seeing the count.
class ChildCounterComponent<T extends Component> extends TextComponent {
  ChildCounterComponent({
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
          text = '$_label: ${target.children.query<T>().length}';
        },
      ),
    );
  }
}
