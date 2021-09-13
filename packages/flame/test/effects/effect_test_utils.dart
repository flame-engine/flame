import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/test.dart';
import 'package:flutter_test/flutter_test.dart';

class Callback {
  int calledNumber = 0;
  bool get isCalledOnce => calledNumber == 1;

  void call() => calledNumber++;
}

void effectTest(
  WidgetTester tester,
  PositionComponent component,
  ComponentEffect effect, {
  bool shouldComplete = true,
  double iterations = 1.0,
  double expectedAngle = 0.0,
  Vector2? expectedPosition,
  Vector2? expectedSize,
  Vector2? expectedScale,
  required Random random,
}) async {
  component.children.register<ComponentEffect>();
  expectedPosition ??= Vector2.zero();
  expectedSize ??= Vector2.all(100.0);
  expectedScale ??= Vector2.all(1.0);
  final callback = Callback();
  effect.onComplete = callback.call;
  final game = BaseGame();
  game.onGameResize(Vector2.all(200));
  await tester.pumpWidget(GameWidget(
    game: game,
  ));
  await game.add(component);
  await component.add(effect);
  final duration = effect.iterationTime;
  var timeLeft = iterations * duration;
  while (timeLeft > 0) {
    var stepDelta = 50.0 + random.nextInt(50);
    stepDelta /= 1000;
    stepDelta = stepDelta < timeLeft ? stepDelta : timeLeft;
    game.update(stepDelta);
    timeLeft -= stepDelta;
  }
  game.update(0.0); // Since effects are removed before they are updated

  if (!shouldComplete) {
    expectVector2(
      component.position,
      expectedPosition,
      reason: 'Position is not correct',
    );
    expectDouble(
      component.angle,
      expectedAngle,
      reason: 'Angle is not correct',
    );
    expectVector2(
      component.size,
      expectedSize,
      reason: 'Size is not correct',
    );
    expectVector2(
      component.scale,
      expectedScale,
      reason: 'Scale is not correct',
    );
  } else {
    // To account for float number operations making effects not finish
    const epsilon = 0.001;
    final percentage = effect.percentage;
    if (percentage < epsilon) {
      print('hit percentage < epsilon');
      game.update(effect.currentTime);
    } else if (1.0 - percentage < epsilon) {
      print('hit 1.0 - percentage < epsilon');
      game.update(effect.peakTime - effect.currentTime);
    }

    print('$expectedPosition ${component.position}');
    expectVector2(
      component.position,
      expectedPosition,
      reason: 'Position is not exactly correct',
    );
    expectDouble(
      component.angle,
      expectedAngle,
      reason: 'Angle is not exactly correct',
    );
    expectVector2(
      component.size,
      expectedSize,
      reason: 'Size is not exactly correct',
    );
    expectVector2(
      component.scale,
      expectedScale,
      reason: 'Scale is not exactly correct',
    );
  }
  print('${effect.percentage} ${component.position}');
  print(expectedPosition);
  print('Should remove: ${effect.shouldRemove}');
  expect(effect.hasCompleted(), shouldComplete, reason: 'Effect shouldFinish');
  game.update(0); // Children are removed before update logic
  expect(
    callback.calledNumber,
    shouldComplete ? 1 : 0,
    reason: 'Callback was treated wrong',
  );
  print('Should remove2: ${effect.shouldRemove}');
  expect(
    component.children.query<ComponentEffect>().every((e) => e.shouldRemove),
    shouldComplete,
    reason: 'Component had wrong number of children',
  );
}

class TestComponent extends PositionComponent {
  TestComponent({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double angle = 0.0,
    Anchor anchor = Anchor.center,
  }) : super(
          position: position,
          size: size ?? Vector2.all(100.0),
          scale: scale,
          angle: angle,
          anchor: anchor,
        );
}

abstract class BaseElements {
  BaseElements(this.random) {
    argumentSize = randomVector2();
    argumentScale = randomVector2();
    argumentAngle = randomAngle();
    path = List.generate(3, (i) => randomVector2());
  }

  final Random random;
  late final Vector2 argumentSize;
  late final Vector2 argumentScale;
  late final double argumentAngle;
  late final List<Vector2> path;

  Vector2 randomVector2() => (Vector2.random(random) * 100)..round();
  double randomAngle() => 1.0 + random.nextInt(5);
  double randomDuration() => 1.0 + random.nextInt(100);

  TestComponent component();
}
