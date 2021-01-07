import 'package:flame/timer.dart';
import 'package:test/test.dart';

void main() {
  group('Timer', () {
    test('can be started and stopped, discarding progress', () {
      final timer = Timer(1.0);
      expect(timer.isRunning(), false);
      timer.start();
      expect(timer.isRunning(), true);
      timer.update(0.5);
      timer.stop();
      expect(timer.isRunning(), false);
      expect(timer.current, 0.0);
    });

    test('can be paused and resumed, retaining progress', () {
      final timer = Timer(1.0);
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
      final timer = Timer(1.0);
      timer.start();
      timer.update(0.5);
      expect(timer.current, 0.5);
      timer.update(0.2);
      expect(timer.current, 0.7);
    });

    test('tracks progress percent capped at 1.0', () {
      final timer = Timer(2.0);
      timer.start();
      timer.update(0.5);
      expect(timer.progress, 0.25);
      timer.update(0.5);
      expect(timer.progress, 0.5);
      timer.update(9999);
      expect(timer.progress, 1.0);
    });

    test('callback fires once if non-repeating', () {
      var callbackCount = 0;
      final timer = Timer(1.0, callback: () => callbackCount++);
      timer.start();
      timer.update(0.9);
      expect(callbackCount, 0);
      timer.update(0.2);
      expect(callbackCount, 1);
      timer.update(1.0);
      expect(callbackCount, 1);
    });

    test('finishes when complete if non-repeating', () {
      final timer = Timer(1.0);
      timer.start();
      expect(timer.finished, false);
      timer.update(1.1);
      expect(timer.finished, true);
    });

    test('callback fires repeatedly if repeating', () {
      var callbackCount = 0;
      final timer = Timer(1.0, repeat: true, callback: () => callbackCount++);
      timer.start();
      timer.update(0.9);
      expect(callbackCount, 0);
      timer.update(0.2);
      expect(callbackCount, 1);
      timer.update(1.0);
      expect(callbackCount, 2);
    });

    test('does not finish past limit if repeating', () {
      final timer = Timer(1.0, repeat: true);
      timer.start();
      expect(timer.finished, false);
      timer.update(1.1);
      expect(timer.finished, false);
    });
  });
}
