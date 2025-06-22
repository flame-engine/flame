import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/post_process.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart';

class _CallbackPostProcess extends PostProcess {
  _CallbackPostProcess(this.callback);

  final void Function() callback;

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    renderSubtree(canvas);
    callback();
  }
}

void main() {
  group('$PostProcessSequentialGroup', () {
    test('render in canvas in sequence', () {
      final calls = <String>[];
      final postProcess1 = _CallbackPostProcess(() => calls.add('1'));
      final postProcess2 = _CallbackPostProcess(() => calls.add('2'));
      final postProcess3 = _CallbackPostProcess(() => calls.add('3'));
      final postProcess = PostProcessSequentialGroup(
        postProcesses: [
          postProcess1,
          postProcess2,
          postProcess3,
        ],
      );

      postProcess.render(
        MockCanvas(),
        Vector2(0, 0),
        (canvas) {
          calls.add('render');
        },
        (postProcess) {},
      );

      expect(calls, [
        'render',
        '1',
        '2',
        '3',
      ]);
    });
  });
}
