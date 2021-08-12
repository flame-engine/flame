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

abstract class ComponentEffect<T extends Component> extends BaseComponent {
  /// If the component has a parent it will be set here
  T _affectedParent(Component component) {
    if (parent is T) {
      return parent! as T;
    } else {
      return _affectedParent(parent!);
    }
  }

  T? affectedParent;

  Function()? onComplete;

  bool _isPaused = false;
  bool get isPaused => _isPaused;
  void resume() => _isPaused = false;
  void pause() => _isPaused = true;

  /// If the animation should first follow the initial curve and then follow the
  /// curve backwards
  bool isInfinite;
  bool isAlternating;
  final bool isRelative;
  final bool removeOnFinish;
  final bool _initialIsInfinite;
  final bool _initialIsAlternating;

  /// The percentage of the effect that has passed including [preOffset] and
  /// [postOffset].
  double percentage = 0.0;

  /// The outcome the curve function, only updates after [preOffset] and before
  /// [postOffset]
  double curveProgress = 0.0;

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

  /// The time (in seconds) that should pass before the component starts each
  /// iteration.
  double preOffset;

  /// The time (in seconds) that should pass before the component ends each
  /// iteration.
  double postOffset;

  /// The total time offset spent waiting in one iteration, so from the start to
  /// the end of the effect and then back again if it [isAlternating].
  double get totalOffset => preOffset + postOffset * (isAlternating ? 2 : 1);

  /// The [preOffset] that the component was initialized with.
  final double originalPreOffset;

  /// The [postOffset] that the component was initialized with.
  final double originalPostOffset;

  /// If this is set to true the effect will not be set to its original state
  /// once it is done.
  bool skipEffectReset = false;

  /// The total time of one iteration of the effect, including offsets.
  double get iterationTime => peakTime * (isAlternating ? 2 : 1);

  ComponentEffect(
    this._initialIsInfinite,
    this._initialIsAlternating, {
    this.isRelative = false,
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    Curve? curve,
    this.onComplete,
  })  : isInfinite = _initialIsInfinite,
        isAlternating = _initialIsAlternating,
        preOffset = preOffset ?? 0.0,
        postOffset = postOffset ?? 0.0,
        originalPreOffset = preOffset ?? 0.0,
        originalPostOffset = postOffset ?? 0.0,
        removeOnFinish = removeOnFinish ?? true,
        curve = curve ?? Curves.linear;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    affectedParent = _affectedParent(parent!);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    if (isAlternating) {
      curveDirection = isMax() ? -1 : (isMin() ? 1 : curveDirection);
    }
    if (isInfinite) {
      if ((!isAlternating && isMax()) || (isAlternating && isMin())) {
        reset();
      }
    }
    if (hasCompleted()) {
      setComponentToEndState();
      if (removeOnFinish) {
        removeFromParent();
      }
    } else {
      currentTime += (dt + driftTime) * curveDirection;
      percentage = (currentTime / peakTime).clamp(0.0, 1.0).toDouble();
      if (currentTime >= preOffset && currentTime <= peakTime - postOffset) {
        final effectPercentage = percentage - preOffset / peakTime;
        curveProgress = curve.transform(effectPercentage);
      }
      _updateDriftTime();
      currentTime = currentTime.clamp(0.0, peakTime).toDouble();
    }
  }

  /// Whether the effect has completed or not.
  bool hasCompleted() {
    return (!isInfinite && !isAlternating && isMax()) ||
        (!isInfinite && isAlternating && isMin()) ||
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
    preOffset = originalPreOffset;
    postOffset = originalPostOffset;
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
    onComplete?.call();
    if (!skipEffectReset) {
      resetEffect();
    }
  }

  void setComponentToOriginalState();
  void setComponentToEndState();

  void setPeakTimeFromDuration(double duration) {
    peakTime = duration / (isAlternating ? 2 : 1) + preOffset + postOffset;
  }
}

abstract class PositionComponentEffect
    extends ComponentEffect<PositionComponent> {
  /// Used to be able to determine the start state of the component
  Vector2? originalPosition;
  double? originalAngle;
  Vector2? originalSize;
  Vector2? originalScale;

  /// Used to be able to determine the end state of a sequence of effects
  Vector2? endPosition;
  double? endAngle;
  Vector2? endSize;
  Vector2? endScale;

  /// Whether the state of a certain field was modified by the effect
  final bool modifiesPosition;
  final bool modifiesAngle;
  final bool modifiesSize;
  final bool modifiesScale;

  PositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    bool isRelative = false,
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    Curve? curve,
    this.modifiesPosition = false,
    this.modifiesAngle = false,
    this.modifiesSize = false,
    this.modifiesScale = false,
    VoidCallback? onComplete,
  }) : super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          preOffset: preOffset,
          postOffset: postOffset,
          removeOnFinish: removeOnFinish,
          curve: curve,
          onComplete: onComplete,
        );

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final component = affectedParent!;

    originalPosition = component.position.clone();
    originalAngle = component.angle;
    originalSize = component.size.clone();
    originalScale = component.scale.clone();

    /// If these aren't modified by the extending effect it is assumed that the
    /// effect didn't bring the component to another state than the one it
    /// started in
    endPosition = component.position.clone();
    endAngle = component.angle;
    endSize = component.size.clone();
    endScale = component.scale.clone();
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
    if (isRootEffect()) {
      if (modifiesPosition) {
        assert(
          position != null,
          '`position` must not be `null` for an effect which modifies `position`',
        );
        affectedParent?.position.setFrom(position!);
      }
      if (modifiesAngle) {
        assert(
          angle != null,
          '`angle` must not be `null` for an effect which modifies `angle`',
        );
        affectedParent?.angle = angle!;
      }
      if (modifiesSize) {
        assert(
          size != null,
          '`size` must not be `null` for an effect which modifies `size`',
        );
        affectedParent?.size.setFrom(size!);
      }
      if (modifiesScale) {
        assert(
          scale != null,
          '`scale` must not be `null` for an effect which modifies `scale`',
        );
        affectedParent?.scale.setFrom(scale!);
      }
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
  void setComponentToEndState() {
    _setComponentState(endPosition, endAngle, endSize, endScale);
  }
}

abstract class SimplePositionComponentEffect extends PositionComponentEffect {
  double? duration;
  double? speed;

  SimplePositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    this.duration,
    this.speed,
    Curve? curve,
    bool isRelative = false,
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    bool modifiesPosition = false,
    bool modifiesAngle = false,
    bool modifiesSize = false,
    bool modifiesScale = false,
    VoidCallback? onComplete,
  })  : assert(
          (duration != null) ^ (speed != null),
          'Either speed or duration necessary',
        ),
        super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          preOffset: preOffset,
          postOffset: postOffset,
          removeOnFinish: removeOnFinish,
          curve: curve,
          modifiesPosition: modifiesPosition,
          modifiesAngle: modifiesAngle,
          modifiesSize: modifiesSize,
          modifiesScale: modifiesScale,
          onComplete: onComplete,
        );
}

mixin EffectsHelper on Component {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    children.register<ComponentEffect>();
  }

  void clearEffects() {
    children.removeAll(effects());
  }

  List<ComponentEffect> effects() {
    return children.query<ComponentEffect>();
  }
}
