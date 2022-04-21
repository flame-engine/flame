import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveOverlaysNotifier', () {
    test('can be constructed', () {
      expect(ActiveOverlaysNotifier(), isNotNull);
    });

    late ActiveOverlaysNotifier notifier;

    setUp(() {
      notifier = ActiveOverlaysNotifier();
    });

    group('add', () {
      test('can add an overlay', () {
        final result = notifier.add('test');

        expect(result, true);
        expect(notifier.isActive('test'), true);
      });

      test('wont add same overlay', () {
        notifier.add('test');
        final result = notifier.add('test');

        expect(result, false);
      });
    });

    group('remove', () {
      test('can remove an overlay', () {
        notifier.add('test');

        final result = notifier.remove('test');

        expect(result, true);
        expect(notifier.isActive('test'), false);
      });

      test('wont result in removal if there is nothing to remove', () {
        final result = notifier.remove('test');

        expect(result, false);
      });
    });

    group('isActive', () {
      test('is true when overlay is active', () {
        notifier.add('test');
        expect(notifier.isActive('test'), true);
      });

      test('is false when overlay is active', () {
        expect(notifier.isActive('test'), false);
      });
    });

    group('clear', () {
      test('clears all overlays', () {
        notifier.add('test1');
        notifier.add('test2');

        notifier.clear();

        expect(notifier.isActive('test1'), false);
        expect(notifier.isActive('test2'), false);
      });
    });
  });
}
