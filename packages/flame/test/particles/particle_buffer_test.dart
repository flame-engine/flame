import 'package:flame/particles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParticleBuffer', () {
    test('spawn hands out slots until the capacity is reached', () {
      final buffer = ParticleBuffer(3);
      expect(buffer.spawn(), 0);
      expect(buffer.spawn(), 1);
      expect(buffer.spawn(), 2);
      expect(buffer.isFull, isTrue);
      expect(buffer.spawn(), -1);
      expect(buffer.length, 3);
    });

    test('removeAt swaps the last particle into the removed slot', () {
      final buffer = ParticleBuffer(3);
      for (var i = 0; i < 3; i++) {
        final index = buffer.spawn();
        buffer.posX[index] = i.toDouble();
      }
      buffer.removeAt(0);
      expect(buffer.length, 2);
      expect(buffer.posX[0], 2);
      expect(buffer.posX[1], 1);
    });

    test('removing the last particle does not copy anything', () {
      final buffer = ParticleBuffer(2);
      buffer.spawn();
      final index = buffer.spawn();
      buffer.posX[index] = 42;
      buffer.removeAt(1);
      expect(buffer.length, 1);
      buffer.removeAt(0);
      expect(buffer.length, 0);
    });

    test('progressAt reports age relative to lifespan', () {
      final buffer = ParticleBuffer(1);
      final index = buffer.spawn();
      buffer.age[index] = 0.5;
      buffer.invLifespan[index] = 1 / 2.0;
      expect(buffer.progressAt(index), 0.25);
    });

    test('clear removes all particles', () {
      final buffer = ParticleBuffer(4);
      buffer.spawn();
      buffer.spawn();
      buffer.clear();
      expect(buffer.length, 0);
      expect(buffer.isFull, isFalse);
    });
  });
}
