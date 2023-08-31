import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Snapshot',
    () {
      testWithGame<_SnapshotTestGame>(
        'Snapshot should be created once',
        _SnapshotTestGame.new,
        (game) async {
          final sc = game.snapshotComponent;
          await game.ready();

          // Wait a few frames
          final canvas = Canvas(PictureRecorder());
          for (var i = 0; i < 5; i++) {
            game.render(canvas);
          }

          // Check that the rendering has only happened once
          expect(sc.renderCalled, equals(1));
          expect(sc.parentRenderTreeCalled, equals(1));
          // And that a snapshot has been generated
          expect(sc.takeSnapshotCalled, equals(1));
          expect(sc.hasSnapshot, equals(true));
          expect(sc.snapshot, isA<Picture>());
        },
      );

      testWithGame<_SnapshotTestGame>(
        'Should render normally when renderSnapshot is false',
        () => _SnapshotTestGame(renderSnapshot: false),
        (game) async {
          final sc = game.snapshotComponent;
          await game.ready();

          // Wait a few frames
          const framesToWait = 5;
          final canvas = Canvas(PictureRecorder());
          for (var i = 0; i < framesToWait; i++) {
            game.render(canvas);
          }

          // Check that render tree has been called multiple times
          expect(sc.renderTreeCalled, greaterThanOrEqualTo(framesToWait));
          // And that rendering is happening normally
          expect(sc.renderCalled, greaterThanOrEqualTo(framesToWait));
          expect(sc.parentRenderTreeCalled, greaterThanOrEqualTo(framesToWait));
          // And that a snapshot has not been generated
          expect(sc.takeSnapshotCalled, equals(0));
          expect(sc.hasSnapshot, equals(false));
        },
      );

      testWidgets(
        'Should generate a snapshot when takeSnapshot is called',
        (tester) async {
          final game = _SnapshotTestGame(renderSnapshot: false);
          final sc = game.snapshotComponent;
          const framesToWait = 5;

          await tester.runAsync(() async {
            final widget = GameWidget(game: game);
            await tester.pumpWidget(widget);
            await tester.pump();
            await game.ready();

            // Wait a few frames
            final recorder = PictureRecorder();
            final canvas = Canvas(recorder);
            for (var i = 0; i < framesToWait; i++) {
              game.render(canvas);
            }

            // Take snapshot
            sc.takeSnapshot();

            // Wait a few more frames
            for (var i = 0; i < framesToWait; i++) {
              game.render(canvas);
            }
            recorder.endRecording();

            await tester.pump();
          });

          // Check that a snapshot has been generated
          expect(sc.takeSnapshotCalled, equals(1));
          expect(sc.hasSnapshot, equals(true));
          // Check golden
          await expectLater(
            sc.snapshotAsImage(200, 200),
            matchesGoldenFile('../../_goldens/snapshot_test_1.png'),
          );
        },
      );

      testWidgets(
        'Should generate a transformed image',
        (tester) async {
          final game = _SnapshotTestGame(renderSnapshot: false);
          final sc = game.snapshotComponent;

          await tester.runAsync(() async {
            final widget = GameWidget(game: game);
            await tester.pumpWidget(widget);
            await tester.pump();
            await game.ready();

            // Force a frame
            final canvas = Canvas(PictureRecorder());
            game.render(canvas);

            // Take snapshot
            sc.takeSnapshot();

            await tester.pump();
          });

          // prepare transform
          final matrix = Matrix4.identity();
          matrix.translate(100.0, 100.0);
          matrix.rotateZ(-pi / 4);
          matrix.scale(1.5, 1.5);
          matrix.translate(-100.0, -100.0);

          // Check that a snapshot has been generated
          expect(sc.takeSnapshotCalled, equals(1));
          expect(sc.hasSnapshot, equals(true));
          // Check transformed image against golden
          await expectLater(
            sc.snapshotAsImage(200, 200, transform: matrix),
            matchesGoldenFile('../../_goldens/snapshot_test_2.png'),
          );
        },
      );

      testGolden(
        'Should respect transforms',
        game: _SnapshotTestGame(),
        size: Vector2(200, 200),
        (game) async {
          final sc = (game as _SnapshotTestGame).snapshotComponent;

          // Apply transforms
          sc.scale = Vector2(0.75, 0.75);
          sc.angle = pi / 4; // 45 degrees
          sc.position += Vector2(-25, -25);
        },
        goldenFile: '../../_goldens/snapshot_test_3.png',
      );
    },
  );
}

class _SnapshotTestGame extends FlameGame {
  late final _MockSnapshotComponent snapshotComponent;

  _SnapshotTestGame({bool renderSnapshot = true}) {
    // Add a snapshot-enabled component that has it's own rendered content
    snapshotComponent = _MockSnapshotComponent()
      ..size = Vector2(200, 200)
      ..anchor = Anchor.center
      ..position = Vector2(100, 100)
      ..renderSnapshot = renderSnapshot;
    add(snapshotComponent);

    // Also adds a child to the snapshot-enabled component tree
    snapshotComponent.add(generateCircle(
      const Color(0x99ff3300),
      x: 50,
      y: 100,
    ));
    snapshotComponent.add(generateCircle(
      const Color(0x9933ff00),
      x: 150,
      y: 100,
    ));
    snapshotComponent.add(generateCircle(
      const Color(0x990033ff),
      x: 100,
      y: 50,
    ));
    snapshotComponent.add(generateCircle(
      const Color(0x99ff33ff),
      x: 100,
      y: 150,
    ));
  }
}

class _MockSnapshotComponent extends _MockComponentSuper with Snapshot {
  int renderCalled = 0;
  int renderTreeCalled = 0;
  int takeSnapshotCalled = 0;

  @override
  void render(Canvas canvas) {
    renderCalled++;
    super.render(canvas);
  }

  @override
  void renderTree(Canvas canvas) {
    renderTreeCalled++;
    super.renderTree(canvas);
  }

  @override
  Picture takeSnapshot() {
    takeSnapshotCalled++;
    return super.takeSnapshot();
  }
}

/// Mock a superclass just so we can count how many times super.renderTree has
/// been called
class _MockComponentSuper extends PositionComponent {
  int parentRenderTreeCalled = 0;

  @override
  void renderTree(Canvas canvas) {
    parentRenderTreeCalled++;
    super.renderTree(canvas);
  }
}

/// Need a few circles, so this class helps
CircleComponent generateCircle(
  Color c, {
  double radius = 50,
  double x = 0,
  double y = 0,
}) {
  return CircleComponent(
    radius: radius,
    position: Vector2(x, y),
    anchor: Anchor.center,
    paint: Paint()..color = c,
  );
}
