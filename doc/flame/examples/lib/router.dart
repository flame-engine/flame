import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/rendering.dart';

class RouterGame extends FlameGame with HasTappableComponents {
  late final RouterComponent router;

  @override
  Future<void> onLoad() async {
    add(
      router = RouterComponent(
        routes: {
          'splash': Route(SplashScreenPage.new),
          'home': Route(StartPage.new),
          'level1': Route(Level1Page.new),
          'level2': Route(Level2Page.new),
          'pause': PauseRoute(),
        },
        initialRoute: 'splash',
      ),
    );
  }
}

class SplashScreenPage extends Component
    with TapCallbacks, HasGameRef<RouterGame> {
  @override
  Future<void> onLoad() async {
    addAll([
      Background(const Color(0xff282828)),
      TextBoxComponent(
        text: '[Router demo]',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0x66ffffff),
            fontSize: 16,
          ),
        ),
        align: Anchor.center,
        size: gameRef.canvasSize,
      ),
    ]);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) => gameRef.router.pushNamed('home');
}

class StartPage extends Component with HasGameRef<RouterGame> {
  StartPage() {
    addAll([
      _logo = TextComponent(
        text: 'Syzygy',
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
        action: () => gameRef.router.pushNamed('level1'),
        color: const Color(0xffadde6c),
        borderColor: const Color(0xffedffab),
      ),
      _button2 = RoundedButton(
        text: 'Level 2',
        action: () => gameRef.router.pushNamed('level2'),
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

class BackButton extends SimpleButton with HasGameRef<RouterGame> {
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
  void action() => gameRef.router.pop();
}

class PauseButton extends SimpleButton with HasGameRef<RouterGame> {
  PauseButton()
      : super(
          Path()
            ..moveTo(14, 10)
            ..lineTo(14, 30)
            ..moveTo(26, 10)
            ..lineTo(26, 30),
          position: Vector2(60, 10),
        );
  @override
  void action() => gameRef.router.pushNamed('pause');
}

class Level1Page extends Component {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0xbb2a074f)),
      BackButton(),
      PauseButton(),
      Planet(
        radius: 25,
        color: const Color(0xfffff188),
        position: game.size / 2,
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
}

class Level2Page extends Component {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0xff052b44)),
      BackButton(),
      PauseButton(),
      Planet(
        radius: 30,
        color: const Color(0xFFFFFFff),
        position: game.size / 2,
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
}

class Planet extends PositionComponent {
  Planet({
    required this.radius,
    required this.color,
    super.position,
    super.children,
  }) : _paint = Paint()..color = color;

  final double radius;
  final Color color;
  final Paint _paint;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _paint);
  }
}

class Orbit extends PositionComponent {
  Orbit({
    required this.radius,
    required this.planet,
    required this.revolutionPeriod,
    double initialAngle = 0,
  })  : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x888888aa),
        _angle = initialAngle {
    add(planet);
  }

  final double radius;
  final double revolutionPeriod;
  final Planet planet;
  final Paint _paint;
  double _angle;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _paint);
  }

  @override
  void update(double dt) {
    _angle += dt / revolutionPeriod * Transform2D.tau;
    planet.position = Vector2(radius, 0)..rotate(_angle);
  }
}

class PauseRoute extends Route {
  PauseRoute() : super(PausePage.new, transparent: true);

  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime()
      ..addRenderEffect(
        PaintDecorator.grayscale(opacity: 0.5)..addBlur(3.0),
      );
  }

  @override
  void onPop(Route previousRoute) {
    previousRoute
      ..resumeTime()
      ..removeRenderEffect();
  }
}

class PausePage extends Component with TapCallbacks, HasGameRef<RouterGame> {
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
          )
        ],
      ),
    ]);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) => gameRef.router.pop();
}
