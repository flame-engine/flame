import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flutter/material.dart';

class WidgetExample extends Forge2DGame {
  static const String description = '''
    This examples shows how to render a widget on top of a Forge2D body outside
    of Flame.
  ''';

  final List<void Function()> updateStates = [];
  final Map<int, Body> bodyIdMap = {};
  final List<int> addLaterIds = [];

  WidgetExample() : super(zoom: 20, gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
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

    final shape = PolygonShape()..setAsBoxXY(4.6, 0.8);
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8,
      friction: 0.2,
    );
    body.createFixture(fixtureDef);
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
        top: bodyPosition.y - 18,
        left: bodyPosition.x - 90,
        child: Transform.rotate(
          angle: body.angle,
          child: ElevatedButton(
            onPressed: () {
              setState(
                () => body.applyLinearImpulse(Vector2(0.0, 1000)),
              );
            },
            child: const Text(
              'Flying button!',
              textScaler: TextScaler.linear(2.0),
            ),
          ),
        ),
      );
    }
  }
}
