import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/widgets.dart';

class DecoratorVsEffectExample extends FlameGame {
  static const String description = '''
  This example demonstrates the difference between using an `Effect` and a 
  `Decorator` for group transparency.

  1. Top (OpacityEffect): 
  Opacity is applied to EACH child individually. 
  Note the "double-exposure" where the sprites overlap.
    
  2. Bottom (Decorator): 
  The entire group is flattened into a layer first using `saveLayer`, 
  and then transparency is applied to the whole layer.
  Note how the overlapping area is uniform.
  ''';

  @override
  Future<void> onLoad() async {
    final groupA = _buildItem(
      'OpacityEffect (Individual Blend)',
      _buildCompositeObject()
        ..children.forEach((child) {
          if (child is OpacityProvider) {
            child.add(OpacityEffect.to(0.5, EffectController(duration: 0)));
          }
        }),
    );

    final groupB = _buildItem(
      'Decorator (Group Blend)',
      _buildCompositeObject(),
    )..decorator.addLast(_GroupOpacityDecorator(0.5));

    world.add(
      ColumnComponent(
        gap: 150,
        anchor: Anchor.center,
        children: [groupA, groupB],
      ),
    );
  }

  PositionComponent _buildItem(String title, Component object) {
    return PositionComponent(
      size: Vector2(150, 120),
      children: [
        object,
        TextComponent(
          text: title,
          position: Vector2(0, 80),
          anchor: Anchor.center,
        ),
      ],
    );
  }

  /// Builds an object consisting of two overlapping Embers.
  Component _buildCompositeObject() {
    return PositionComponent(
      children: [
        Ember(
          size: Vector2.all(100),
          position: Vector2(-25, 0),
        ),
        Ember(
          size: Vector2.all(100),
          position: Vector2(25, 0),
        ),
      ],
    );
  }
}

/// A simple decorator that applies opacity to the entire decorated subtree.
class _GroupOpacityDecorator extends Decorator {
  _GroupOpacityDecorator(double opacity)
    : _paint = Paint()..color = Color.fromRGBO(255, 255, 255, opacity);

  final Paint _paint;

  @override
  void apply(void Function(Canvas) draw, Canvas canvas) {
    canvas.saveLayer(null, _paint);
    draw(canvas);
    canvas.restore();
  }
}
