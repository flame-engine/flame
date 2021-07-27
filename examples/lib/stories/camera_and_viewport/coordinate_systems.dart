import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CoordinateSystemsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CoordinateSystemsState();
  }
}

class _CoordinateSystemsState extends State<CoordinateSystemsWidget> {
  int rowsBefore = 1;
  int rowsAfter = 1;
  int colsBefore = 1;
  int colsAfter = 1;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...blocks(
          rowsBefore,
          (v) => rowsBefore = v,
          rotated: false,
          start: true,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...blocks(
                colsBefore,
                (v) => colsBefore = v,
                rotated: true,
                start: true,
              ),
              Expanded(
                child: GameWidget(game: CoordinateSystemsGame()),
              ),
              ...blocks(
                colsAfter,
                (v) => colsAfter = v,
                rotated: true,
                start: false,
              ),
            ],
          ),
        ),
        ...blocks(
          rowsAfter,
          (v) => rowsAfter = v,
          rotated: false,
          start: false,
        ),
      ],
    );
  }

  List<Widget> blocks(
    int variable,
    void Function(int) setVariable, {
    required bool rotated,
    required bool start,
  }) {
    final add = Container(
      child: Center(
        child: TextButton(
          child: const Text('+'),
          onPressed: () => setState(() => setVariable(variable + 1)),
        ),
      ),
      margin: const EdgeInsets.all(32),
    );
    return [
      if (start) add,
      for (int i = 1; i <= variable; i++)
        GestureDetector(
          child: Container(
            child: Center(
              child: RotatedBox(
                quarterTurns: rotated ? 1 : 0,
                child: Text('Block $i'),
              ),
            ),
            margin: const EdgeInsets.all(32),
          ),
          onTap: () => setState(() => setVariable(variable - 1)),
        ),
      if (!start) add,
    ];
  }
}

class CoordinateSystemsGame extends BaseGame
    with
        MultiTouchTapDetector,
        MultiTouchDragDetector,
        ScrollDetector,
        KeyboardEvents {
  static final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = BasicPalette.red.color;
  static final _text = TextPaint(
    config: TextPaintConfig(
      color: BasicPalette.red.color,
      fontSize: 12,
    ),
  );

  String? lastEventDesc;
  Vector2 cameraPosition = Vector2.zero();
  Vector2 cameraVelocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    camera.followVector2(cameraPosition, relativeOffset: Anchor.topLeft);
  }

  @override
  void render(Canvas c) {
    c.drawRect(canvasSize.toRect(), _borderPaint);
    _text.render(
      c,
      'Camera: WASD to move, QE to zoom',
      Vector2.all(5.0),
    );
    _text.render(
      c,
      'Camera: ${camera.position}, zoom: ${camera.zoom}',
      Vector2(canvasSize.x - 5, 5.0),
      anchor: Anchor.topRight,
    );
    _text.render(
      c,
      'This is your Flame game!',
      canvasSize - Vector2.all(5.0),
      anchor: Anchor.bottomRight,
    );
    final lastEventDesc = this.lastEventDesc;
    if (lastEventDesc != null) {
      _text.render(c, lastEventDesc, canvasSize / 2, anchor: Anchor.center);
    }
    super.render(c);
  }

  @override
  void onTapUp(int pointer, TapUpInfo info) {
    lastEventDesc = describe('TapUp', info);
  }

  @override
  void onTapDown(int pointer, TapDownInfo info) {
    lastEventDesc = describe('TapDown', info);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    lastEventDesc = describe('DragStart', info);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    lastEventDesc = describe('DragUpdate', info);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    lastEventDesc = describe('Scroll', info);
  }

  static String describe(String name, PositionInfo info) {
    return [
      name,
      'Global: ${info.eventPosition.global}',
      'Widget: ${info.eventPosition.widget}',
      'Game: ${info.eventPosition.game}',
      if (info is DragUpdateInfo) ...[
        'Delta',
        'Global: ${info.delta.global}',
        'Game: ${info.delta.game}',
      ],
      if (info is PointerScrollInfo) ...[
        'Scroll Delta',
        'Global: ${info.scrollDelta.global}',
        'Game: ${info.scrollDelta.game}',
      ],
    ].join('\n');
  }

  @override
  void update(double dt) {
    super.update(dt);
    cameraPosition.add(cameraVelocity * dt * 10);
    cameraPosition.x = dp(cameraPosition.x, 5);
    cameraPosition.y = dp(cameraPosition.y, 5);
  }

  static double dp(double val, int places) {
    final mod = pow(10.0, places);
    return (val * mod).round().toDouble() / mod;
  }

  @override
  void onKeyEvent(RawKeyEvent e) {
    final isKeyDown = e is RawKeyDownEvent;
    if (e.data.keyLabel == 'a') {
      cameraVelocity.x = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 'd') {
      cameraVelocity.x = isKeyDown ? 1 : 0;
    } else if (e.data.keyLabel == 'w') {
      cameraVelocity.y = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 's') {
      cameraVelocity.y = isKeyDown ? 1 : 0;
    } else if (isKeyDown) {
      if (e.data.keyLabel == 'q') {
        camera.zoom *= 2;
      } else if (e.data.keyLabel == 'e') {
        camera.zoom /= 2;
      }
    }
  }
}
