import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class TappableEmber extends Ember with TapCallbacks {
  TappableEmber({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  bool onTapDown(TapDownEvent event) {
    size += Vector2.all(10);
    return true;
  }
}

class ClipComponentExample extends FlameGame {
  static const String description =
      '''Tap on the objects to increase their size and see how the clip component
works.''';

  late final _embers = <TappableEmber>[
    TappableEmber(size: Vector2.all(200), position: Vector2.all(100)),
    TappableEmber(size: Vector2.all(300), position: Vector2.all(100)),
    TappableEmber(size: Vector2.all(200), position: Vector2.all(125)),
  ];

  @override
  Future<void> onLoad() async {
    addAll(
      [
        ClipComponent.circle(
          position: Vector2.all(200),
          size: Vector2.all(200),
          children: [_embers[0]],
        ),
        ClipComponent.rectangle(
          position: Vector2(600, 200),
          size: Vector2.all(200),
          children: [_embers[1]],
        ),
        ClipComponent.polygon(
          points: [
            Vector2(1, 0),
            Vector2(1, 1),
            Vector2(0, 1),
            Vector2(1, 0),
          ],
          position: Vector2(200, 500),
          size: Vector2.all(200),
          children: [_embers[2]],
        ),
      ],
    );
  }
}
