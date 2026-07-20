import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flutter/material.dart';

/// The body shape that a widget is given, which follows the shape that
/// Material draws it with.
enum WidgetShape {
  /// A plain box, for the app bar.
  box,

  /// A box with rounded corners, for the button. Material 3 draws a floating
  /// action button as a rounded square rather than as a circle.
  roundedBox,

  /// A capsule, for a line of text.
  capsule,
}

/// One of the widgets of the counter app, carried by a Forge2D body.
class FallingWidget {
  FallingWidget(this.shape);

  /// The shape of the body underneath the widget.
  final WidgetShape shape;

  Body? _body;

  /// The body that carries the widget, which only exists once the widget has
  /// been measured, see [WidgetExample.fit].
  Body get body => _body!;

  bool get hasBody => _body != null;

  /// The size of the widget in logical pixels.
  Size size = Size.zero;
}

class WidgetExample extends Forge2DExampleGame {
  static const String description = '''
    This is the app that `flutter create` gives you, except that every widget
    rests on a Forge2D body and drops to the floor when the example starts.

    Press a widget to launch it across the screen. They are real widgets in
    the Flutter tree the whole time, so the button keeps counting while it
    tumbles, and the counter keeps showing the total.
  ''';

  /// How many pixels one meter of the physics world is rendered as.
  static const scale = 20.0;

  WidgetExample() : super(metersToPixels: scale, gravity: Vector2(0, 10.0));

  final _random = Random();

  /// The corner radius that Material 3 draws a floating action button with.
  static const buttonCornerRadius = 16.0;

  /// The mass that every widget is given, so that the big app bar does not
  /// crush the small counter. Used as `density = widgetMass / area`.
  static const widgetMass = 1.0;

  final appBar = FallingWidget(WidgetShape.box);
  final label = FallingWidget(WidgetShape.capsule);
  final counter = FallingWidget(WidgetShape.capsule);
  final button = FallingWidget(WidgetShape.roundedBox);

  /// Callbacks that run after every step, so that the overlay can follow the
  /// bodies that it is drawn on.
  final List<VoidCallback> onStep = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _addWalls();
  }

  /// Boxes just outside each edge of the screen that keep the widgets on
  /// screen.
  ///
  /// They are solid boxes rather than the thin lines that the other examples
  /// use, so that a small widget shoved into a corner by the falling app bar
  /// cannot squeeze out between two walls.
  void _addWalls() {
    final rect = camera.visibleWorldRect;
    const thickness = 5.0;
    const half = thickness / 2;

    void wall(double cx, double cy, double halfWidth, double halfHeight) {
      world
          .createBody(BodyDef(position: Vector2(cx, cy)))
          .createShape(Polygon.box(halfWidth, halfHeight));
    }

    final halfWidth = rect.width / 2;
    final halfHeight = rect.height / 2;
    wall(rect.center.dx, rect.top - half, halfWidth, half); // top
    wall(rect.center.dx, rect.bottom + half, halfWidth, half); // bottom
    wall(rect.left - half, rect.center.dy, half, halfHeight); // left
    wall(rect.right + half, rect.center.dy, half, halfHeight); // right
  }

  /// Fits the body of [fallingWidget] to [size] logical pixels, creating it at
  /// [layout] the first time.
  ///
  /// The overlay measures its widgets before it calls this, so that the shape
  /// covers the widget itself and not the space around it. It is called again
  /// whenever a widget changes size, which is what happens when the counter
  /// gains a digit.
  void fit(
    FallingWidget fallingWidget, {
    required Size size,
    required Offset layout,
  }) {
    if (fallingWidget.size == size) {
      return;
    }
    fallingWidget.size = size;
    if (fallingWidget.hasBody) {
      for (final shape in fallingWidget.body.shapes) {
        shape.destroy();
      }
    } else {
      fallingWidget._body = world.createBody(
        BodyDef(
          type: BodyType.dynamic,
          position: screenToWorld(Vector2(layout.dx, layout.dy)),
        ),
      );
    }
    fallingWidget.body.createShape(
      _geometryFor(fallingWidget.shape, size),
      ShapeDef(
        // Every widget weighs the same, whatever its size. With one density
        // for all of them the app bar comes out orders of magnitude heavier
        // than the counter, and squeezes it through the floor when it lands
        // on top of it.
        density: widgetMass / (size.width / scale * (size.height / scale)),
        // The default friction of 0.6 keeps the widgets from sliding, and the
        // rolling resistance is what stops the capsules from rolling on for
        // ever once they have landed.
        material: SurfaceMaterial(restitution: 0.2, rollingResistance: 0.1),
      ),
    );
  }

  /// The geometry, in meters, that covers a widget of [size] logical pixels.
  ShapeGeometry _geometryFor(WidgetShape shape, Size size) {
    final halfWidth = size.width / 2 / scale;
    final halfHeight = size.height / 2 / scale;
    switch (shape) {
      case WidgetShape.box:
        return Polygon.box(halfWidth, halfHeight);
      case WidgetShape.roundedBox:
        // The rounding radius grows the box outwards, so it has to be taken
        // off the half extents for the shape to stay the size of the widget.
        final radius = min(
          buttonCornerRadius / scale,
          min(halfWidth, halfHeight),
        );
        return Polygon.box(
          halfWidth - radius,
          halfHeight - radius,
          radius: radius,
        );
      case WidgetShape.capsule:
        final radius = min(halfWidth, halfHeight);
        final offset = halfWidth >= halfHeight
            ? Vector2(halfWidth - radius, 0)
            : Vector2(0, halfHeight - radius);
        return Capsule(center1: -offset, center2: offset, radius: radius);
    }
  }

  /// Sends a widget flying, which is what pressing one does.
  void launch(FallingWidget fallingWidget) {
    final body = fallingWidget.body;
    final direction = Vector2(_random.nextDouble() * 2 - 1, -1.6)..normalize();
    body
      ..applyLinearImpulse(direction * (body.mass * 14))
      ..applyAngularImpulse(body.mass * (_random.nextDouble() * 2 - 1));
  }

  /// Where the top left corner of [fallingWidget] currently is on screen.
  Offset topLeftOf(FallingWidget fallingWidget) {
    final center = worldToScreen(fallingWidget.body.position);
    return Offset(
      center.x - fallingWidget.size.width / 2,
      center.y - fallingWidget.size.height / 2,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final callback in onStep) {
      callback();
    }
  }
}

class BodyWidgetExample extends StatelessWidget {
  const BodyWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget<WidgetExample>(
      game: WidgetExample(),
      overlayBuilderMap: {
        'counterApp': (context, game) => CounterAppOverlay(game),
      },
      initialActiveOverlays: const ['counterApp'],
    );
  }
}

/// The widget tree of the counter app, with every widget positioned by the
/// body that carries it.
class CounterAppOverlay extends StatefulWidget {
  const CounterAppOverlay(this.game, {super.key});

  final WidgetExample game;

  @override
  State<CounterAppOverlay> createState() => _CounterAppOverlayState();
}

class _CounterAppOverlayState extends State<CounterAppOverlay> {
  static const _appBarHeight = 56.0;

  /// How much of the width the app bar covers. A bar that spans the whole
  /// game is wedged between the two walls, so it is kept a little narrower to
  /// leave it room to tumble and to be bounced up.
  static const _appBarWidthFactor = 0.85;
  static const _fabSize = 56.0;
  static const _fabMargin = 16.0;
  static const _labelText = 'You have pushed the button this many times:';

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    widget.game.onStep.add(_follow);
  }

  @override
  void dispose() {
    widget.game.onStep.remove(_follow);
    super.dispose();
  }

  void _follow() {
    if (mounted) {
      setState(() {});
    }
  }

  /// The button's normal function, plus a shove.
  void _incrementCounter() {
    setState(() => _counter++);
    widget.game.launch(widget.game.button);
  }

  /// The size that [text] takes up, so that the body underneath it covers the
  /// glyphs instead of a padded box around them.
  Size _measure(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.size;
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final theme = Theme.of(context);
    if (!game.isLoaded) {
      return const SizedBox.shrink();
    }

    final gameSize = game.size;
    final labelStyle = theme.textTheme.bodyMedium;
    final counterStyle = theme.textTheme.headlineMedium;
    game
      ..fit(
        game.appBar,
        size: Size(gameSize.x * _appBarWidthFactor, _appBarHeight),
        layout: Offset(gameSize.x / 2, _appBarHeight / 2),
      )
      ..fit(
        game.label,
        size: _measure(_labelText, labelStyle),
        layout: Offset(gameSize.x / 2, gameSize.y / 2 - 24),
      )
      ..fit(
        game.counter,
        size: _measure('$_counter', counterStyle),
        layout: Offset(gameSize.x / 2, gameSize.y / 2 + 20),
      )
      ..fit(
        game.button,
        size: const Size(_fabSize, _fabSize),
        layout: Offset(
          gameSize.x - _fabMargin - _fabSize / 2,
          gameSize.y - _fabMargin - _fabSize / 2,
        ),
      );

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          _positioned(
            game.appBar,
            AppBar(
              // The game is not the whole window, so there is no status bar
              // to leave room for.
              primary: false,
              backgroundColor: theme.colorScheme.inversePrimary,
              title: const Text('Flutter Demo Home Page'),
            ),
          ),
          _positioned(game.label, Text(_labelText, style: labelStyle)),
          _positioned(game.counter, Text('$_counter', style: counterStyle)),
          _positioned(
            game.button,
            FloatingActionButton(
              heroTag: 'counterButton',
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  /// Places [child] on the body of [fallingWidget], and launches it when it is
  /// pressed. Widgets that handle their own taps, like the button, win the
  /// gesture and launch themselves instead.
  Widget _positioned(FallingWidget fallingWidget, Widget child) {
    final topLeft = widget.game.topLeftOf(fallingWidget);
    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: Transform.rotate(
        angle: fallingWidget.body.angle,
        child: SizedBox(
          width: fallingWidget.size.width,
          height: fallingWidget.size.height,
          child: GestureDetector(
            onTap: () => widget.game.launch(fallingWidget),
            child: child,
          ),
        ),
      ),
    );
  }
}
