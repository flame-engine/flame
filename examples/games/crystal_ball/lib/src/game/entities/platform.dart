import 'dart:async';
import 'dart:math';

import 'package:crystal_ball/src/game/components/rarity_list.dart';
import 'package:crystal_ball/src/game/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

enum PlatformColor {
  green._(
    rarity: 600,
    gradient: [Color(0xFF00FF00), Color(0xFF00FF7F)],
  ),
  blue._(
    rarity: 250,
    gradient: [Color(0xFF00BFFF), Color(0xFF00FFFF)],
  ),
  orange._(
    rarity: 80,
    gradient: [Color(0xFFFD7001), Color(0xFFFDAB42)],
  ),
  red._(
    rarity: 44,
    gradient: [Color(0xFFFF3403), Color(0xFFFD2B9B)],
  ),
  purple._(
    rarity: 25,
    gradient: [Color(0xFF8B00FF), Color(0xFFCD00FF)],
  ),
  golden._(
    rarity: 1,
    gradient: [Color(0xFFFFFFF6), Color(0xFFFFD700)],
  ),
  ;

  const PlatformColor._({
    required this.gradient,
    required this.rarity,
  });

  final List<Color> gradient;
  final int rarity;

  static PlatformColor random(Random random) =>
      values[random.nextInt(values.length)];

  static PlatformColor rarityRandom(Random random) {
    final rarities = values.map((e) => Rarity(e, e.rarity));
    return RarityList(rarities.toList()).getRandom(random);
  }
}

class Platform extends PositionComponent
    with HasGameReference<CrystalBallGame> {
  Platform({
    required Vector2 super.position,
    required Vector2 super.size,
    required this.color,
    required this.random,
  }) : super(
          anchor: Anchor.center,
          priority: 1000,
          children: [
            RectangleHitbox(),
            RectangleHitbox(
              position: Vector2(0, 10),
              size: size,
            ),
            RectangleHitbox(
              position: Vector2(0, 20),
              size: size,
            ),
            RectangleHitbox(
              position: Vector2(0, 30),
              size: size,
            ),
          ],
        );

  final Random random;

    @override
  bool get debugMode => true;

  late final List<Color> gradient = () {
    if (random.nextBool()) {
      return color.gradient.reversed.toList();
    }
    return color.gradient;
  }();

  final PlatformColor color;

  double initialGlowGama = 10;
  double glowGama = 0;

  final effectController = CurvedEffectController(
    0.4,
    Curves.easeInOut,
  )..setToEnd();
  late final glowEffect = PlatformGamaEffect(20, effectController);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(glowEffect);
    height = 40;
  }

  @override
  void onMount() {
    super.onMount();
    scheduleMicrotask(() {
      glowTo(
        to: initialGlowGama,
        duration: 0.3,
      );
    });
  }

  void glowTo({
    required double to,
    double duration = 0.1,
  }) {
    effectController.duration = duration;

    glowEffect._change(to: to);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (y > game.world.reaper.y) {
      removeFromParent();
    }
  }
}

class PlatformGamaEffect extends Effect with EffectTarget<Platform> {
  PlatformGamaEffect(this._to, super.controller);

  @override
  void onMount() {
    super.onMount();
    _from = target.glowGama;
  }

  double _to;
  late double _from;

  @override
  bool get removeOnFinish => false;

  @override
  void apply(double progress) {
    final delta = _to - _from;
    final position = _from + delta * progress;
    target.glowGama = position;
  }

  void _change({required double to}) {
    reset();

    _to = to;
    _from = target.glowGama;
  }
}
