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
  /// If the component has a parent it will be set here
  @override
  T? get parent => super.parent != null ? super.parent! as T : null;

  T _affectedParent(Component component) {
    if (parent is T) {
      return parent!;
    } else {
      return _affectedParent(parent!);
    }
  }

  T? affectedComponent;

  Function()? onComplete;

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

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
  double? percentage;
  double curveProgress = 0.0;
  double peakTime = 0.0;
  double currentTime = 0.0;
  double driftTime = 0.0;
  int curveDirection = 1;
  Curve curve;

  /// If this is set to true the effect will not be set to its original state
  /// once it is done.
  bool skipEffectReset = false;

  double get iterationTime => peakTime * (isAlternating ? 2 : 1);

  ComponentEffect(
    this._initialIsInfinite,
    this._initialIsAlternating, {
    this.isRelative = false,
    bool? removeOnFinish,
    Curve? curve,
    this.onComplete,
  })  : isInfinite = _initialIsInfinite,
        isAlternating = _initialIsAlternating,
        removeOnFinish = removeOnFinish ?? true,
        curve = curve ?? Curves.linear;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    affectedComponent = _affectedParent(parent!);
  }

  @override
  @mustCallSuper
  void update(double dt) {
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
      curveProgress = curve.transform(percentage!);
      _updateDriftTime();
      currentTime = currentTime.clamp(0.0, peakTime).toDouble();
    }
  }

  void dispose() => _isDisposed = true;

  /// Whether the effect has completed or not.
  bool hasCompleted() {
    return (!isInfinite && !isAlternating && isMax()) ||
        (!isInfinite && isAlternating && isMin()) ||
        isDisposed;
  }

  bool isMax() => percentage == null ? false : percentage == 1.0;
  bool isMin() => percentage == null ? false : percentage == 0.0;
  bool isRootEffect() {
    return parent is! ComponentEffect;
  }

  /// Resets the effect and the component which the effect was added to.
  void reset() {
    resetEffect();
    setComponentToOriginalState();
  }

  /// Resets the effect to its original state so that it can be re-run.
  void resetEffect() {
    _isDisposed = false;
    percentage = null;
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
    onComplete?.call();
    if (!skipEffectReset) {
      resetEffect();
    }
  }

  void setComponentToOriginalState();
  void setComponentToEndState();
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
          removeOnFinish: removeOnFinish,
          curve: curve,
          onComplete: onComplete,
        );

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    super.onLoad();
    final component = parent!;

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
        parent?.position.setFrom(position!);
      }
      if (modifiesAngle) {
        assert(
          angle != null,
          '`angle` must not be `null` for an effect which modifies `angle`',
        );
        parent?.angle = angle!;
      }
      if (modifiesSize) {
        assert(
          size != null,
          '`size` must not be `null` for an effect which modifies `size`',
        );
        parent?.size.setFrom(size!);
      }
      if (modifiesScale) {
        assert(
          scale != null,
          '`scale` must not be `null` for an effect which modifies `scale`',
        );
        parent?.scale.setFrom(scale!);
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
  void clearEffects() {
    children.removeAll(effects());
  }

  List<ComponentEffect> effects() {
    // TODO: check if query is registered
    return children.query<ComponentEffect>();
  }
}
