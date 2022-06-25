import 'package:flame/components.dart';
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
      },
      initialPage: 'home',
    )..addToParent(this);
  }
}

class StartPageImpl extends Component with HasGameRef<NavigatorGame> {
  StartPageImpl()
      : _logo = TextPaint(
          style: const TextStyle(
            fontSize: 64,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w800,
          ),
        ).toTextPainter('Syzygy'),
        _button1 = RoundedButton(
          text: 'Level 1',
          action: () {},
          color: const Color(0xffadde6c),
          borderColor: const Color(0xffedffab),
        ),
        _button2 = RoundedButton(
          text: 'Level 2',
          action: () {},
          color: const Color(0xffdebe6c),
          borderColor: const Color(0xfffff4c7),
        ) {
    add(_button1);
    add(_button2);
  }

  final TextPainter _logo;
  late Offset _logoOffset;
  final RoundedButton _button1;
  final RoundedButton _button2;

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
