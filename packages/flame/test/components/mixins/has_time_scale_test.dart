import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('HasTimeScale', () {
    testWithGame<_GameWithTimeScale>(
      'delta time scales correctly',
      _GameWithTimeScale.new,
      (game) async {
        final component = _MovingComponent();
        await game.add(component);
        await game.ready();
        const stepTime = 10.0;
        var distance = 0.0;
        final offset = stepTime * component.speed;

        game.timeScale = 0.5;
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + game.timeScale * offset);

        game.timeScale = 1.0;
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + game.timeScale * offset);

        game.timeScale = 1.5;
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + game.timeScale * offset);

        game.timeScale = 2.0;
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + game.timeScale * offset);
      },
    );

    testWithGame(
      'cascading time scale',
      _GameWithTimeScale.new,
      (game) async {
        final component1 = _ComponentWithTimeScale();
        final component2 = _MovingComponent();
        await component1.add(component2);
        await game.add(component1);
        await game.ready();
        const stepTime = 10.0;
        var distance = 0.0;
        final offset = stepTime * component2.speed;

        game.timeScale = 0.5;
        component1.timeScale = 0.5;
        distance = component2.x;
        game.update(stepTime);
        expect(
          component2.x,
          distance + game.timeScale * component1.timeScale * offset,
        );

        game.timeScale = 1.0;
        distance = component2.x;
        game.update(stepTime);
        expect(
          component2.x,
          distance + game.timeScale * component1.timeScale * offset,
        );

        component1.timeScale = 1.5;
        distance = component2.x;
        game.update(stepTime);
        expect(
          component2.x,
          distance + game.timeScale * component1.timeScale * offset,
        );

        game.timeScale = 2.0;
        distance = component2.x;
        game.update(stepTime);
        expect(
          component2.x,
          distance + game.timeScale * component1.timeScale * offset,
        );
      },
    );

    testWithGame(
      'pausing and resuming',
      _GameWithTimeScale.new,
      (game) async {
        final component = _MovingComponent();
        await game.add(component);
        await game.ready();
        const stepTime = 10.0;
        var distance = 0.0;
        final offset = stepTime * component.speed;

        game.pause();
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance);

        game.resume();
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + offset);

        game.pause();
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance);

        game.resume(newTimeScale: 0.5);
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + 0.5 * offset);
      },
    );

    testWithGame(
      'resume does not modify timeScale if not paused',
      _GameWithTimeScale.new,
      (game) async {
        final component = _MovingComponent();
        await game.add(component);
        await game.ready();
        const stepTime = 10.0;
        var distance = 0.0;
        final offset = stepTime * component.speed;

        game.pause();
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + game.timeScale * offset);

        game.timeScale = 0.5;
        game.resume();
        distance = component.x;
        game.update(stepTime);
        expect(component.x, distance + game.timeScale * offset);
      },
    );
  });
}

class _GameWithTimeScale extends FlameGame with HasTimeScale {}

class _ComponentWithTimeScale extends Component with HasTimeScale {}

class _MovingComponent extends PositionComponent {
  final speed = 1.0;
  @override
  void update(double dt) => position.setValues(position.x + speed * dt, 0);
}
