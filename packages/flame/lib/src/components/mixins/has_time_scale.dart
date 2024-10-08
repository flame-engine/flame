import 'package:flame/src/components/core/component.dart';

/// This mixin allows components to control their speed as compared to the
/// normal speed. Only framerate independent logic will benefit from [timeScale]
/// changes.
///
/// Note: Modified [timeScale] will be applied to all children as well.
mixin HasTimeScale on Component {
  /// The ratio of components tick speed and normal tick speed.
  /// It defaults to 1.0, which means the component moves normally.
  /// A value of 0.5 means the component moves half the normal speed
  /// and a value of 2.0 means the component moves twice as fast.
  double _timeScale = 1.0;

  /// Returns the current time scale.
  double get timeScale => _timeScale;

  /// Sets the time scale to given value if it is non-negative.
  /// Note: Too high values will result in inconsistent gameplay
  /// and tunneling in physics.
  set timeScale(double value) {
    if (value.isNegative) {
      return;
    }
    _timeScale = value;
  }

  @override
  void update(double dt) {
    super.update(dt * (parent == null ? _timeScale : 1.0));
  }

  @override
  void updateTree(double dt) {
    super.updateTree(dt * (parent != null ? _timeScale : 1.0));
  }

  /// Pauses the component by setting the time scale to 0.0.
  void pause() {
    timeScale = 0.0;
  }

  /// Resumes the component by setting the time scale to 1.0 or to the given
  /// value.
  void resume({double? newTimeScale}) {
    if (timeScale == 0.0) {
      timeScale = newTimeScale ?? 1.0;
    }
  }
}
