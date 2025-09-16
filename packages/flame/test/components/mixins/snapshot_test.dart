import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Snapshot',
    () {
      testWithGame<_SnapshotTestGame>(
        'Snapshot should be created once',
        _SnapshotTestGame.new,
        (game) async {
          await game.ready();
          final snapshotComponent = game.snapshotComponent;

          // Wait a few frames
          final canvas = Canvas(PictureRecorder());
          for (var i = 0; i < 5; i++) {
            game.render(canvas);
          }

          // Check that the rendering has only happened once
          expect(snapshotComponent.renderCalled, equals(1));
          expect(snapshotComponent.parentRenderTreeCalled, equals(1));
          // And that a snapshot has been generated
          expect(snapshotComponent.takeSnapshotCalled, equals(1));
          expect(snapshotComponent.hasSnapshot, equals(true));
          expect(snapshotComponent.snapshot, isA<Picture>());
        },
      );

      testWithGame<_SnapshotTestGame>(
        'Should render normally when renderSnapshot is false',
        () => _SnapshotTestGame(renderSnapshot: false),
        (game) async {
          await game.ready();
          final snapshotComponent = game.snapshotComponent;

          // Wait a few frames
          const framesToWait = 5;
          final canvas = Canvas(PictureRecorder());
          for (var i = 0; i < framesToWait; i++) {
            game.render(canvas);
          }

          // Check that render tree has been called multiple times
          expect(
            snapshotComponent.renderTreeCalled,
            greaterThanOrEqualTo(framesToWait),
          );
          // And that rendering is happening normally
          expect(
            snapshotComponent.renderCalled,
            greaterThanOrEqualTo(framesToWait),
          );
          expect(
            snapshotComponent.parentRenderTreeCalled,
            greaterThanOrEqualTo(framesToWait),
          );
          // And that a snapshot has not been generated
          expect(snapshotComponent.takeSnapshotCalled, equals(0));
          expect(snapshotComponent.hasSnapshot, equals(false));
        },
      );

      testWidgets(
        'Should generate a snapshot when takeSnapshot is called',
        (tester) async {
          final game = _SnapshotTestGame(renderSnapshot: false);
          const framesToWait = 5;
          late final _MockSnapshotComponent snapshotComponent;

          await tester.runAsync(() async {
            final widget = GameWidget(game: game);
            await tester.pumpWidget(widget);
            await tester.pump();
            await game.ready();
            snapshotComponent = game.snapshotComponent;

            // Wait a few frames
            final recorder = PictureRecorder();
            final canvas = Canvas(recorder);
            for (var i = 0; i < framesToWait; i++) {
              game.render(canvas);
            }

            // Take snapshot
            snapshotComponent.takeSnapshot();

            // Wait a few more frames
            for (var i = 0; i < framesToWait; i++) {
              game.render(canvas);
            }
            recorder.endRecording();

            await tester.pump();
          });

          // Check that a snapshot has been generated
          expect(snapshotComponent.takeSnapshotCalled, equals(1));
          expect(snapshotComponent.hasSnapshot, equals(true));
          // Check golden
          await expectLater(
            snapshotComponent.snapshotAsImage(200, 200),
            matchesGoldenFile('../../_goldens/snapshot_test_1.png'),
          );
        },
      );

      testWidgets(
        'Should generate a transformed image',
        (tester) async {
          final game = _SnapshotTestGame(renderSnapshot: false);
          late final _MockSnapshotComponent snapshotComponent;

          await tester.runAsync(() async {
            final widget = GameWidget(game: game);
            await tester.pumpWidget(widget);
            await tester.pump();
            await game.ready();
            snapshotComponent = game.snapshotComponent;

            // Force a frame
            final canvas = Canvas(PictureRecorder());
            game.render(canvas);

            // Take snapshot
            snapshotComponent.takeSnapshot();

            await tester.pump();
          });

          // prepare transform
          final matrix = Matrix4.identity();
          matrix.translateByDouble(100.0, 100.0, 0.0, 1.0);
          matrix.rotateZ(-pi / 4);
          matrix.scaleByDouble(1.5, 1.5, 1.0, 1.0);
          matrix.translateByDouble(-100.0, -100.0, 0.0, 1.0);

          // Check that a snapshot has been generated
          expect(snapshotComponent.takeSnapshotCalled, equals(1));
          expect(snapshotComponent.hasSnapshot, equals(true));
          // Check transformed image against golden
          await expectLater(
            snapshotComponent.snapshotAsImage(200, 200, transform: matrix),
            matchesGoldenFile('../../_goldens/snapshot_test_2.png'),
          );
        },
      );

      testGolden(
        'Should respect transforms',
        game: _SnapshotTestGame(),
        size: Vector2(200, 200),
        (game, tester) async {
          final snapshotComponent =
              (game as _SnapshotTestGame).snapshotComponent;

          // Apply transforms
          snapshotComponent.scale = Vector2(0.75, 0.75);
          snapshotComponent.angle = pi / 4; // 45 degrees
          snapshotComponent.position += Vector2(-25, -25);
        },
        goldenFile: '../../_goldens/snapshot_test_3.png',
      );
    },
  );
}

class _SnapshotTestGame extends FlameGame {
  late final _MockSnapshotComponent snapshotComponent;
  bool renderSnapshot;

  _SnapshotTestGame({this.renderSnapshot = true});

  @override
  Future<void> onLoad() async {
    // Add a snapshot-enabled component that has it's own rendered content
    snapshotComponent = _MockSnapshotComponent()
      ..size = Vector2(200, 200)
      ..anchor = Anchor.center
      ..position = Vector2(100, 100)
      ..renderSnapshot = renderSnapshot;
    add(snapshotComponent);

    // Also adds a child to the snapshot-enabled component tree
    snapshotComponent.add(
      _generateCircle(
        const Color(0x99ff3300),
        x: 50,
        y: 100,
      ),
    );
    snapshotComponent.add(
      _generateCircle(
        const Color(0x9933ff00),
        x: 150,
        y: 100,
      ),
    );
    snapshotComponent.add(
      _generateCircle(
        const Color(0x990033ff),
        x: 100,
        y: 50,
      ),
    );
    snapshotComponent.add(
      _generateCircle(
        const Color(0x99ff33ff),
        x: 100,
        y: 150,
      ),
    );
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
CircleComponent _generateCircle(
  Color color, {
  double radius = 50,
  double x = 0,
  double y = 0,
}) {
  return CircleComponent(
    radius: radius,
    position: Vector2(x, y),
    anchor: Anchor.center,
    paint: Paint()..color = color,
  );
}
