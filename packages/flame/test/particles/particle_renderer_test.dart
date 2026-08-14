import 'dart:ui';

import 'package:flame/particles.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Image> _makeImage(int width, int height) {
  final recorder = PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xffffffff),
  );
  return recorder.endRecording().toImage(width, height);
}

ParticleBuffer _bufferWithParticles(int count) {
  final buffer = ParticleBuffer(count + 4);
  for (var i = 0; i < count; i++) {
    final index = buffer.spawn();
    buffer.posX[index] = i * 10.0;
    buffer.posY[index] = i * 5.0;
    buffer.size[index] = 8;
    buffer.rotation[index] = i * 0.1;
    buffer.color[index] = 0xffffffff;
  }
  return buffer;
}

void main() {
  group('CircleParticleRenderer', () {
    test('generates its texture on load', () async {
      final renderer = CircleParticleRenderer();
      expect(renderer.texture, isNull);
      await renderer.onLoad();
      expect(renderer.texture, isNotNull);
      expect(renderer.srcRect.width, renderer.texture!.width);
    });

    test('loading twice keeps the same texture', () async {
      final renderer = CircleParticleRenderer();
      await renderer.onLoad();
      final texture = renderer.texture;
      await renderer.onLoad();
      expect(renderer.texture, same(texture));
    });

    test('renders live particles without throwing', () async {
      final renderer = CircleParticleRenderer(softness: 0.5);
      await renderer.onLoad();
      final canvas = Canvas(PictureRecorder());
      renderer.render(canvas, _bufferWithParticles(16));
    });

    test('rendering before load or with no particles is a no-op', () async {
      final renderer = CircleParticleRenderer();
      final canvas = Canvas(PictureRecorder());
      renderer.render(canvas, _bufferWithParticles(3));
      await renderer.onLoad();
      renderer.render(canvas, _bufferWithParticles(0));
    });
  });

  group('SpriteParticleRenderer', () {
    test('uses the full image by default', () async {
      final image = await _makeImage(16, 8);
      final renderer = SpriteParticleRenderer.fromImage(image);
      expect(renderer.texture, same(image));
      expect(renderer.srcRect, const Rect.fromLTWH(0, 0, 16, 8));
    });

    test('renders live particles without throwing', () async {
      final image = await _makeImage(16, 16);
      final renderer = SpriteParticleRenderer.fromImage(image);
      await renderer.onLoad();
      final canvas = Canvas(PictureRecorder());
      renderer.render(canvas, _bufferWithParticles(32));
    });

    test('blendMode is applied to the paint', () {
      final renderer = CircleParticleRenderer(blendMode: BlendMode.plus);
      expect(renderer.paint.blendMode, BlendMode.plus);
    });
  });
}
