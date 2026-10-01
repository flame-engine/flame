part of 'river_game.dart';

/// The instrument panel along the bottom: the score, the fuel gauge, the
/// jets in reserve, and a line across the middle when there is something
/// to say.
///
/// **The one thing Flame draws.** Everything above the panel is the 3D
/// layer showing through the transparent game; this component sits in
/// Flame's own viewport and paints with Flame's own canvas.
final class RiverHud extends PositionComponent with HasGameRef<RiverGame> {
  static const double panelHeight = 78.0;
  static const String _keysHelp =
      'Space to fly and fire, arrows or WASD to steer';
  static const double _gaugeWidth = 200.0;
  static const double _gaugeHeight = 22.0;

  static const List<Shadow> _shadow = <Shadow>[
    Shadow(blurRadius: 4.0, color: Color(0xAA000000)),
  ];

  final TextPaint _score = TextPaint(
    style: const TextStyle(
      color: Color(0xFFF4D35E),
      fontSize: 26.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 3.0,
    ),
  );

  final TextPaint _label = TextPaint(
    style: const TextStyle(
      color: Color(0xFFE8E8E8),
      fontSize: 13.0,
      fontWeight: FontWeight.w700,
    ),
  );

  final TextPaint _banner = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.0,
      shadows: _shadow,
    ),
  );

  final TextPaint _detail = TextPaint(
    style: const TextStyle(
      color: Color(0xFFF0F0F0),
      fontSize: 15.0,
      height: 1.4,
      shadows: _shadow,
    ),
  );

  /// A line of the task that is done.
  final TextPaint _done = TextPaint(
    style: const TextStyle(
      color: Color(0xFF7CE38B),
      fontSize: 13.0,
      fontWeight: FontWeight.w700,
      shadows: _shadow,
    ),
  );

  final Paint _panel = Paint()..color = const Color(0xE0202428);
  final Paint _rule = Paint()..color = const Color(0xFF8A8F94);
  final Paint _dial = Paint()..color = const Color(0xFF101214);
  final Paint _frame = Paint()
    ..color = const Color(0xFFE8E8E8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  final Paint _needle = Paint();
  final Paint _jet = Paint()..color = const Color(0xFFF4D35E);

  double _clock = 0.0;

  /// On for a quarter of a second, off for the next: the rate the low-fuel
  /// warning and the needle blink at.
  bool get _blink => (_clock * 4.0).floor().isEven;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!gameRef.built) {
      return;
    }
    final width = size.x;
    final top = size.y - panelHeight;
    final run = gameRef.run;

    canvas
      ..drawRect(Rect.fromLTWH(0.0, top, width, panelHeight), _panel)
      ..drawRect(Rect.fromLTWH(0.0, top, width, 3.0), _rule);

    _score.render(
      canvas,
      '${run.score}',
      Vector2(width / 2.0, top + 8.0),
      anchor: Anchor.topCenter,
    );

    // The gauge: E, a half and F, and a needle that goes red and blinks
    // below a quarter of a tank.
    final left = width / 2.0 - _gaugeWidth / 2.0;
    final gaugeTop = top + 44.0;
    final dial = Rect.fromLTWH(left, gaugeTop, _gaugeWidth, _gaugeHeight);
    canvas
      ..drawRect(dial, _dial)
      ..drawRect(dial, _frame);
    for (final (mark, at) in <(String, double)>[
      ('E', 0.07),
      ('½', 0.5),
      ('F', 0.93),
    ]) {
      _label.render(
        canvas,
        mark,
        Vector2(left + _gaugeWidth * at, gaugeTop + _gaugeHeight / 2.0),
        anchor: Anchor.center,
      );
    }
    final low = run.fuelLow;
    _needle.color = low ? const Color(0xFFFF4B3E) : const Color(0xFFF4D35E);
    if (!low || _blink) {
      final x = left + 10.0 + (_gaugeWidth - 20.0) * run.fuel;
      canvas.drawRect(
        Rect.fromLTWH(x - 2.0, gaugeTop - 4.0, 4.0, _gaugeHeight + 8.0),
        _needle,
      );
    }

    // A small jet for each one in reserve, to the left of the gauge.
    for (var i = 0; i < math.min(run.reserve, 6); i++) {
      final cx = left - 22.0 - i * 20.0;
      final cy = gaugeTop + _gaugeHeight / 2.0;
      canvas.drawPath(
        Path()
          ..moveTo(cx, cy - 8.0)
          ..lineTo(cx + 7.0, cy + 6.0)
          ..lineTo(cx, cy + 3.0)
          ..lineTo(cx - 7.0, cy + 6.0)
          ..close(),
        _jet,
      );
    }

    // Which bridge of the level this is, and a word while a depot fills the
    // tank.
    final stage = gameRef.stage;
    final section = gameRef.course.sectionIndexAt(gameRef.distance);
    final bridges = stage.index == campaign.length - 1
        ? 'BRIDGE ${section - stage.first + 1}'
        : 'BRIDGE ${section - stage.first + 1} / ${stage.level.bridges}';
    _label.render(
      canvas,
      gameRef.refuelling ? 'REFUELLING' : bridges,
      Vector2(left + _gaugeWidth + 18.0, gaugeTop + _gaugeHeight / 2.0),
      anchor: Anchor.centerLeft,
    );

    _renderOrders(canvas, stage);

    final trigger = gameRef.touch ? 'FIRE' : 'SPACE';
    final message = switch (gameRef.phase) {
      Phase.ready => (
        'LEVEL ${stage.index + 1}  ·  ${stage.level.name.toUpperCase()}',
        '${stage.level.briefing}\n'
            '${gameRef.touch ? 'Press fire to fly' : _keysHelp}',
      ),
      Phase.over => ('GAME OVER', '$trigger to fly again'),
      _ when gameRef.banner != null => (gameRef.banner!, null),
      Phase.flying when low && _blink => ('LOW FUEL', null),
      Phase.flying || Phase.crashed => null,
    };
    if (message != null) {
      final (headline, detail) = message;
      _banner.render(
        canvas,
        headline,
        Vector2(width / 2.0, top * 0.38),
        anchor: Anchor.center,
      );
      if (detail != null) {
        _detail.render(
          canvas,
          detail,
          Vector2(width / 2.0, top * 0.38 + 26.0),
          anchor: Anchor.topCenter,
        );
      }
    }
  }

  /// The level and what is left of its task, top left.
  void _renderOrders(Canvas canvas, Stage stage) {
    final level = stage.level;
    _label.render(
      canvas,
      'LEVEL ${stage.index + 1}  ${level.name.toUpperCase()}',
      Vector2(16.0, 16.0),
    );
    var y = 36.0;
    for (final MapEntry(key: kind, value: wanted) in level.task.entries) {
      final done = wanted - gameRef.run.stillWanted(level, kind);
      final paint = done >= wanted ? _done : _label;
      paint.render(
        canvas,
        '${RiverGame._plural(kind)}  $done / $wanted',
        Vector2(16.0, y),
      );
      y += 18.0;
    }
  }
}
