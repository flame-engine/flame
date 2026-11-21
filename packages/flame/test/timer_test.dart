import 'package:flame/timer.dart';
import 'package:test/test.dart';

void main() {
  group('Timer', () {
    test('can be started and stopped, discarding progress', () {
      final timer = Timer(period: 1.0, autoStart: false);
      expect(timer.isRunning(), false);
      timer.start();
      expect(timer.isRunning(), true);
      timer.update(0.5);
      timer.stop();
      expect(timer.isRunning(), false);
      expect(timer.current, 0.0);
    });

    test('can be paused and resumed, retaining progress', () {
      final timer = Timer(period: 1.0, autoStart: false);
      expect(timer.isRunning(), false);
      timer.start();
      expect(timer.isRunning(), true);
      timer.update(0.5);
      timer.pause();
      expect(timer.isRunning(), false);
      timer.resume();
      expect(timer.isRunning(), true);
      expect(timer.current, 0.5);
    });

    test('tracks current delta time', () {
      final timer = Timer(period: 1.0);
      timer.update(0.5);
      expect(timer.current, 0.5);
      timer.update(0.2);
      expect(timer.current, 0.7);
    });

    test('tracks progress percent capped at 1.0', () {
      final timer = Timer(period: 2.0);
      timer.update(0.5);
      expect(timer.progress, 0.25);
      timer.update(0.5);
      expect(timer.progress, 0.5);
      timer.update(9999);
      expect(timer.progress, 1.0);
    });

    test('onTick fires once if non-repeating', () {
      var onTickCount = 0;
      final timer = Timer(period: 1.0, onTick: () => onTickCount++);
      timer.update(0.9);
      expect(onTickCount, 0);
      timer.update(0.2);
      expect(onTickCount, 1);
      timer.update(1.0);
      expect(onTickCount, 1);
    });

    test('finishes when complete if non-repeating', () {
      final timer = Timer(period: 1.0);
      expect(timer.finished, false);
      timer.update(1.1);
      expect(timer.finished, true);
    });

    test('onTick fires repeatedly if repeating', () {
      var onTickCount = 0;
      final timer = Timer(
        period: 1.0,
        repeat: true,
        onTick: () => onTickCount++,
      );
      timer.update(0.9);
      expect(onTickCount, 0);
      timer.update(0.2);
      expect(onTickCount, 1);
      timer.update(1.0);
      expect(onTickCount, 2);
    });

    test('does not finish past limit if repeating', () {
      final timer = Timer(period: 1.0, repeat: true);
      expect(timer.finished, false);
      timer.update(1.1);
      expect(timer.finished, false);
    });

    test('when tickCount is provided, tick only the provided amount', () {
      var count = 0;
      final timer = Timer(
        period: 1,
        repeat: true,
        tickCount: 2,
        onTick: () {
          count++;
        },
      );
      timer.update(1.1);
      timer.update(1.1);
      timer.update(1.1);

      expect(count, equals(2));
      expect(timer.finished, isTrue);
    });

    test('when tickCount is provided, start ticks the full amount again', () {
      var count = 0;
      final timer = Timer(
        period: 1,
        repeat: true,
        tickCount: 2,
        onTick: () => count++,
      );
      timer.update(1.1);
      timer.update(1.1);
      expect(count, 2);
      expect(timer.finished, isTrue);
      expect(timer.isRunning(), isFalse);
      expect(timer.current, 0);

      timer.start();
      expect(timer.finished, isFalse);
      expect(timer.isRunning(), isTrue);
      timer.update(1.1);
      timer.update(1.1);
      timer.update(1.1);
      expect(count, 4);
      expect(timer.finished, isTrue);
    });

    test('when tickCount is provided, reset also resets the ticks', () {
      var count = 0;
      final timer = Timer(
        period: 1,
        repeat: true,
        tickCount: 2,
        onTick: () => count++,
      );
      timer.update(1.1);
      expect(count, 1);

      timer.reset();
      timer.update(1.1);
      expect(count, 2);
      expect(timer.finished, isFalse);
      expect(timer.isRunning(), isTrue);
      timer.update(1.1);
      expect(count, 3);
      expect(timer.finished, isTrue);
    });

    test('when tickCount is provided, start from onTick ticks again', () {
      var count = 0;
      late Timer timer;
      timer = Timer(
        period: 1,
        repeat: true,
        tickCount: 3,
        onTick: () {
          count++;
          if (count == 3) {
            timer.start();
          }
        },
      );
      for (var i = 0; i < 6; i++) {
        timer.update(1.1);
      }
      expect(count, 6);
      expect(timer.finished, isTrue);
    });

    test('when tickCount is 1, start from onTick keeps it running', () {
      var count = 0;
      late Timer timer;
      timer = Timer(
        period: 1,
        repeat: true,
        tickCount: 1,
        onTick: () {
          count++;
          if (count == 1) {
            timer.start();
          }
        },
      );
      timer.update(1.1);
      expect(timer.isRunning(), isTrue);
      expect(timer.finished, isFalse);
      timer.update(1.1);
      expect(count, 2);
      expect(timer.finished, isTrue);
    });

    test('when tickCount is provided, reset from onTick resets the ticks', () {
      var count = 0;
      late Timer timer;
      timer = Timer(
        period: 1,
        repeat: true,
        tickCount: 2,
        onTick: () {
          count++;
          if (count == 1) {
            timer.reset();
          }
        },
      );
      timer.update(1.1);
      timer.update(1.1);
      expect(count, 2);
      expect(timer.finished, isFalse);
      timer.update(1.1);
      expect(count, 3);
      expect(timer.finished, isTrue);
    });

    test('when tickCount is provided, stop resets finished', () {
      final timer = Timer(period: 1, repeat: true, tickCount: 2);
      timer.update(1.1);
      timer.update(1.1);
      expect(timer.finished, isTrue);

      timer.stop();
      expect(timer.finished, isFalse);
      expect(timer.isRunning(), isFalse);
    });
  });
}
