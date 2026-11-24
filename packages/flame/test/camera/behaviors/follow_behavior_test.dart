import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FollowBehavior', () {
    test('basic properties', () {
      final target = PositionComponent();
      final owner = PositionComponent();
      final behavior = FollowBehavior(target: target, owner: owner);
      expect(behavior.target, target);
      expect(behavior.owner, owner);
      expect(behavior.maxSpeed, double.infinity);
      expect(behavior.horizontalOnly, false);
      expect(behavior.verticalOnly, false);
    });

    test('errors', () {
      expect(
        () => FollowBehavior(target: PositionComponent(), maxSpeed: 0),
        failsAssert('maxSpeed must be positive: 0.0'),
      );
      expect(
        () => FollowBehavior(target: PositionComponent(), maxSpeed: -2.45),
        failsAssert('maxSpeed must be positive: -2.45'),
      );
      expect(
        () => FollowBehavior(
          target: PositionComponent(),
          horizontalOnly: true,
          verticalOnly: true,
        ),
        failsAssert(
          'The behavior cannot be both horizontalOnly and verticalOnly',
        ),
      );
    });

    testWithFlameGame('parent is not position provider', (game) async {
      final target = PositionComponent()..addToParent(game);
      final component = Component()..addToParent(game);
      await game.ready();

      expect(
        () async {
          component.add(FollowBehavior(target: target));
          await game.ready();
        },
        failsAssert('Can only apply this behavior to a PositionProvider'),
      );
    });

    testWithFlameGame('custom position provider', (game) async {
      final target = PositionComponent()
        ..position = Vector2(3, 100)
        ..addToParent(game);
      final component = Component()..addToParent(game);
      await game.ready();

      final followTarget = Vector2(3, 1);
      component.add(
        FollowBehavior(
          target: target,
          owner: PositionProviderImpl(
            getValue: () => followTarget,
            setValue: followTarget.setFrom,
          ),
          maxSpeed: 1,
        ),
      );
      await game.ready();

      const dt = 0.11;
      for (var i = 0; i < 20; i++) {
        final value = Vector2(3, 1 + i * dt);
        final tolerance = toleranceVector2Float32(value);
        expect(followTarget, closeToVector(value, tolerance));
        game.update(dt);
      }
    });

    testWithFlameGame('simple follow', (game) async {
      final target = PositionComponent()..addToParent(game);
      final pursuer = PositionComponent()
        ..add(FollowBehavior(target: target))
        ..addToParent(game);
      await game.ready();

      for (var i = 0; i < 10; i++) {
        target.position = Vector2.random()..scale(1000);
        // The key here is to make sure you check the tolerance of the pursuer
        // position before the update, because the error may be higher if e.g.
        // the pursuer was at a location with a large value.
        final tolerancePursuer = toleranceVector2Float32(pursuer.position);
        final toleranceTarget = toleranceVector2Float32(target.position);
        game.update(0.01);
        final tolerance = tolerancePursuer + toleranceTarget;
        expect(
          pursuer.position,
          closeToVector(target.position, tolerance),
        );
      }
    });

    testWithFlameGame('follow with max speed', (game) async {
      const dt = 0.013;
      const speed = 587.0;
      final target = PositionComponent()
        ..position = Vector2(600, 800)
        ..addToParent(game);
      final pursuer = PositionComponent()
        ..add(FollowBehavior(target: target, maxSpeed: speed))
        ..addToParent(game);
      await game.ready();
      var tolerance = toleranceVector2Float32(pursuer.position);
      for (var i = 0; i < 100; i++) {
        final distance = speed * i * dt;
        final value = Vector2(distance * 0.6, distance * 0.8);
        tolerance += toleranceVector2Float32(value);
        expect(
          pursuer.position,
          closeToVector(value, tolerance),
        );
        game.update(dt);
      }
    });

    testWithFlameGame('horizontal-only follow', (game) async {
      final target = PositionComponent(position: Vector2(20, 10));
      final pursuer = PositionComponent();
      pursuer.add(
        FollowBehavior(target: target, horizontalOnly: true, maxSpeed: 1),
      );
      game.addAll([target, pursuer]);
      await game.ready();

      for (var i = 0; i < 10; i++) {
        expect(pursuer.position.x, i);
        expect(pursuer.position.y, 0);
        game.update(1);
      }
    });

    testWithFlameGame('vertical-only follow', (game) async {
      final target = PositionComponent(position: Vector2(20, 100));
      final pursuer = PositionComponent();
      pursuer.add(
        FollowBehavior(target: target, verticalOnly: true, maxSpeed: 1),
      );
      game.addAll([target, pursuer]);
      await game.ready();

      for (var i = 0; i < 10; i++) {
        expect(pursuer.position.x, 0);
        expect(pursuer.position.y, i);
        game.update(1);
      }
    });

    group('when the target and the owner have different parents', () {
      testWithFlameGame('follows a nested target', (game) async {
        final container = PositionComponent(
          position: Vector2(100, 50),
          scale: Vector2.all(2),
          angle: pi / 2,
        )..addToParent(game);
        final target = PositionComponent(position: Vector2(20, 30))
          ..addToParent(container);
        final pursuer = PositionComponent()
          ..add(FollowBehavior(target: target))
          ..addToParent(game);
        await game.ready();

        game.update(0.01);
        // (20, 30) scaled by 2 and turned by a quarter turn is (-60, 40).
        expect(pursuer.position, closeToVector(Vector2(40, 90), 1e-4));
      });

      testWithFlameGame('follows a target from a nested owner', (game) async {
        final target = PositionComponent(position: Vector2(300, 200))
          ..addToParent(game);
        final container = PositionComponent(position: Vector2(100, 50))
          ..addToParent(game);
        final pursuer = PositionComponent()
          ..add(FollowBehavior(target: target))
          ..addToParent(container);
        await game.ready();

        game.update(0.01);
        expect(pursuer.position, Vector2(200, 150));
        expect(pursuer.absolutePosition, target.absolutePosition);
      });

      testWithFlameGame(
        'follows a target within the same nested parent',
        (game) async {
          final container = PositionComponent(position: Vector2(100, 50))
            ..addToParent(game);
          final target = PositionComponent(position: Vector2(20, 30))
            ..addToParent(container);
          final pursuer = PositionComponent()
            ..add(FollowBehavior(target: target))
            ..addToParent(container);
          await game.ready();

          game.update(0.01);
          expect(pursuer.position, Vector2(20, 30));
        },
      );

      testWithFlameGame(
        'follows a target nested deeper in the parent of the owner',
        (game) async {
          final container = PositionComponent(position: Vector2(100, 50))
            ..addToParent(game);
          final group = PositionComponent(
            position: Vector2(10, 10),
            scale: Vector2.all(2),
          )..addToParent(container);
          final target = PositionComponent(position: Vector2(20, 30))
            ..addToParent(group);
          final pursuer = PositionComponent()
            ..add(FollowBehavior(target: target))
            ..addToParent(container);
          await game.ready();

          game.update(0.01);
          expect(pursuer.position, Vector2(50, 70));
          expect(pursuer.absolutePosition, target.absolutePosition);
        },
      );

      testWithFlameGame(
        'follows a target in another branch of a transformed ancestor',
        (game) async {
          final level = PositionComponent(
            position: Vector2(100, 100),
            scale: Vector2.all(2),
            angle: pi / 3,
          )..addToParent(game);
          final targetGroup = PositionComponent(
            position: Vector2(10, 20),
            angle: -pi / 4,
          )..addToParent(level);
          final pursuerGroup = PositionComponent(
            position: Vector2(-30, 40),
            scale: Vector2.all(0.5),
          )..addToParent(level);
          final target = PositionComponent(position: Vector2(25, -15))
            ..addToParent(targetGroup);
          final pursuer = PositionComponent()
            ..add(FollowBehavior(target: target))
            ..addToParent(pursuerGroup);
          await game.ready();

          game.update(0.01);
          expect(
            pursuer.absolutePosition,
            closeToVector(target.absolutePosition, 1e-3),
          );
        },
      );

      testWithFlameGame(
        'follows a target with a different parent at a zero scale',
        (game) async {
          final target = PositionComponent(position: Vector2(300, 200))
            ..addToParent(game);
          final container = PositionComponent(position: Vector2(100, 50))
            ..addToParent(game);
          // A follower that scales in from zero, e.g. with a ScaleEffect.
          final pursuer = PositionComponent(scale: Vector2.zero())
            ..add(FollowBehavior(target: target))
            ..addToParent(container);
          await game.ready();

          game.update(0.01);
          expect(pursuer.position, Vector2(200, 150));
        },
      );

      testWithFlameGame(
        'follows a nested target with a custom owner',
        (game) async {
          final container = PositionComponent(position: Vector2(100, 50))
            ..addToParent(game);
          final target = PositionComponent(position: Vector2(20, 30))
            ..addToParent(container);
          final ownerPosition = Vector2.zero();
          final owner = PositionProviderImpl(
            getValue: () => ownerPosition,
            setValue: ownerPosition.setFrom,
          );
          game.add(FollowBehavior(target: target, owner: owner));
          await game.ready();

          game.update(0.01);
          expect(ownerPosition, Vector2(120, 80));
        },
      );

      testWithFlameGame('moves at max speed towards a nested target', (
        game,
      ) async {
        final container = PositionComponent(position: Vector2(100, 50))
          ..addToParent(game);
        final target = PositionComponent(position: Vector2(200, 350))
          ..addToParent(container);
        final pursuer = PositionComponent()
          ..add(FollowBehavior(target: target, maxSpeed: 50))
          ..addToParent(game);
        await game.ready();

        // The target is at (300, 400), which is 500 units away.
        game.update(1);
        expect(pursuer.position, closeToVector(Vector2(30, 40), 1e-4));
      });
    });
  });
}
