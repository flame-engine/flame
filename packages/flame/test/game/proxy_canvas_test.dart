import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/game/proxy_canvas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProxyCanvas', () {
    test('forwards drawing calls to the inner canvas', () {
      final recorder = PictureRecorder();
      final inner = Canvas(recorder);
      final canvas = ProxyCanvas(inner);

      canvas.translate(10, 20);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 10, 10), Paint());

      expect(canvas.inner, same(inner));
      expect(canvas.getTransform(), inner.getTransform());
      expect(canvas.getTransform()[12], 10);
      expect(canvas.getTransform()[13], 20);
      recorder.endRecording().dispose();
    });

    test('replays the save stack, transforms and clips on swap', () {
      final firstRecorder = PictureRecorder();
      final first = Canvas(firstRecorder);
      final canvas = ProxyCanvas(first);

      canvas.translate(10, 20);
      canvas.save();
      canvas.scale(2);
      canvas.clipRect(const Rect.fromLTWH(0, 0, 100, 100));
      canvas.save();
      canvas.rotate(1);
      canvas.transform(
        Float64List.fromList(
          [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 5, 5, 0, 1],
        ),
      );
      final expectedTransform = first.getTransform();
      final expectedClip = first.getDestinationClipBounds();
      final expectedSaveCount = first.getSaveCount();

      final secondRecorder = PictureRecorder();
      final second = Canvas(secondRecorder);
      canvas.swap(second);

      expect(canvas.inner, same(second));
      expect(second.getSaveCount(), expectedSaveCount);
      expect(second.getTransform(), expectedTransform);
      expect(second.getDestinationClipBounds(), expectedClip);

      canvas.restore();
      canvas.restore();
      expect(second.getSaveCount(), 1);
      expect(second.getTransform()[0], 1);
      expect(second.getTransform()[12], 10);
      expect(second.getTransform()[13], 20);

      firstRecorder.endRecording().dispose();
      secondRecorder.endRecording().dispose();
    });

    test('drops popped levels before a swap', () {
      final firstRecorder = PictureRecorder();
      final first = Canvas(firstRecorder);
      final canvas = ProxyCanvas(first);

      canvas.save();
      canvas.translate(100, 0);
      canvas.restore();
      canvas.save();
      canvas.translate(1, 0);
      canvas.save();
      canvas.translate(1, 0);
      canvas.save();
      canvas.translate(1, 0);
      canvas.restoreToCount(2);
      final expectedTransform = first.getTransform();

      final secondRecorder = PictureRecorder();
      final second = Canvas(secondRecorder);
      canvas.swap(second);

      expect(second.getSaveCount(), 2);
      expect(second.getTransform(), expectedTransform);
      expect(second.getTransform()[12], 1);

      firstRecorder.endRecording().dispose();
      secondRecorder.endRecording().dispose();
    });

    test('replays a saveLayer as a new layer on the swapped canvas', () {
      final firstRecorder = PictureRecorder();
      final first = Canvas(firstRecorder);
      final canvas = ProxyCanvas(first);

      canvas.saveLayer(null, Paint());
      canvas.translate(3, 4);

      final secondRecorder = PictureRecorder();
      final second = Canvas(secondRecorder);
      canvas.swap(second);

      expect(second.getSaveCount(), 2);
      expect(second.getTransform()[12], 3);
      expect(second.getTransform()[13], 4);
      canvas.restore();
      expect(second.getSaveCount(), 1);

      firstRecorder.endRecording().dispose();
      secondRecorder.endRecording().dispose();
    });
  });
}
