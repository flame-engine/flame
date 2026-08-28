import 'package:flame/game.dart';
import 'package:test/test.dart';

class _Notifier with SimpleChangeNotifier {
  void notify() => notifyListeners();

  bool get hasAnyListeners => hasListeners;
}

void main() {
  group('SimpleChangeNotifier', () {
    test('notifies a single listener', () {
      final notifier = _Notifier();
      var count = 0;
      notifier.addListener(() => count++);
      notifier.notify();
      notifier.notify();
      expect(count, 2);
    });

    test('notifies without listeners', () {
      final notifier = _Notifier();
      expect(notifier.notify, returnsNormally);
      expect(notifier.hasAnyListeners, isFalse);
    });

    test('notifies multiple listeners in registration order', () {
      final notifier = _Notifier();
      final calls = <int>[];
      notifier.addListener(() => calls.add(1));
      notifier.addListener(() => calls.add(2));
      notifier.addListener(() => calls.add(3));
      notifier.notify();
      expect(calls, [1, 2, 3]);
    });

    test('same listener can be added multiple times', () {
      final notifier = _Notifier();
      var count = 0;
      void listener() => count++;
      notifier.addListener(listener);
      notifier.addListener(listener);
      notifier.notify();
      expect(count, 2);
      notifier.removeListener(listener);
      notifier.notify();
      expect(count, 3);
      notifier.removeListener(listener);
      notifier.notify();
      expect(count, 3);
    });

    test('removing a listener stops notifications', () {
      final notifier = _Notifier();
      var first = 0;
      var second = 0;
      void firstListener() => first++;
      void secondListener() => second++;
      notifier.addListener(firstListener);
      notifier.addListener(secondListener);
      notifier.removeListener(firstListener);
      notifier.notify();
      expect(first, 0);
      expect(second, 1);
      notifier.removeListener(secondListener);
      notifier.notify();
      expect(second, 1);
      expect(notifier.hasAnyListeners, isFalse);
    });

    test('removing an unknown listener is a no-op', () {
      final notifier = _Notifier();
      var count = 0;
      notifier.addListener(() => count++);
      notifier.removeListener(() {});
      notifier.notify();
      expect(count, 1);
    });

    test('listener removing itself during notification', () {
      final notifier = _Notifier();
      var first = 0;
      var second = 0;
      late void Function() firstListener;
      firstListener = () {
        first++;
        notifier.removeListener(firstListener);
      };
      notifier.addListener(firstListener);
      notifier.addListener(() => second++);
      notifier.notify();
      expect(first, 1);
      expect(second, 1);
      notifier.notify();
      expect(first, 1);
      expect(second, 2);
    });

    test('single listener removing itself during notification', () {
      final notifier = _Notifier();
      var count = 0;
      late void Function() listener;
      listener = () {
        count++;
        notifier.removeListener(listener);
      };
      notifier.addListener(listener);
      notifier.notify();
      notifier.notify();
      expect(count, 1);
      expect(notifier.hasAnyListeners, isFalse);
    });

    test('listener removing a later listener during notification', () {
      final notifier = _Notifier();
      var second = 0;
      var third = 0;
      void secondListener() => second++;
      void thirdListener() => third++;
      notifier.addListener(() => notifier.removeListener(secondListener));
      notifier.addListener(secondListener);
      notifier.addListener(thirdListener);
      notifier.notify();
      expect(second, 0);
      expect(third, 1);
      notifier.notify();
      expect(second, 0);
      expect(third, 2);
    });

    test('listener added during notification is not called in that round', () {
      final notifier = _Notifier();
      var late = 0;
      void lateListener() => late++;
      notifier.addListener(() => notifier.addListener(lateListener));
      notifier.notify();
      expect(late, 0);
      notifier.removeListener(lateListener);
      notifier.notify();
      expect(late, 0);
    });

    test('reentrant notification', () {
      final notifier = _Notifier();
      var depth = 0;
      var count = 0;
      notifier.addListener(() {
        count++;
        if (depth == 0) {
          depth++;
          notifier.notify();
          depth--;
        }
      });
      notifier.addListener(() => count++);
      notifier.notify();
      expect(count, 4);
    });

    test('exceptions propagate to the caller', () {
      final notifier = _Notifier();
      notifier.addListener(() => throw StateError('boom'));
      expect(notifier.notify, throwsStateError);
    });

    test('dispose removes all listeners', () {
      final notifier = _Notifier();
      var count = 0;
      notifier.addListener(() => count++);
      notifier.addListener(() => count++);
      expect(notifier.hasAnyListeners, isTrue);
      notifier.dispose();
      expect(notifier.hasAnyListeners, isFalse);
      notifier.notify();
      expect(count, 0);
    });

    test('hasListeners', () {
      final notifier = _Notifier();
      void listener() {}
      expect(notifier.hasAnyListeners, isFalse);
      notifier.addListener(listener);
      expect(notifier.hasAnyListeners, isTrue);
      notifier.addListener(() {});
      notifier.removeListener(listener);
      expect(notifier.hasAnyListeners, isTrue);
    });
  });
}
