import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('CustomTraversal', () {
    testWithFlameGame('default updateSubtree matches standard traversal', (
      game,
    ) async {
      final child = _DtRecorder();
      final parent = _PlainBarrier(children: [child]);
      await game.world.ensureAdd(parent);

      game.update(0.5);
      expect(child.recordedDts, [0.5]);
    });

    testWithFlameGame('updateSubtree can modify the dt for the subtree', (
      game,
    ) async {
      final child = _DtRecorder();
      final grandChild = _DtRecorder();
      child.add(grandChild);
      final parent = _HalfSpeedBarrier(children: [child]);
      await game.world.ensureAdd(parent);

      game.update(1.0);
      expect(child.recordedDts, [0.5]);
      expect(grandChild.recordedDts, [0.5]);
    });

    testWithFlameGame('updateSubtree can skip the subtree entirely', (
      game,
    ) async {
      final child = _DtRecorder();
      final parent = _FrozenBarrier(children: [child]);
      await game.world.ensureAdd(parent);

      game.update(1.0);
      expect(parent.recordedDts, isEmpty);
      expect(child.recordedDts, isEmpty);

      parent.frozen = false;
      game.update(1.0);
      expect(parent.recordedDts, [1.0]);
      expect(child.recordedDts, [1.0]);
    });

    testWithFlameGame('barrier subtrees still process nested barriers', (
      game,
    ) async {
      final inner = _DtRecorder();
      final innerBarrier = _HalfSpeedBarrier(children: [inner]);
      final outerBarrier = _HalfSpeedBarrier(children: [innerBarrier]);
      await game.world.ensureAdd(outerBarrier);

      game.update(1.0);
      expect(inner.recordedDts, [0.25]);
    });
  });
}

class _DtRecorder extends Component {
  final List<double> recordedDts = [];

  @override
  void update(double dt) {
    recordedDts.add(dt);
  }
}

class _PlainBarrier extends Component implements CustomTraversal {
  _PlainBarrier({super.children});
}

class _HalfSpeedBarrier extends Component implements CustomTraversal {
  _HalfSpeedBarrier({super.children});

  @override
  void updateSubtree(double dt) => super.updateSubtree(dt / 2);
}

class _FrozenBarrier extends _DtRecorder implements CustomTraversal {
  _FrozenBarrier({List<Component>? children}) {
    if (children != null) {
      addAll(children);
    }
  }

  bool frozen = true;

  @override
  void updateSubtree(double dt) {
    if (!frozen) {
      super.updateSubtree(dt);
    }
  }
}
