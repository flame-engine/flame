import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Material.activeAlphaScissorThreshold', () {
    test('alphaScissor applies the threshold in every pass', () {
      final material = UnlitMaterial(
        transparency: Transparency.alphaScissor,
        alphaScissorThreshold: 0.3,
      );

      for (final pass in PassKind.values) {
        expect(material.activeAlphaScissorThreshold(pass), 0.3);
      }
    });

    test('alphaDepthPrePass applies the threshold only in the pre-pass', () {
      final material = UnlitMaterial(
        transparency: Transparency.alphaDepthPrePass,
        alphaScissorThreshold: 0.6,
      );

      expect(material.activeAlphaScissorThreshold(PassKind.depthPrePass), 0.6);
      expect(material.activeAlphaScissorThreshold(PassKind.blend), 0);
      expect(material.activeAlphaScissorThreshold(PassKind.opaque), 0);
    });

    test('other modes never apply the threshold', () {
      for (final t in [
        Transparency.disabled,
        Transparency.alpha,
        Transparency.alphaHash,
      ]) {
        final material = UnlitMaterial(transparency: t);
        for (final pass in PassKind.values) {
          expect(material.activeAlphaScissorThreshold(pass), 0, reason: '$t');
        }
      }
    });
  });

  group('Material.activeAlphaHashScale', () {
    test('is the hash scale only for alphaHash', () {
      for (final t in Transparency.values) {
        final material = UnlitMaterial(transparency: t, alphaHashScale: 5);
        expect(
          material.activeAlphaHashScale,
          t == Transparency.alphaHash ? 5 : 0,
          reason: '$t',
        );
      }
    });
  });

  group('Material.isBlended', () {
    test('is true only for alpha and alphaDepthPrePass', () {
      for (final t in Transparency.values) {
        expect(
          UnlitMaterial(transparency: t).isBlended,
          t == Transparency.alpha || t == Transparency.alphaDepthPrePass,
          reason: '$t',
        );
      }
    });
  });
}
