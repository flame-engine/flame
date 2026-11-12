import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Component.lifecycleState', () {
    test('a freshly created component is Detached', () {
      final component = Component();

      expect(component.lifecycleState, ComponentLifecycleState.detached);
    });

    test('a component whose onLoad never completes is Loading', () async {
      final game = FlameGame()..onGameResize(Vector2.all(100));
      final component = _PendingLoadComponent();
      game.add(component);

      expect(component.lifecycleState, ComponentLifecycleState.loading);
      component.completeLoading();
    });

    test('a loaded but unmounted component is Loaded', () async {
      final game = FlameGame()..onGameResize(Vector2.all(100));
      final component = _PendingLoadComponent();
      game.add(component);
      component.completeLoading();
      await component.loaded;

      expect(component.lifecycleState, ComponentLifecycleState.loaded);
    });

    testWithFlameGame('a mounted component is Mounted', (game) async {
      final component = Component();
      game.add(component);
      await game.ready();

      expect(component.lifecycleState, ComponentLifecycleState.mounted);
    });

    testWithFlameGame(
      'a component scheduled for removal is Removing, '
      'and Loaded once the removal completes',
      (game) async {
        final component = Component();
        game.add(component);
        await game.ready();

        final removed = component.removed;
        component.removeFromParent();
        expect(component.lifecycleState, ComponentLifecycleState.removing);

        game.update(0);
        await removed;
        expect(component.lifecycleState, ComponentLifecycleState.loaded);
      },
    );
  });
}

class _PendingLoadComponent() extends Component {
  final _completer = Completer<void>();

  void completeLoading() => _completer.complete();

  @override
  Future<void> onLoad() => _completer.future;
}
