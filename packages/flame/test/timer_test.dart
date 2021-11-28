import 'package:flame/components.dart';
import 'package:flame/timer.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Timer', () {
    test('can be started and stopped, discarding progress', () {
      final timer = Timer(1.0, autoStart: false);
      expect(timer.isRunning(), false);
      timer.start();
      expect(timer.isRunning(), true);
      timer.update(0.5);
      timer.stop();
      expect(timer.isRunning(), false);
      expect(timer.current, 0.0);
    });

    test('can be paused and resumed, retaining progress', () {
      final timer = Timer(1.0, autoStart: false);
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
      timer.update(0.5);
      expect(timer.current, 0.5);
      timer.update(0.2);
      expect(timer.current, 0.7);
    });

    test('tracks progress percent capped at 1.0', () {
      final timer = Timer(2.0);
      timer.update(0.5);
      expect(timer.progress, 0.25);
      timer.update(0.5);
      expect(timer.progress, 0.5);
      timer.update(9999);
      expect(timer.progress, 1.0);
    });

    test('onTick fires once if non-repeating', () {
      var onTickCount = 0;
      final timer = Timer(1.0, onTick: () => onTickCount++);
      timer.update(0.9);
      expect(onTickCount, 0);
      timer.update(0.2);
      expect(onTickCount, 1);
      timer.update(1.0);
      expect(onTickCount, 1);
    });

    test('finishes when complete if non-repeating', () {
      final timer = Timer(1.0);
      expect(timer.finished, false);
      timer.update(1.1);
      expect(timer.finished, true);
    });

    test('onTick fires repeatedly if repeating', () {
      var onTickCount = 0;
      final timer = Timer(1.0, repeat: true, onTick: () => onTickCount++);
      timer.update(0.9);
      expect(onTickCount, 0);
      timer.update(0.2);
      expect(onTickCount, 1);
      timer.update(1.0);
      expect(onTickCount, 2);
    });

    test('does not finish past limit if repeating', () {
      final timer = Timer(1.0, repeat: true);
      expect(timer.finished, false);
      timer.update(1.1);
      expect(timer.finished, false);
    });

    flameGame.test(
      'broken test',
      (game) async {
        print('1');
        await game.ensureAdd(Component());
        print('2');
        await game.ensureAdd(Component());
        print('3');
        await game.ensureAdd(Component());
        print('4');
        await game.ensureAdd(Component());
        print('5');
        await game.ensureAdd(Component());
        print('6');
        await game.ensureAdd(Component());
        print('7');
        await game.ensureAdd(Component());

        print('8');
        expect(game.children, -1);
        print('9');
        expect(true, false);
        print('0');
      },
    );
  });
}
