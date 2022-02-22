import 'dart:ui';

import 'package:flame/assets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockImage extends Mock implements Image {
  int disposedCount = 0;

  @override
  void dispose() {
    disposedCount++;
  }
}

void main() {
  group('Images', () {
    test('clear', () {
      final cache = Images();
      final image = MockImage();
      cache.add('test', image);
      expect(image.disposedCount, 0);
      cache.clear('test');
      expect(image.disposedCount, 1);
    });

    test('clearCache', () {
      final cache = Images();
      final images = List.generate(10, (_) => MockImage());
      for (var i = 0; i < images.length; i++) {
        cache.add(i.toString(), images[i]);
      }
      expect(images.fold<int>(0, (agg, image) => agg + image.disposedCount), 0);
      cache.clearCache();
      expect(
        images.fold<int>(0, (agg, image) => agg + image.disposedCount),
        images.length,
      );
    });
  });
}
