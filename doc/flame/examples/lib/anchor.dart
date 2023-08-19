import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class AnchorGame extends FlameGame {
  final _parentAnchorText = TextComponent(position: Vector2.all(5));
  final _childAnchorText = TextComponent(position: Vector2(5, 30));

  late _AnchoredRectangle _redComponent;
  late _AnchoredRectangle _blueComponent;

  @override
  Future<void> onLoad() async {
    _redComponent = _AnchoredRectangle(
      size: size / 4,
      position: size / 2,
      paint: BasicPalette.red.paint(),
    );

    _blueComponent = _AnchoredRectangle(
      size: size / 8,
      paint: BasicPalette.blue.paint(),
    );

    await _redComponent.addAll([
      _blueComponent,
      CircleComponent(radius: 2, anchor: Anchor.center),
    ]);

    await addAll([
      _redComponent,
      _parentAnchorText,
      _childAnchorText,
      CircleComponent(
        radius: 4,
        position: size / 2,
        anchor: Anchor.center,
      ),
    ]);
  }

  @override
  void update(double dt) {
    _parentAnchorText.text = 'Parent: ${_redComponent.anchor}';
    _childAnchorText.text = 'Child: ${_blueComponent.anchor}';
    super.update(dt);
  }
}

class _AnchoredRectangle extends RectangleComponent with TapCallbacks {
  _AnchoredRectangle({
    super.position,
    super.size,
    super.paint,
  });

  @override
  void onTapDown(TapDownEvent event) {
    var index = Anchor.values.indexOf(anchor) + 1;
    if (index == Anchor.values.length) {
      index = 0;
    }
    anchor = Anchor.values.elementAt(index);
    super.onTapDown(event);
  }
}
