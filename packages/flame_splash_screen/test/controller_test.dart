import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class OnFinishContainer {
  void onFinish() {}
}

class MockOnFinish extends Mock implements OnFinishContainer {}

void main() {
  group('Without autostart', () {
    late FlameSplashController controller;
    setUp(() {
      controller = FlameSplashController(
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 500),
        waitDuration: const Duration(milliseconds: 500),
        autoStart: false,
      );
    });
    test('dont let start before setup', () async {
      expect(() => controller.start(), throwsAssertionError);
      controller.setup(1, () {});
      controller.start();
    });
    test('Idle after setup', () {
      controller.setup(1, () {});
      expect(controller.state, FlameSplashControllerState.idle);
    });
    test('Started after .start()', () {
      controller.setup(1, () {});
      expect(controller.state, FlameSplashControllerState.idle);
      controller.start();
      expect(controller.state, FlameSplashControllerState.started);
    });
    test('Calls onfinish after steps', () async {
      final onFinishContainer = MockOnFinish();
      controller.setup(3, onFinishContainer.onFinish);
      controller.start();
      await untilCalled(onFinishContainer.onFinish());
      expect(controller.state, FlameSplashControllerState.finished);
    });
  });
  group('With autostart', () {
    late FlameSplashController controller;
    setUp(() {
      controller = FlameSplashController(
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 500),
        waitDuration: const Duration(milliseconds: 500),
      );
    });
    test('Started automatically', () {
      controller.setup(1, () {});
      expect(controller.state, FlameSplashControllerState.started);
    });
    test('Calls onfinish after steps', () async {
      final onFinishContainer = MockOnFinish();
      controller.setup(3, onFinishContainer.onFinish);
      await untilCalled(onFinishContainer.onFinish());
      expect(controller.state, FlameSplashControllerState.finished);
    });

    test('dont let start again', () async {
      controller.setup(1, () {});
      expect(() => controller.start(), throwsAssertionError);
    });
  });
}
