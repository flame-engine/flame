import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('_ActiveOverlays', () {
    group('add', () {
      test('can add an overlay', () {
        final overlays = FlameGame().overlays;
        final added = overlays.add('test');
        expect(added, true);
        expect(overlays.isActive('test'), true);
      });

      test('wont add same overlay', () {
        final overlays = FlameGame().overlays;
        overlays.add('test');
        final added = overlays.add('test');
        expect(added, false);
      });
    });

    group('remove', () {
      test('can remove an overlay', () {
        final overlays = FlameGame().overlays;
        overlays.add('test');

        final removed = overlays.remove('test');
        expect(removed, true);
        expect(overlays.isActive('test'), false);
      });

      test('will not result in removal if there is nothing to remove', () {
        final overlays = FlameGame().overlays;
        final removed = overlays.remove('test');
        expect(removed, false);
      });
    });

    group('isActive', () {
      test('is true when overlay is active', () {
        final overlays = FlameGame().overlays;
        overlays.add('test');
        expect(overlays.isActive('test'), true);
      });

      test('is false when overlay is active', () {
        final overlays = FlameGame().overlays;
        expect(overlays.isActive('test'), false);
      });
    });

    group('clear', () {
      test('clears all overlays', () {
        final overlays = FlameGame().overlays;
        overlays.add('test1');
        overlays.add('test2');

        overlays.clear();

        expect(overlays.isActive('test1'), false);
        expect(overlays.isActive('test2'), false);
      });
    });
  });
}
