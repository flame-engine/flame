import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

class NavigatorGame extends FlameGame with HasTappableComponents {
  late final Navigator navigator;

  @override
  Future<void> onLoad() async {
    navigator = Navigator(
      pages: {
        'home': Page(builder: StartPageImpl.new),
        'level1': Level1Page(),
        'level2': Level2Page(),
        'pause': Page(builder: PausePageImpl.new, transparent: true),
      },
      initialPage: 'home',
    )..addToParent(this);
  }
}

class StartPageImpl extends Component with HasGameRef<NavigatorGame> {
  StartPageImpl() {
    _logo = TextPaint(
      style: const TextStyle(
        fontSize: 64,
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.w800,
      ),
    ).toTextPainter('Syzygy');
    _button1 = RoundedButton(
      text: 'Level 1',
      action: () => gameRef.navigator.showPage('level1'),
      color: const Color(0xffadde6c),
      borderColor: const Color(0xffedffab),
    );
    _button2 = RoundedButton(
      text: 'Level 2',
      action: () => gameRef.navigator.showPage('level2'),
      color: const Color(0xffdebe6c),
      borderColor: const Color(0xfffff4c7),
    );
    add(_button1);
    add(_button2);
  }

  late final TextPainter _logo;
  late Offset _logoOffset;
  late final RoundedButton _button1;
  late final RoundedButton _button2;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _logoOffset = Offset((size.x - _logo.width) / 2, size.y / 3 - _logo.height);
    _button1.position = Vector2(size.x / 2, _logoOffset.dy + 140);
    _button2.position = Vector2(size.x / 2, _logoOffset.dy + 200);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawColor(const Color(0xff063e67), BlendMode.src);
    _logo.paint(canvas, _logoOffset);
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

class BackButton extends SimpleButton with HasGameRef<NavigatorGame> {
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
  void action() => gameRef.navigator.popPage();
}

class PauseButton extends SimpleButton with HasGameRef<NavigatorGame> {
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
  void action() => gameRef.navigator.showPage('pause');
}

class Level1Page extends Page {
  @override
  Component build() => Level1PageImpl();

  @override
  void onDeactivate() => stopTime();
}

class Level2Page extends Page {
  @override
  Component build() => Level2PageImpl();

  @override
  void onDeactivate() => stopTime();
}

class Level1PageImpl extends Component {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0xbb5f358d)),
      BackButton(),
      PauseButton(),
      Planet(
        radius: 40,
        color: const Color(0xfffff188),
        position: game.size / 2,
        children: [
          Orbit(
            radius: 150,
            revolutionPeriod: 6,
            planet: Planet(
              radius: 15,
              color: const Color(0xff54d7b1),
              children: [
                Orbit(
                  radius: 40,
                  revolutionPeriod: 5,
                  planet: Planet(radius: 5, color: const Color(0xFFcccccc)),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }
}

class Level2PageImpl extends Component {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0xbb074825)),
      BackButton(),
      PauseButton(),
      Planet(
        radius: 30,
        color: const Color(0xFFFFFFff),
        position: game.size / 2,
        children: [
          Orbit(
            radius: 100,
            revolutionPeriod: 5,
            planet: Planet(
              radius: 15,
              color: const Color(0xffc9ce0d),
            ),
          ),
          Orbit(
            radius: 180,
            revolutionPeriod: 10,
            planet: Planet(
              radius: 20,
              color: const Color(0xfff32727),
              children: [
                Orbit(
                  radius: 32,
                  revolutionPeriod: 3,
                  planet: Planet(
                    radius: 6,
                    color: const Color(0xffffdb00),
                  ),
                ),
                Orbit(
                  radius: 45,
                  revolutionPeriod: 4,
                  planet: Planet(
                    radius: 4,
                    color: const Color(0xffdc00ff),
                  ),
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

class PausePageImpl extends Component
    with TapCallbacks, HasGameRef<NavigatorGame> {
  @override
  Future<void> onLoad() async {
    final game = findGame()!;
    addAll([
      Background(const Color(0x55000000)),
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
  void onTapUp(TapUpEvent event) => gameRef.navigator.popPage();
}
