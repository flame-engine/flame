import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flutter/material.dart';

class WidgetExample extends Forge2DExampleGame {
  static const String description = '''
    This example shows how to render a widget on top of a Forge2D body,
    outside of Flame. The Flutter buttons are real widgets in the Flutter
    tree, driven by the physics bodies underneath them, so you can press them
    while they tumble around.
  ''';

  /// The size of the button widget in logical pixels.
  static const buttonWidth = 190.0;
  static const buttonHeight = 48.0;

  final List<void Function()> updateStates = [];
  final Map<int, Body> bodyIdMap = {};
  final List<int> addLaterIds = [];

  static const zoom = 20.0;

  WidgetExample() : super(zoom: zoom, gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this, strokeWidth: 0);
    world.addAll(boundaries);
  }

  Body createBody() {
    final bodyDef = BodyDef(
      angularVelocity: 3,
      position: Vector2.zero(),
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    // The body matches the size of the button widget that is drawn on top.
    body.createShape(
      Polygon.box(buttonWidth / 2 / zoom, buttonHeight / 2 / zoom),
      ShapeDef(material: SurfaceMaterial(restitution: 0.8, friction: 0.2)),
    );
    return body;
  }

  int createBodyId(int id) {
    addLaterIds.add(id);
    return id;
  }

  @override
  void update(double dt) {
    super.update(dt);
    addLaterIds.forEach((id) {
      if (!bodyIdMap.containsKey(id)) {
        bodyIdMap[id] = createBody();
      }
    });
    addLaterIds.clear();
    updateStates.forEach((f) => f());
  }
}

class BodyWidgetExample extends StatelessWidget {
  const BodyWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget<WidgetExample>(
      game: WidgetExample(),
      overlayBuilderMap: {
        'button1': (ctx, game) {
          return BodyButtonWidget(game, game.createBodyId(1));
        },
        'button2': (ctx, game) {
          return BodyButtonWidget(game, game.createBodyId(2));
        },
      },
      initialActiveOverlays: const ['button1', 'button2'],
    );
  }
}

class BodyButtonWidget extends StatefulWidget {
  final WidgetExample _game;
  final int _bodyId;

  const BodyButtonWidget(
    this._game,
    this._bodyId, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _BodyButtonState(_game, _bodyId);
  }
}

class _BodyButtonState extends State<BodyButtonWidget> {
  final WidgetExample _game;
  final int _bodyId;
  Body? _body;

  _BodyButtonState(this._game, this._bodyId) {
    _game.updateStates.add(() {
      setState(() {
        _body = _game.bodyIdMap[_bodyId];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _body;
    if (body == null) {
      return Container();
    } else {
      final bodyPosition = _game.worldToScreen(body.position);
      return Positioned(
        top: bodyPosition.y - WidgetExample.buttonHeight / 2,
        left: bodyPosition.x - WidgetExample.buttonWidth / 2,
        child: Transform.rotate(
          angle: body.angle,
          child: SizedBox(
            width: WidgetExample.buttonWidth,
            height: WidgetExample.buttonHeight,
            child: FloatingActionButton.extended(
              // Every button needs its own tag, since there is more than one.
              heroTag: 'flying_button_$_bodyId',
              onPressed: () {
                setState(
                  () => body.applyLinearImpulse(Vector2(0.0, 1000)),
                );
              },
              icon: const FlutterLogo(size: 28),
              label: const Text('Flutter'),
            ),
          ),
        ),
      );
    }
  }
}
