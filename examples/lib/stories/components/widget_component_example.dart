import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class WidgetComponentExample extends FlameGame {
  static const String description = '''
    In this example we showcase the `WidgetComponent`, which hosts a Flutter
    widget inside the Flame component tree. The widgets are real parts of the
    Flutter widget tree, so the button and the text field respond to taps and
    keyboard input, while they are rendered with the position, angle, scale and
    priority of their component, in between other Flame components.

    Press the button to spawn Embers around the card, randomly behind or in
    front of it, and type in the text field to change the label of the
    rotating card.
  ''';

  final Random _random = Random();
  final ValueNotifier<String> _label = ValueNotifier('Flame');

  Vector2 get _cardCenter => size / 2 + Vector2(0, 80);

  @override
  Future<void> onLoad() async {
    final button = WidgetComponent(
      position: Vector2(size.x / 2, 80),
      anchor: Anchor.center,
      widget: Material(
        color: Colors.transparent,
        child: ElevatedButton.icon(
          onPressed: _spawnEmber,
          icon: const Icon(Icons.add),
          label: const Text('Spawn an Ember'),
        ),
      ),
    );

    final textField = WidgetComponent(
      position: Vector2(size.x / 2, 160),
      size: Vector2(280, 56),
      anchor: Anchor.center,
      widget: Material(
        color: Colors.transparent,
        child: TextField(
          onChanged: (value) => _label.value = value,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Card label',
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );

    final card = WidgetComponent(
      position: _cardCenter,
      size: Vector2(220, 120),
      anchor: Anchor.center,
      priority: 1,
      widget: _LabelCard(label: _label),
    );
    card.add(
      RotateEffect.by(
        2 * pi,
        EffectController(duration: 8, infinite: true),
      ),
    );
    card.add(
      ScaleEffect.to(
        Vector2.all(1.3),
        EffectController(
          duration: 2,
          reverseDuration: 2,
          infinite: true,
        ),
      ),
    );

    addAll([
      _BackgroundEmber(position: _cardCenter),
      button,
      textField,
      card,
      _ForegroundEmber(position: _cardCenter),
    ]);
  }

  void _spawnEmber() {
    final angle = _random.nextDouble() * 2 * pi;
    final distance = 80 + _random.nextDouble() * 120;
    final inFront = _random.nextBool();
    final ember = Ember(
      position: _cardCenter + Vector2(cos(angle), sin(angle)) * distance,
      size: Vector2.all(40),
      priority: inFront ? 2 : 0,
    );
    ember.add(
      MoveEffect.by(
        Vector2(0, -30),
        EffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
        ),
      ),
    );
    add(ember);
  }
}

/// An Ember rendered behind the card, to show that widgets are rendered in
/// between other components according to their priority.
class _BackgroundEmber extends Ember {
  _BackgroundEmber({required super.position})
    : super(size: Vector2.all(160), priority: 0);
}

/// An Ember rendered in front of the card, orbiting around it.
class _ForegroundEmber extends Ember {
  _ForegroundEmber({required super.position})
    : super(size: Vector2.all(40), priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      MoveAlongPathEffect(
        Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 140)),
        EffectController(duration: 6, infinite: true),
      ),
    );
  }
}

class _LabelCard extends StatelessWidget {
  const _LabelCard({required this.label});

  final ValueNotifier<String> label;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.widgets, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: label,
              builder: (context, value, child) {
                return Text(
                  value.isEmpty ? 'Flame' : value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
