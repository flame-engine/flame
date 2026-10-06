import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_3d_component/flame_3d_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [Component3D] that records the scene calls instead of touching the GPU,
/// which is not available under `flutter test`.
class _RecordingComponent3D({
  this.ready = true,
  super.camera,
  super.size,
  super.pixelRatio,
}) extends Component3D {
  final bool ready;
  final List<double> updates = [];
  final List<Rect> viewports = [];
  final List<double> pixelRatios = [];

  @override
  bool get isReadyToRender => ready;

  @override
  void updateScene(double dt) {
    updates.add(dt);
  }

  @override
  void renderScene(Canvas canvas, Rect viewport, double pixelRatio) {
    viewports.add(viewport);
    pixelRatios.add(pixelRatio);
  }
}

void main() {
  group('Component3D', () {
    test('uses a perspective camera by default', () {
      final component = _RecordingComponent3D();
      expect(component.camera, isA<PerspectiveCamera>());
    });

    test('keeps a provided camera', () {
      final camera = PerspectiveCamera();
      final component = _RecordingComponent3D(camera: camera);
      expect(component.camera, same(camera));
    });

    testWithFlameGame(
      'hands the accumulated update time to the scene when rendering',
      (game) async {
        final component = _RecordingComponent3D(
          size: Vector2(200, 100),
          pixelRatio: 1,
        );
        await game.ensureAdd(component);

        component.update(0.25);
        component.update(0.5);
        expect(component.updates, isEmpty);

        component.render(_canvas());
        expect(component.updates, [0.75]);

        component.render(_canvas());
        expect(component.updates, [0.75, 0]);
      },
    );

    testWithFlameGame('renders into a viewport matching its size', (
      game,
    ) async {
      final component = _RecordingComponent3D(
        size: Vector2(200, 100),
        pixelRatio: 1.5,
      );
      await game.ensureAdd(component);

      component.render(_canvas());

      expect(component.viewports, [const Rect.fromLTWH(0, 0, 200, 100)]);
      expect(component.pixelRatios, [1.5]);
    });

    testWithFlameGame('skips rendering when the size is empty', (game) async {
      final component = _RecordingComponent3D();
      await game.ensureAdd(component);

      component.update(1);
      component.render(_canvas());

      expect(component.updates, isEmpty);
      expect(component.viewports, isEmpty);
    });

    testWithFlameGame('skips rendering while the engine is not ready', (
      game,
    ) async {
      final component = _RecordingComponent3D(
        ready: false,
        size: Vector2.all(100),
      );
      await game.ensureAdd(component);

      component.update(1);
      component.render(_canvas());

      expect(component.updates, isEmpty);
      expect(component.viewports, isEmpty);
    });

    test('derives the pixel ratio from the canvas zoom', () {
      final component = _RecordingComponent3D(size: Vector2.all(100));
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..clipRect(const Rect.fromLTWH(0, 0, 400, 400))
        ..scale(2);

      component.render(canvas);
      recorder.endRecording().dispose();

      final devicePixelRatio =
          PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
      expect(component.pixelRatios, [devicePixelRatio * 2]);
    });

    test('falls back to the device pixel ratio without a clip', () {
      final component = _RecordingComponent3D(size: Vector2.all(100));

      component.render(_canvas());

      final devicePixelRatio =
          PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
      expect(component.pixelRatios, [devicePixelRatio]);
    });
  });
}

Canvas _canvas() => Canvas(PictureRecorder());
