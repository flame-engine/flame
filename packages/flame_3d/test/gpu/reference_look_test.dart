import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';
import 'reference_scenes.dart';

void main() {
  setUpGpu();

  // The references were rendered by flame_3d before instancing, per-material
  // render state and the per-pass uniforms: the built-in materials must look
  // the same.
  group('built-in materials keep their look', () {
    testGpu('lit scene', (tester) async {
      final pixels = await renderGame(
        tester,
        litScene(),
        width: 256,
        height: 256,
      );
      final reference = await loadPng(
        tester,
        'test/gpu/goldens/lit_reference.png',
      );
      final differing = differingPixels(pixels, reference);
      expect(differing, lessThan(256 * 256 * 0.002));
    });

    testGpu('unlit scene', (tester) async {
      final pixels = await renderGame(
        tester,
        unlitScene(),
        width: 256,
        height: 256,
      );
      final reference = await loadPng(
        tester,
        'test/gpu/goldens/unlit_reference.png',
      );
      final differing = differingPixels(pixels, reference);
      expect(differing, lessThan(256 * 256 * 0.002));
    });
  });
}
