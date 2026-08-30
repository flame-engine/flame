import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ensureAdd', () {
    testWithFlameGame('adds the component', (game) async {
      final component = Component();
      await game.ensureAdd(component);

      expect(game.children, contains(component));
    });

    testWithFlameGame('reports a load failure instead of hanging', (
      game,
    ) async {
      await expectLater(
        () => game.ensureAdd(_FailingLoadComponent()),
        throwsA(isA<_LoadException>()),
      );
    });
  });

  group('ensureAddAll', () {
    testWithFlameGame('adds all the components', (game) async {
      final components = [Component(), Component()];
      await game.ensureAddAll(components);

      expect(game.children, containsAll(components));
    });

    testWithFlameGame('reports a load failure instead of hanging', (
      game,
    ) async {
      await expectLater(
        () => game.ensureAddAll([Component(), _FailingLoadComponent()]),
        throwsA(isA<_LoadException>()),
      );
    });
  });
}

class _LoadException implements Exception {
  const _LoadException();
}

class _FailingLoadComponent extends Component {
  @override
  Future<void> onLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    throw const _LoadException();
  }
}
