import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/rendering.dart';

class RouterWorldExample extends FlameGame {
  static const description = '''
This example shows how to use the RouterComponent to navigate between
different worlds and pages.
''';

  late final RouterComponent router;

  @override
  Future<void> onLoad() async {
    add(
      router = RouterComponent(
        routes: {
          'home': Route(StartPage.new),
          'level1': WorldRoute(Level1Page.new),
          'level2': WorldRoute(Level2Page.new, maintainState: false),
          'pause': PauseRoute(),
        },
        initialRoute: 'home',
      ),
    );
  }
}

class StartPage extends Component with HasGameReference<RouterWorldExample> {
  StartPage() {
    addAll([
      _logo = TextComponent(
        text: 'Your Game',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 64,
            color: Color(0xFFC8FFF5),
            fontWeight: FontWeight.w800,
          ),
        ),
        anchor: Anchor.center,
      ),
      _button1 = RoundedButton(
        text: 'Level 1',
        action: () => game.router.pushNamed('level1'),
        color: const Color(0xffadde6c),
        borderColor: const Color(0xffedffab),
      ),
      _button2 = RoundedButton(
        text: 'Level 2',
        action: () => game.router.pushNamed('level2'),
        color: const Color(0xffdebe6c),
        borderColor: const Color(0xfffff4c7),
      ),
    ]);
  }

  late final TextComponent _logo;
  late final RoundedButton _button1;
  late final RoundedButton _button2;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _logo.position = Vector2(size.x / 2, size.y / 3);
    _button1.position = Vector2(size.x / 2, _logo.y + 80);
    _button2.position = Vector2(size.x / 2, _logo.y + 140);
  }
}

class Background extends Component {
  Background(this.color);
  final Color color;

  @override
  void render(Canvas canvas) {
    canvas.drawColor(color, BlendMode.srcATop);
  }
}

class RoundedButton extends PositionComponent with TapCallbacks {
  RoundedButton({
    required this.text,
    required this.action,
    required Color color,
    required Color borderColor,
    super.position,
    super.anchor = Anchor.center,
  }) : _textDrawable = TextPaint(
         style: const TextStyle(
           fontSize: 20,
           color: Color(0xFF000000),
           fontWeight: FontWeight.w800,
         ),
       ).toTextPainter(text) {
    size = Vector2(150, 40);
    _textOffset = Offset(
      (size.x - _textDrawable.width) / 2,
      (size.y - _textDrawable.height) / 2,
    );
    _rrect = RRect.fromLTRBR(0, 0, size.x, size.y, Radius.circular(size.y / 2));
    _bgPaint = Paint()..color = color;
    _borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = borderColor;
  }

  final String text;
  final void Function() action;
  final TextPainter _textDrawable;
  late final Offset _textOffset;
  late final RRect _rrect;
  late final Paint _borderPaint;
  late final Paint _bgPaint;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_rrect, _bgPaint);
    canvas.drawRRect(_rrect, _borderPaint);
    _textDrawable.paint(canvas, _textOffset);
  }

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(1.05);
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    action();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }
}

abstract class SimpleButton extends PositionComponent with TapCallbacks {
  SimpleButton(this._iconPath, {super.position}) : super(size: Vector2.all(40));

  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0x66ffffff);
  final Paint _iconPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xffaaaaaa)
    ..strokeWidth = 7;
  final Path _iconPath;

  void action();

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      _borderPaint,
    );
    canvas.drawPath(_iconPath, _iconPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _iconPaint.color = const Color(0xffffffff);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _iconPaint.color = const Color(0xffaaaaaa);
    action();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _iconPaint.color = const Color(0xffaaaaaa);
  }
}

class BackButton extends SimpleButton
    with HasGameReference<RouterWorldExample> {
  BackButton()
    : super(
        Path()
          ..moveTo(22, 8)
          ..lineTo(10, 20)
          ..lineTo(22, 32)
          ..moveTo(12, 20)
          ..lineTo(34, 20),
        position: Vector2.all(10),
      );

  @override
  void action() => game.router.pop();
}

class PauseButton extends SimpleButton
    with HasGameReference<RouterWorldExample> {
  PauseButton()
    : super(
        Path()
          ..moveTo(14, 10)
          ..lineTo(14, 30)
          ..moveTo(26, 10)
          ..lineTo(26, 30),
        position: Vector2(60, 10),
      );

  bool isPaused = false;

  @override
  void action() {
    if (isPaused) {
      game.router.pop();
    } else {
      game.router.pushNamed('pause');
    }
    isPaused = !isPaused;
  }
}

class Level1Page extends DecoratedWorld with HasGameReference {
  @override
  Future<void> onLoad() async {
    addAll([
      Background(const Color(0xbb2a074f)),
      Planet(
        radius: 25,
        color: const Color(0xfffff188),
        children: [
          Orbit(
            radius: 110,
            revolutionPeriod: 6,
            planet: Planet(
              radius: 10,
              color: const Color(0xff54d7b1),
              children: [
                Orbit(
                  radius: 25,
                  revolutionPeriod: 5,
                  planet: Planet(radius: 3, color: const Color(0xFFcccccc)),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  final hudComponents = <Component>[];

  @override
  void onMount() {
    hudComponents.addAll([
      BackButton(),
      PauseButton(),
    ]);
    game.camera.viewport.addAll(hudComponents);
  }

  @override
  void onRemove() {
    game.camera.viewport.removeAll(hudComponents);
    super.onRemove();
  }
}

class Level2Page extends DecoratedWorld with HasGameReference {
  @override
  Future<void> onLoad() async {
    addAll([
      Background(const Color(0xff052b44)),
      Planet(
        radius: 30,
        color: const Color(0xFFFFFFff),
        children: [
          Orbit(
            radius: 60,
            revolutionPeriod: 5,
            planet: Planet(radius: 10, color: const Color(0xffc9ce0d)),
          ),
          Orbit(
            radius: 110,
            revolutionPeriod: 10,
            planet: Planet(
              radius: 14,
              color: const Color(0xfff32727),
              children: [
                Orbit(
                  radius: 26,
                  revolutionPeriod: 3,
                  planet: Planet(radius: 5, color: const Color(0xffffdb00)),
                ),
                Orbit(
                  radius: 35,
                  revolutionPeriod: 4,
                  planet: Planet(radius: 3, color: const Color(0xffdc00ff)),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  final hudComponents = <Component>[];

  @override
  void onMount() {
    hudComponents.addAll([
      BackButton(),
      PauseButton(),
    ]);
    game.camera.viewport.addAll(hudComponents);
  }

  @override
  void onRemove() {
    game.camera.viewport.removeAll(hudComponents);
    super.onRemove();
  }
}

class Planet extends CircleComponent
    with TapCallbacks, HasGameReference<RouterWorldExample> {
  Planet({
    required super.radius,
    required Color color,
    super.children,
  }) : super(paint: Paint()..color = color, anchor: Anchor.center);

  @override
  void onTapDown(TapDownEvent event) {
    game.router.pushAndWait(YesNoDialog()).then((shouldRemove) {
      if (shouldRemove) {
        removeFromParent();
      }
    });
  }
}

class Orbit extends CircleComponent {
  Orbit({
    required super.radius,
    required this.planet,
    required this.revolutionPeriod,
  }) : super(
         children: [planet],
         anchor: Anchor.center,
         paint: Paint()
           ..style = PaintingStyle.stroke
           ..color = const Color(0x888888aa),
       );

  final double revolutionPeriod;
  final Planet planet;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (parent is Planet) {
      position = Vector2.all((parent! as Planet).radius);
    }
    planet.position.x = size.x;
    planet.position.y = size.y / 2;
    planet.add(
      RotateAroundEffect(
        tau,
        EffectController(duration: revolutionPeriod, infinite: true),
        center: size / 2,
      ),
    );
  }
}

class PauseRoute extends Route {
  PauseRoute() : super(PausePage.new, transparent: true);

  @override
  void onPush(Route? previousRoute) {
    if (previousRoute is WorldRoute && previousRoute.world is DecoratedWorld) {
      (previousRoute.world! as DecoratedWorld).timeScale = 0;
      (previousRoute.world! as DecoratedWorld).decorator =
          PaintDecorator.grayscale(opacity: 0.5)..addBlur(3.0);
    }
  }

  @override
  void onPop(Route nextRoute) {
    if (nextRoute is WorldRoute && nextRoute.world is DecoratedWorld) {
      (nextRoute.world! as DecoratedWorld).timeScale = 1;
      (nextRoute.world! as DecoratedWorld).decorator = null;
    }
  }
}

class PausePage extends Component
    with TapCallbacks, HasGameReference<RouterWorldExample> {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      TextComponent(
        text: 'PAUSED',
        position: game.canvasSize / 2,
        anchor: Anchor.center,
        children: [
          ScaleEffect.to(
            Vector2.all(1.1),
            EffectController(
              duration: 0.3,
              alternate: true,
              infinite: true,
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) => game.router.pop();
}

class DecoratedWorld extends World with HasTimeScale {
  PaintDecorator? decorator;

  @override
  void renderFromCamera(Canvas canvas) {
    if (decorator == null) {
      super.renderFromCamera(canvas);
    } else {
      decorator!.applyChain(super.renderFromCamera, canvas);
    }
  }
}

class YesNoDialog extends ValueRoute<bool> {
  YesNoDialog() : super(value: false);

  @override
  Component build() {
    final gameSize = findGame()!.size;
    const margin = 10.0;
    final boxSize = Vector2(350, 100);
    return PositionComponent(
      position: Vector2(gameSize.x / 2, margin),
      size: boxSize,
      anchor: Anchor.topCenter,
      children: [
        RectangleComponent(
          size: boxSize,
          paint: Paint()..color = const Color(0xFFAA0000),
        ),
        TextComponent(
          position: Vector2.all(margin),
          text: 'Remove the planet?',
        ),
        RoundedButton(
          text: 'Yes',
          action: () => completeWith(true),
          color: Colors.green,
          borderColor: Colors.white,
          position: Vector2(boxSize.x / 4, boxSize.y - 30),
        ),
        RoundedButton(
          text: 'No',
          action: () => completeWith(false),
          color: Colors.red,
          borderColor: Colors.white,
          position: Vector2(boxSize.x * 0.75, boxSize.y - 30),
        ),
      ],
    );
  }
}
