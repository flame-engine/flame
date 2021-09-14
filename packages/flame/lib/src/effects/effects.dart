import 'package:flutter/material.dart';

import '../../components.dart';
import '../components/position_component.dart';
import '../extensions/vector2.dart';

export './color_effect.dart';
export './move_effect.dart';
export './opacity_effect.dart';
export './rotate_effect.dart';
export './sequence_effect.dart';
export './size_effect.dart';

abstract class ComponentEffect<T extends Component> extends Component {
  T _affectedParent(Component? component) {
    if (component is T) {
      return component;
    } else {
      return _affectedParent(component!.parent);
    }
  }

  /// If the effect has a parent further up in the tree that will be affected by
  /// this effect, that parent will be set here.
  late T affectedParent;

  /// The callback that is called when the effect is completed.
  Function()? onComplete;

  bool _isPaused = false;

  /// Whether the effect is paused or not.
  bool get isPaused => _isPaused;

  /// Resume the effect from a paused state.
  void resume() => _isPaused = false;

  /// Pause the effect.
  void pause() => _isPaused = true;

  /// If the effect should first follow the initial curve and then follow the
  /// curve backwards.
  bool isAlternating;

  /// Whether the effect should continue to loop forever.
  bool isInfinite;

  /// Whether the effect should be removed from its parent once it has
  /// completed.
  bool removeOnFinish;

  /// If the effect is relative to the current state of the component or not.
  final bool isRelative;

  final bool _initialIsInfinite;
  final bool _initialIsAlternating;

  /// The percentage of the effect that has passed including [initialDelay] and
  /// [peakDelay].
  double percentage = 0.0;

  /// The outcome the curve function, only updates after [initialDelay] and before
  /// [peakDelay].
  double curveProgress = 0.0;

  /// Whether the effect has started or not.
  bool hasStarted = false;

  /// How much time it takes for the effect to peak, which means right before it
  /// starts any potential reversal or reset. Including both offsets.
  double peakTime = 0.0;

  /// The time passed since the start of the effect, it will start to decrease
  /// after it has reached [peakTime] if [isAlternating] is true, and reset to
  /// zero if it is not.
  double currentTime = 0.0;

  /// When an effect reaches the end, and the beginning if it is alternating,
  /// it will overshoot 0.0 and [peakTime], this time is added to the next time
  /// step.
  double driftTime = 0.0;

  /// Whether the effect is going forward or is reversing.
  ///
  /// Reversing in this context means that after the effect has peaked and if it
  /// has [isAlternating] set to true, it will do the effect backwards back to
  /// its original state.
  int curveDirection = 1;

  /// Which curve that the effect is following.
  Curve curve;

  /// The time (in seconds) that should pass before the effect starts each
  /// iteration.
  double initialDelay;

  /// The time (in seconds) that should pass before the effect ends each
  /// peak.
  double peakDelay;

  /// The total time offset spent waiting in one iteration, so from the start to
  /// the end of the effect and then back again if it [isAlternating].
  double get totalOffset => initialDelay + peakDelay * (isAlternating ? 2 : 1);

  /// If this is set to true the effect will not be set to its original state
  /// once it is done.
  bool skipEffectReset = false;

  /// The total time of one iteration of the effect, including offsets.
  double get iterationTime => peakTime * (isAlternating ? 2 : 1);

  ComponentEffect(
    this._initialIsInfinite,
    this._initialIsAlternating, {
    this.isRelative = false,
    double? initialDelay,
    double? peakDelay,
    bool? removeOnFinish,
    Curve? curve,
    this.onComplete,
  })  : isInfinite = _initialIsInfinite,
        isAlternating = _initialIsAlternating,
        initialDelay = initialDelay ?? 0.0,
        peakDelay = peakDelay ?? 0.0,
        removeOnFinish = removeOnFinish ?? true,
        curve = curve ?? Curves.linear;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    affectedParent = _affectedParent(parent);
    parent?.children.register<ComponentEffect>();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (isPaused) {
      return;
    }
    super.update(dt);
    if (isAlternating) {
      curveDirection = isMax() ? -1 : (isMin() ? 1 : curveDirection);
    }
    if (isInfinite) {
      if ((!isAlternating && isMax()) || (isAlternating && isMin())) {
        reset();
      }
    }

    currentTime += (dt + driftTime) * curveDirection;
    percentage = (currentTime / peakTime).clamp(0.0, 1.0).toDouble();
    if (currentTime >= initialDelay && currentTime <= peakTime - peakDelay) {
      final effectPercentage =
          ((currentTime - initialDelay) / (peakTime - initialDelay - peakDelay))
              .clamp(0.0, 1.0);
      curveProgress = curve.transform(effectPercentage);
    }
    _updateDriftTime();
    currentTime = currentTime.clamp(0.0, peakTime).toDouble();

    if (hasCompleted()) {
      setComponentToEndState();
      onComplete?.call();
      if (removeOnFinish) {
        removeFromParent();
      }
    }
    hasStarted = true;
  }

  /// Whether the effect has completed or not.
  bool hasCompleted() {
    return (!isInfinite && !isAlternating && isMax()) ||
        (!isInfinite && isAlternating && isMin() && hasStarted) ||
        shouldRemove;
  }

  /// Whether the effect has reached its end, before potentially reversing
  bool isMax() => percentage == 1.0;

  /// Whether the effect is at its beginning
  bool isMin() => percentage == 0.0;

  bool isRootEffect() {
    return parent is! ComponentEffect;
  }

  /// Resets the effect and the component which the effect was added to.
  @mustCallSuper
  void reset() {
    resetEffect();
    setComponentToOriginalState();
  }

  /// Resets the effect to its original state so that it can be re-run.
  @mustCallSuper
  void resetEffect() {
    shouldRemove = false;
    percentage = 0.0;
    currentTime = 0.0;
    curveDirection = 1;
    isInfinite = _initialIsInfinite;
    isAlternating = _initialIsAlternating;
  }

  // When the time overshoots the max and min it needs to add that time to
  // whatever is going to happen next, for example an alternation or
  // following effect in a SequenceEffect.
  void _updateDriftTime() {
    if (isMax()) {
      driftTime = currentTime - peakTime;
    } else if (isMin()) {
      driftTime = currentTime.abs();
    } else {
      driftTime = 0;
    }
  }

  /// Called when the effect is removed from the component.
  /// Calls the [onComplete] callback if it is defined and sets the effect back
  /// to its original state so that it can be re-added.
  @override
  void onRemove() {
    super.onRemove();
    if (!skipEffectReset) {
      resetEffect();
    }
  }

  /// Sets the affected component to the state that it should be in before the
  /// effect is started.
  void setComponentToOriginalState();

  /// Sets the affected component to the state that it should be in when the
  /// effect is peaking (before it potentially starts reversing).
  void setComponentToPeakState();

  /// Sets the affected component to the state that it should be in after the
  /// effect is done.
  void setComponentToEndState() {
    isAlternating ? setComponentToOriginalState() : setComponentToPeakState();
  }

  void setPeakTimeFromDuration(double duration) {
    peakTime = duration / (isAlternating ? 2 : 1) + initialDelay + peakDelay;
  }
}

abstract class PositionComponentEffect
    extends ComponentEffect<PositionComponent> {
  /// The duration of the effect
  double? duration;

  /// The speed of the effect
  double? speed;

  /// Used to be able to determine the start state of the component
  Vector2? originalPosition;
  double? originalAngle;
  Vector2? originalSize;
  Vector2? originalScale;

  /// Used to be able to determine what state that the component should be in
  /// when the effect is peaking.
  Vector2? peakPosition;
  double? peakAngle;
  Vector2? peakSize;
  Vector2? peakScale;

  /// Used to be able to determine what state that the component should be in
  /// when the effect is done.
  Vector2? get endPosition => isAlternating ? originalPosition : peakPosition;
  double? get endAngle => isAlternating ? originalAngle : peakAngle;
  Vector2? get endSize => isAlternating ? originalSize : peakSize;
  Vector2? get endScale => isAlternating ? originalScale : peakScale;

  /// Whether the state of a certain field was modified by the effect
  bool modifiesPosition;
  bool modifiesAngle;
  bool modifiesSize;
  bool modifiesScale;

  PositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    this.duration,
    this.speed,
    bool isRelative = false,
    double? initialDelay,
    double? peakDelay,
    bool? removeOnFinish,
    Curve? curve,
    this.modifiesPosition = false,
    this.modifiesAngle = false,
    this.modifiesSize = false,
    this.modifiesScale = false,
    VoidCallback? onComplete,
  })  : assert(
          (duration != null) ^ (speed != null),
          'Either speed or duration necessary',
        ),
        super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          initialDelay: initialDelay,
          peakDelay: peakDelay,
          removeOnFinish: removeOnFinish,
          curve: curve,
          onComplete: onComplete,
        );

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final component = affectedParent;

    originalPosition = component.position.clone();
    originalAngle = component.angle;
    originalSize = component.size.clone();
    originalScale = component.scale.clone();

    /// If these aren't modified by the extending effect it is assumed that the
    /// effect didn't bring the component to another state than the one it
    /// started in
    peakPosition = component.position.clone();
    peakAngle = component.angle;
    peakSize = component.size.clone();
    peakScale = component.scale.clone();
  }

  /// Only change the parts of the component that is affected by the
  /// effect, and only set the state if it is the root effect (not part of
  /// another effect, like children of a CombinedEffect or SequenceEffect).
  void _setComponentState(
    Vector2? position,
    double? angle,
    Vector2? size,
    Vector2? scale,
  ) {
    if (modifiesPosition) {
      assert(
        position != null,
        '`position` must not be `null` for an effect which modifies `position`',
      );
      affectedParent.position.setFrom(position!);
    }
    if (modifiesAngle) {
      assert(
        angle != null,
        '`angle` must not be `null` for an effect which modifies `angle`',
      );
      affectedParent.angle = angle!;
    }
    if (modifiesSize) {
      assert(
        size != null,
        '`size` must not be `null` for an effect which modifies `size`',
      );
      affectedParent.size.setFrom(size!);
    }
    if (modifiesScale) {
      assert(
        scale != null,
        '`scale` must not be `null` for an effect which modifies `scale`',
      );
      affectedParent.scale.setFrom(scale!);
    }
  }

  @override
  void setComponentToOriginalState() {
    _setComponentState(
      originalPosition,
      originalAngle,
      originalSize,
      originalScale,
    );
  }

  @override
  void setComponentToPeakState() {
    _setComponentState(peakPosition, peakAngle, peakSize, peakScale);
  }
}

mixin EffectsHelper on Component {
  void clearEffects() {
    children.removeAll(effects);
  }

  List<ComponentEffect> get effects {
    return children.isRegistered<ComponentEffect>()
        ? children.query<ComponentEffect>()
        : [];
  }
}
