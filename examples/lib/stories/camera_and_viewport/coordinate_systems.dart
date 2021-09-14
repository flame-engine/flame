import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A simple widget that "wraps" a Flame game with some Containers
/// on each direction (top, bottom, left and right) and allow adding
/// or removing containers.
class CoordinateSystemsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CoordinateSystemsState();
  }
}

class _CoordinateSystemsState extends State<CoordinateSystemsWidget> {
  /// The number of blocks in each direction (top, left, right, bottom).
  List<int> blocks = [1, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...createBlocks(index: 0, rotated: false, start: true),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...createBlocks(index: 1, rotated: true, start: true),
              Expanded(
                child: GameWidget(game: CoordinateSystemsGame()),
              ),
              ...createBlocks(index: 2, rotated: true, start: false),
            ],
          ),
        ),
        ...createBlocks(index: 3, rotated: false, start: false),
      ],
    );
  }

  /// Just creates a list of Widgets + the "add" button
  List<Widget> createBlocks({
    /// Index on the [blocks] array
    required int index,

    /// If true, render vertical text
    required bool rotated,

    /// Whether to render the "add" button before or after
    required bool start,
  }) {
    final add = Container(
      child: Center(
        child: TextButton(
          child: const Text('+'),
          onPressed: () => setState(() => blocks[index]++),
        ),
      ),
      margin: const EdgeInsets.all(32),
    );
    return [
      if (start) add,
      for (int i = 1; i <= blocks[index]; i++)
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
          onTap: () => setState(() => blocks[index]--),
        ),
      if (!start) add,
    ];
  }
}

/// A game that allows for camera control and displays Tap, Drag & Scroll
/// events information on the screen, to allow exploration of the 3 coordinate
/// systems of Flame (global, widget, game).
class CoordinateSystemsGame extends FlameGame
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

  String? lastEventDescription;
  Vector2 cameraPosition = Vector2.zero();
  Vector2 cameraVelocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
    final lastEventDescription = this.lastEventDescription;
    if (lastEventDescription != null) {
      _text.render(
        c,
        lastEventDescription,
        canvasSize / 2,
        anchor: Anchor.center,
      );
    }
    super.render(c);
  }

  @override
  void onTapUp(int pointer, TapUpInfo info) {
    lastEventDescription = _describe('TapUp', info);
  }

  @override
  void onTapDown(int pointer, TapDownInfo info) {
    lastEventDescription = _describe('TapDown', info);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    lastEventDescription = _describe('DragStart', info);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    lastEventDescription = _describe('DragUpdate', info);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    lastEventDescription = _describe('Scroll', info);
  }

  /// Describes generic event information + some event specific details for
  /// some events.
  static String _describe(String name, PositionInfo info) {
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
    // just make it look pretty
    cameraPosition.x = _roundDouble(cameraPosition.x, 5);
    cameraPosition.y = _roundDouble(cameraPosition.y, 5);
  }

  /// Round [val] up to [places] decimal places.
  static double _roundDouble(double val, int places) {
    final mod = pow(10.0, places);
    return (val * mod).round().toDouble() / mod;
  }

  /// Camera controls.
  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      cameraVelocity.x = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      cameraVelocity.x = isKeyDown ? 1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      cameraVelocity.y = isKeyDown ? -1 : 0;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      cameraVelocity.y = isKeyDown ? 1 : 0;
    } else if (isKeyDown) {
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        camera.zoom *= 2;
      } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
        camera.zoom /= 2;
      }
    }

    return KeyEventResult.handled;
  }
}
