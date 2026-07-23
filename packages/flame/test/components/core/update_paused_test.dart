import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('updatePaused', () {
    testWithFlameGame('pauses the component and its subtree', (game) async {
      final child = _Counter();
      final parent = _Counter(children: [child]);
      final sibling = _Counter();
      await game.world.ensureAddAll([parent, sibling]);

      game.update(0);
      expect(parent.updates, 1);
      expect(child.updates, 1);
      expect(sibling.updates, 1);

      parent.updatePaused = true;
      game.update(0);
      game.update(0);
      expect(parent.updates, 1);
      expect(child.updates, 1);
      expect(sibling.updates, 3);

      parent.updatePaused = false;
      game.update(0);
      expect(parent.updates, 2);
      expect(child.updates, 2);
      expect(sibling.updates, 4);
    });

    testWithFlameGame('paused components still render', (game) async {
      final component = _Counter();
      await game.world.ensureAdd(component);
      component.updatePaused = true;

      game.update(0);
      game.render(MockCanvas());
      expect(component.updates, 0);
      expect(component.renders, 1);
    });

    testWithFlameGame('pause works inside a custom traversal subtree', (
      game,
    ) async {
      final pausable = _Counter();
      final running = _Counter();
      final barrier = _ScaledBarrier(children: [pausable, running]);
      await game.world.ensureAdd(barrier);

      pausable.updatePaused = true;
      game.update(0);
      expect(pausable.updates, 0);
      expect(running.updates, 1);
    });

    testWithFlameGame('lifecycle events still process while paused', (
      game,
    ) async {
      final parent = _Counter();
      await game.world.ensureAdd(parent);
      parent.updatePaused = true;

      final child = _Counter();
      parent.add(child);
      game.update(0);
      await game.ready();

      expect(child.isMounted, isTrue);
      expect(child.updates, 0);
    });
  });
}

class _Counter extends Component {
  _Counter({super.children});

  int updates = 0;
  int renders = 0;

  @override
  void update(double dt) {
    updates++;
  }

  @override
  void render(Canvas canvas) {
    renders++;
  }
}

class _ScaledBarrier extends Component implements CustomTraversal {
  _ScaledBarrier({super.children});

  @override
  void updateSubtree(double dt) => super.updateSubtree(dt * 2);
}
