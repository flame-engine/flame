import 'package:flame/effects.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('HasSingleChildEffectController', () {
    test('child getter should return the wrapped child effect controller', () {
      final childController = _MockEffectController();
      final controller = _TestEffectController(childController);

      expect(controller.child, equals(childController));
    });

    test(
      'setToStart should call setToStart on the child effect controller',
      () {
        final childController = _MockEffectController();
        final controller = _TestEffectController(childController);
        controller.setToStart();
        verify(childController.setToStart).called(1);
      },
    );

    test('setToEnd should call setToEnd on the child effect controller', () {
      final childController = _MockEffectController();
      final controller = _TestEffectController(childController);
      controller.setToEnd();
      verify(childController.setToEnd).called(1);
    });

    test('onMount should call onMount on the child effect controller', () {
      final childController = _MockEffectController();
      final controller = _TestEffectController(childController);
      final parentEffect = _MockEffect();
      controller.onMount(parentEffect);
      verify(() => childController.onMount(parentEffect)).called(1);
    });
  });
}

class _TestEffectController extends _MockEffectController
    with HasSingleChildEffectController<_MockEffectController> {
  _TestEffectController(_MockEffectController child) : _child = child;

  final _MockEffectController _child;

  @override
  _MockEffectController get child => _child;
}

class _MockEffectController extends Mock implements EffectController {}

class _MockEffect extends Mock implements Effect {}
