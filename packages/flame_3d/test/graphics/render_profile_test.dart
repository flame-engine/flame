import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  group('RenderProfile', () {
    tearDown(() => RenderProfile.active = null);

    test('starts at zero', () {
      final profile = RenderProfile();
      for (final phase in RenderPhase.values) {
        expect(profile.microseconds(phase), 0);
        expect(profile.microseconds(phase, shadow: true), 0);
      }
      expect(profile.totalMicroseconds, 0);
    });

    test('times the phases only when built with FLAME_3D_PROFILE', () {
      final profile = RenderProfile.active = RenderProfile();
      final device = GraphicsDevice(backend: FakeGpuBackend());
      final context = RenderContext3D(device);
      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(8, 8));
      RenderProfile.start();
      context.flush();
      RenderProfile.switchPass(RenderPhase.setup, shadow: true);
      final clock = Stopwatch()..start();
      while (clock.elapsedMicroseconds < 200) {}
      RenderProfile.lap(RenderPhase.sort);
      device
        ..endPass()
        ..end();

      if (kProfileRender) {
        expect(profile.inShadowPass, isTrue);
        expect(
          profile.microseconds(RenderPhase.sort, shadow: true),
          greaterThanOrEqualTo(200),
        );
        expect(profile.totalMicroseconds, greaterThanOrEqualTo(200));
      } else {
        expect(profile.inShadowPass, isFalse);
        expect(profile.totalMicroseconds, 0);
      }
    });

    test('reset sets every time back to zero', () {
      final profile = RenderProfile.active = RenderProfile();
      RenderProfile.start();
      RenderProfile.switchPass(RenderPhase.draw, shadow: true);
      profile.reset();

      expect(profile.totalMicroseconds, 0);
      expect(profile.inShadowPass, isFalse);
    });
  });
}
