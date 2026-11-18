import 'dart:math' as math;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

void main() {
  setUpGpu();

  group('back-face culling', () {
    final material = UnlitMaterial()
      ..renderState = const RenderState(cullMode: CullMode.backFace);

    /// Renders a quad at x = 0.5 (facing the camera unless [facingAway]) and
    /// returns whether it is visible at x = 0.5 and at x = -0.5.
    Future<(bool, bool)> render({
      required bool mirroredCamera,
      bool facingAway = false,
      bool mirroredModel = false,
    }) async {
      final surface = quad(material, halfSize: 0.3);
      final projection = defaultProjection;
      if (mirroredCamera) {
        projection.setEntry(0, 0, -1);
      }
      final transform = Matrix4.translationValues(0.5, 0, -5);
      if (facingAway) {
        transform.rotateY(math.pi);
      }
      if (mirroredModel) {
        transform.scaleByDouble(-1, 1, 1, 1);
      }
      final frame = await renderFrame(
        projection: projection,
        draw: (context) {
          expect(context.isMirrored, mirroredCamera);
          context.drawSurface(surface, transform: transform);
        },
      );
      final (rx, ry) = pixelAt(0.5, 0);
      final (lx, ly) = pixelAt(-0.5, 0);
      return (!frame.pixels.isClear(rx, ry), !frame.pixels.isClear(lx, ly));
    }

    testGpuEngine('keeps faces toward a standard camera', () async {
      expect(await render(mirroredCamera: false), (true, false));
    });

    testGpuEngine('culls faces away from a standard camera', () async {
      expect(
        await render(mirroredCamera: false, facingAway: true),
        (false, false),
      );
    });

    testGpuEngine('keeps faces toward a mirroring camera', () async {
      // The image is mirrored: the quad shows on the left.
      expect(await render(mirroredCamera: true), (false, true));
    });

    testGpuEngine('culls faces away from a mirroring camera', () async {
      expect(
        await render(mirroredCamera: true, facingAway: true),
        (false, false),
      );
    });

    testGpuEngine('keeps the front faces of mirrored objects', () async {
      // Scaling x by -1 keeps the quad facing the camera, but reverses the
      // order of its vertices on screen.
      expect(
        await render(mirroredCamera: false, mirroredModel: true),
        (true, false),
      );
      expect(
        await render(mirroredCamera: true, mirroredModel: true),
        (false, true),
      );
    });

    testGpuEngine('culls the back faces of mirrored objects', () async {
      expect(
        await render(
          mirroredCamera: false,
          mirroredModel: true,
          facingAway: true,
        ),
        (false, false),
      );
    });
  });
}
