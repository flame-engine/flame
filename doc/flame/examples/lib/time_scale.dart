import 'dart:async';

import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class TimeScaleGame extends FlameGame with HasTimeScale {
  final _timeScales = [0.5, 1.0, 2.0];
  var _index = 1;

  @override
  Future<void> onLoad() async {
    await add(
      EmberPlayer(
        position: size / 2,
        size: size / 4,
        onTap: (p0) => timeScale = getNextTimeScale(),
      ),
    );
    return super.onLoad();
  }

  double getNextTimeScale() {
    ++_index;
    if (_index >= _timeScales.length) {
      _index = 0;
    }
    return _timeScales[_index];
  }
}
