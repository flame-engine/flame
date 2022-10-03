import 'dart:math';
import 'dart:ui';

import 'package:doc_flame_examples/router.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class ValueRouteExample extends FlameGame with HasTappableComponents {
  late final RouterComponent router;

  @override
  Future<void> onLoad() async {
    router = RouterComponent(
      routes: {'home': Route(HomePage.new)},
      initialRoute: 'home',
    );
    add(router);
  }
}

class HomePage extends Component with HasGameReference<ValueRouteExample> {
  @override
  Future<void> onLoad() async {
    add(
      RoundedButton(
        text: 'Rate me',
        action: () async {
          final score = await game.router.pushAndWait(RateRoute());
          firstChild<TextComponent>()!.text = 'Score: $score';
        },
        color: const Color(0xff758f9a),
        borderColor: const Color(0xff60d5ff),
      )..position = game.size / 2,
    );
    add(
      TextComponent(
        text: 'Score: –',
        anchor: Anchor.topCenter,
        position: game.size / 2 + Vector2(0, 30),
        scale: Vector2.all(0.7),
      ),
    );
  }
}

class RateRoute extends ValueRoute<int>
    with HasGameReference<ValueRouteExample> {
  RateRoute() : super(value: -1, transparent: true);

  @override
  Component build() {
    final size = Vector2(250, 130);
    const radius = 18.0;
    final starGap = (size.x - 5 * 2 * radius) / 6;
    return RectangleComponent(
      position: game.size / 2,
      size: size,
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xee858585),
      children: [
        RoundedButton(
          text: 'Ok',
          action: () {
            completeWith(
              descendants().where((c) => c is Star && c.active).length,
            );
          },
          color: const Color(0xFFFFFFFF),
          borderColor: const Color(0xFF000000),
        )..position = Vector2(size.x / 2, 100),
        for (var i = 0; i < 5; i++)
          Star(
            value: i + 1,
            radius: radius,
            position: Vector2(starGap * (i + 1) + radius * (2 * i + 1), 40),
          ),
      ],
    );
  }
}

class Star extends PositionComponent with TapCallbacks {
  Star({required this.value, required this.radius, super.position})
      : super(size: Vector2.all(2 * radius), anchor: Anchor.center);

  final int value;
  final double radius;
  final Path path = Path();
  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xffffe395)
    ..strokeWidth = 2;
  final Paint fillPaint = Paint()..color = const Color(0xffffe395);
  bool active = false;

  @override
  Future<void> onLoad() async {
    path.moveTo(radius, 0);
    for (var i = 0; i < 5; i++) {
      path.lineTo(
        radius + 0.6 * radius * sin(tau / 5 * (i + 0.5)),
        radius - 0.6 * radius * cos(tau / 5 * (i + 0.5)),
      );
      path.lineTo(
        radius + radius * sin(tau / 5 * (i + 1)),
        radius - radius * cos(tau / 5 * (i + 1)),
      );
    }
    path.close();
  }

  @override
  void render(Canvas canvas) {
    if (active) {
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    var on = true;
    for (final star in parent!.children.whereType<Star>()) {
      star.active = on;
      if (star == this) {
        on = false;
      }
    }
  }
}

const tau = pi * 2;
