import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:forge2d/forge2d.dart' hide Transform;

import 'boundaries.dart';

const widgetSampleDescription = '''
This examples shows how to render a widget on top of a Forge2D body.
''';

class WidgetSample extends Forge2DGame with TapDetector {
  List<Function()> updateStates = [];
  Map<int, Body> bodyIdMap = {};
  List<int> addLaterIds = [];

  Vector2 screenPosition(Body body) => worldToScreen(body.worldCenter);

  WidgetSample() : super(zoom: 20, gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    addAll(boundaries);
  }

  Body createBody() {
    final bodyDef = BodyDef()
      ..angularVelocity = 3
      ..position = screenToWorld(
        Vector2.random()..multiply(camera.viewport.effectiveSize),
      )
      ..type = BodyType.dynamic;
    final body = world.createBody(bodyDef);

    final shape = PolygonShape()..setAsBoxXY(4.6, 0.8);
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..restitution = 0.95;
    body.createFixture(fixtureDef);
    return body;
  }

  int createBodyId() {
    final id = bodyIdMap.length + addLaterIds.length;
    addLaterIds.add(id);
    return id;
  }

  @override
  void update(double dt) {
    super.update(dt);
    addLaterIds.forEach((id) => bodyIdMap[id] = createBody());
    addLaterIds.clear();
    updateStates.forEach((f) => f());
  }
}

class BodyWidgetSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GameWidget<WidgetSample>(
      game: WidgetSample(),
      overlayBuilderMap: {
        'button1': (ctx, game) {
          return BodyButtonWidget(game, game.createBodyId());
        },
        'button2': (ctx, game) {
          return BodyButtonWidget(game, game.createBodyId());
        },
      },
      initialActiveOverlays: const ['button1', 'button2'],
    );
  }
}

class BodyButtonWidget extends StatefulWidget {
  final WidgetSample _game;
  final int _bodyId;

  const BodyButtonWidget(this._game, this._bodyId);

  @override
  State<StatefulWidget> createState() {
    return _BodyButtonState(_game, _bodyId);
  }
}

class _BodyButtonState extends State<BodyButtonWidget> {
  final WidgetSample _game;
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
      final bodyPosition = _game.screenPosition(body);
      return Positioned(
        top: bodyPosition.y - 18,
        left: bodyPosition.x - 90,
        child: Transform.rotate(
          angle: -body.angle,
          child: material.ElevatedButton(
            onPressed: () {
              setState(
                () => body.applyLinearImpulse(Vector2(0.0, 1000)),
              );
            },
            child: const Text(
              'Flying button!',
              textScaleFactor: 2.0,
            ),
          ),
        ),
      );
    }
  }
}
