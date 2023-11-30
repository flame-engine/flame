import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class KeysExampleWidget extends StatefulWidget {
  const KeysExampleWidget({super.key});

  static const String description = '''
      Showcases how component keys can be used to find components
      from a flame game instance.

      Use the buttons to select or deselect the heroes.
''';

  @override
  State<KeysExampleWidget> createState() => _KeysExampleWidgetState();
}

class _KeysExampleWidgetState extends State<KeysExampleWidget> {
  late final KeysExampleGame game = KeysExampleGame();

  void selectHero(ComponentKey key) {
    final hero = game.findByKey<SelectableClass>(key);
    if (hero != null) {
      hero.selected = !hero.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget(game: game),
        ),
        Positioned(
          left: 20,
          top: 222,
          width: 300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  selectHero(ComponentKey.named('knight'));
                },
                child: const Text('Knight'),
              ),
              ElevatedButton(
                onPressed: () {
                  selectHero(ComponentKey.named('mage'));
                },
                child: const Text('Mage'),
              ),
              ElevatedButton(
                onPressed: () {
                  selectHero(ComponentKey.named('ranger'));
                },
                child: const Text('Ranger'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KeysExampleGame extends FlameGame {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final knight = await loadSprite('knight.png');
    final mage = await loadSprite('mage.png');
    final ranger = await loadSprite('ranger.png');

    await addAll([
      SelectableClass(
        key: ComponentKey.named('knight'),
        sprite: knight,
        size: Vector2.all(100),
        position: Vector2(0, 100),
      ),
      SelectableClass(
        key: ComponentKey.named('mage'),
        sprite: mage,
        size: Vector2.all(100),
        position: Vector2(120, 100),
      ),
      SelectableClass(
        key: ComponentKey.named('ranger'),
        sprite: ranger,
        size: Vector2.all(100),
        position: Vector2(240, 100),
      ),
    ]);
  }
}

class SelectableClass extends SpriteComponent {
  SelectableClass({
    super.position,
    super.size,
    super.key,
    super.sprite,
  }) : super(paint: Paint()..color = Colors.white.withOpacity(0.5));

  bool _selected = false;
  bool get selected => _selected;
  set selected(bool value) {
    _selected = value;
    paint = Paint()
      ..color = value ? Colors.white : Colors.white.withOpacity(0.5);
  }
}
