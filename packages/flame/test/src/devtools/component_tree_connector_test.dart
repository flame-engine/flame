import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/connectors/component_tree_connector.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _PendingLoadComponent extends Component {
  @override
  Future<void> onLoad() => Completer<void>().future;
}

void main() {
  group('lifecycleState', () {
    flameGame.test('reports Detached for a component not in a game', (game) {
      final component = Component();
      expect(lifecycleState(component), 'Detached');
    });

    flameGame.test('reports Loading while the component is loading', (game) {
      final component = _PendingLoadComponent();
      game.add(component);
      expect(lifecycleState(component), 'Loading');
    });

    flameGame.test('reports Loaded for a component that was removed', (
      game,
    ) async {
      final component = Component();
      await game.ensureAdd(component);
      await component.removeFromParent();
      expect(lifecycleState(component), 'Loaded');
    });

    flameGame.test('reports Mounted for a component in the game', (
      game,
    ) async {
      final component = Component();
      await game.ensureAdd(component);
      expect(lifecycleState(component), 'Mounted');
    });

    flameGame.test('reports Removing for a component being removed', (
      game,
    ) async {
      final component = Component();
      await game.ensureAdd(component);
      unawaited(component.removeFromParent());
      expect(lifecycleState(component), 'Removing');
    });
  });
}
