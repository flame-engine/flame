import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:forge2d/forge2d.dart' hide Transform;

import 'boundaries.dart';

class WidgetSample extends Forge2DGame with TapDetector {
  List<Function()> updateStates = [];
  Map<int, Body> bodyIdMap = {};
  List<int> addLaterIds = [];

  Vector2 screenPosition(Body body) => worldToScreen(body.worldCenter);

  WidgetSample() : super(zoom: 20, gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    addAll(boundaries);
  }

  Body createBody() {
    final bodyDef = BodyDef()
      ..angularVelocity = 3
      ..position =
          screenToWorld(Vector2.random()..multiply(viewport.effectiveSize))
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

  static GameWidget gameWidget() {
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

  _BodyButtonState(this._game, this._bodyId) {
    _game.updateStates.add(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final _body = _game.bodyIdMap[_bodyId];
    if (_body == null) {
      return widgets.Container();
    } else {
      return Positioned(
        top: _game.screenPosition(_body).y - 18,
        left: _game.screenPosition(_body).x - 90,
        child: widgets.Transform.rotate(
          angle: -_body.angle,
          child: ElevatedButton(
            onPressed: () {
              setState(
                () => _body.applyLinearImpulse(Vector2(0.0, 1000)),
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
