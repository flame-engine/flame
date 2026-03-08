import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class UnifiedAnimationExample extends FlameGame {
  static const description = '''
This example demonstrates the Unified Animation Architecture 
managing multiple animation batches (Ember, Robot, Chopper) for maximum 
CPU and GPU efficiency.
  ''';

  UnifiedAnimationExample() : super(world: UnifiedAnimationWorld());

  final Random random = Random();
  late final TextComponent counter;

  // Animation types
  final List<UnifiedAnimationData> animationTypes = [];

  @override
  Future<void> onLoad() async {
    // 1. Setup Ember
    final emberAnimation = await loadSpriteAnimation(
      'animations/ember.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    );
    final emberBatch = await SpriteBatch.load('animations/ember.png');
    animationTypes.add(
      UnifiedAnimationData(
        name: 'Ember',
        ticker: emberAnimation.createTicker(),
        batch: emberBatch,
        size: Vector2.all(32),
      ),
    );

    // 2. Setup Robot
    final robotAnimation = await loadSpriteAnimation(
      'animations/robot.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(16, 18),
        stepTime: 0.1,
      ),
    );
    final robotBatch = await SpriteBatch.load('animations/robot.png');
    animationTypes.add(
      UnifiedAnimationData(
        name: 'Robot',
        ticker: robotAnimation.createTicker(),
        batch: robotBatch,
        size: Vector2(32, 36),
      ),
    );

    // 3. Setup Chopper
    final chopperAnimation = await loadSpriteAnimation(
      'animations/chopper.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(48, 48),
        stepTime: 0.05,
      ),
    );
    final chopperBatch = await SpriteBatch.load('animations/chopper.png');
    animationTypes.add(
      UnifiedAnimationData(
        name: 'Chopper',
        ticker: chopperAnimation.createTicker(),
        batch: chopperBatch,
        size: Vector2.all(64),
      ),
    );

    // Add Parent components for each type
    for (final data in animationTypes) {
      final isEmber = data.name == 'Ember';
      world.add(
        UnifiedAnimationParentComponent(
          spriteBatch: data.batch,
          ticker: data.ticker,
          depthSort: true,
          culling: true,
          blendMode: BlendMode.modulate,
          colorFilter: isEmber
              ? const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0, //
                  0.2126, 0.7152, 0.0722, 0, 0, //
                  0.2126, 0.7152, 0.0722, 0, 0, //
                  0, 0, 0, 1, 0, //
                ])
              : null,
        ),
      );
    }

    await camera.viewport.addAll([
      FpsTextComponent(
        position: size - Vector2(10, 50),
        anchor: Anchor.bottomRight,
      ),
      counter = TextComponent(
        position: size - Vector2(10, 25),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    ]);
  }

  @override
  void update(double dt) {
    var total = 0;
    for (final data in animationTypes) {
      data.ticker.update(dt);
      // We can find the parent component in world to get the count
      total += world.children
          .whereType<UnifiedAnimationParentComponent>()
          .firstWhere((p) => p.ticker == data.ticker)
          .positions
          .length;
    }
    super.update(dt);
    counter.text = 'Mega Entities: $total';
  }
}

class UnifiedAnimationData {
  UnifiedAnimationData({
    required this.name,
    required this.ticker,
    required this.batch,
    required this.size,
  });

  final String name;
  final SpriteAnimationTicker ticker;
  final SpriteBatch batch;
  final Vector2 size;
}

class UnifiedAnimationWorld extends World
    with TapCallbacks, HasGameReference<UnifiedAnimationExample> {
  final Random random = Random();

  @override
  void onTapDown(TapDownEvent event) {
    // Spawn 1000 of a random type
    final type =
        game.animationTypes[random.nextInt(game.animationTypes.length)];
    final parent = game.world.children
        .whereType<UnifiedAnimationParentComponent>()
        .firstWhere((p) => p.ticker == type.ticker);

    for (var i = 0; i < 1000; i++) {
      // Random velocity in range [-20, 20]
      final velocity = Vector2(
        (random.nextDouble() - 0.5) * 40,
        (random.nextDouble() - 0.5) * 40,
      );

      parent.addInstance(
        color: Colors.red,
        position: Vector2(
          (game.size.x / 2) *
              random.nextDouble() *
              (random.nextBool() ? 1 : -1),
          (game.size.y / 2) *
              random.nextDouble() *
              (random.nextBool() ? 1 : -1),
        ),
        size: type.size,
        velocity: velocity,
      );
    }
  }
}
