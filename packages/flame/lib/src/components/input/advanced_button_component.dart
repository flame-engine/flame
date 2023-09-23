import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

class AdvancedButtonComponent extends PositionComponent
    with HoverCallbacks, TapCallbacks {
  AdvancedButtonComponent({
    this.onPressed,
    PositionComponent? defaultSkin,
    PositionComponent? downSkin,
    PositionComponent? hoverSkin,
    PositionComponent? disabledSkin,
    super.size,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) {
    this.defaultSkin = defaultSkin;
    this.downSkin = downSkin;
    this.hoverSkin = hoverSkin;
    this.disabledSkin = disabledSkin;
    size.addListener(_updateSizes);
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
    defaultSkin != null,
    'The defaultSkin has to either be passed '
        'in as an argument or set in onLoad',
    );
    if (_state.isDefault && !contains(defaultSkin!)) {
      add(defaultSkin!);
    }
  }

  @protected
  bool isPressed = false;

  @override
  @mustCallSuper
  void onTapDown(TapDownEvent event) {
    if (_isDisabled) {
      return;
    }
    onPressed?.call();
    isPressed = true;
    updateState();
  }

  void Function()? onPressed;

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    updateState();
  }

  @override
  void onHoverEnter() {
    updateState();
  }

  @override
  void onHoverExit() {
    isPressed = false;
    updateState();
  }

  Map<ButtonState, PositionComponent?> skinsMap = {};

  PositionComponent? get defaultSkin => skinsMap[ButtonState.up];

  set defaultSkin(PositionComponent? value) {
    skinsMap[ButtonState.up] = value;
    if (size.isZero()) {
      size = skinsMap[ButtonState.up]?.size ?? Vector2.zero();
    }
    invalidateSkins();
  }

  set downSkin(PositionComponent? value) {
    skinsMap[ButtonState.down] = value;
    invalidateSkins();
  }

  set hoverSkin(PositionComponent? value) {
    skinsMap[ButtonState.hover] = value;
    invalidateSkins();
  }

  set disabledSkin(PositionComponent? value) {
    skinsMap[ButtonState.disabled] = value;
    invalidateSkins();
  }

  @protected
  void invalidateSkins() {
    _updateSizes();
    updateState();
  }

  bool _isDisabled = false;

  bool get isDisabled => _isDisabled;

  set isDisabled(bool value) {
    if (_isDisabled == value) {
      return;
    }
    _isDisabled = value;
    updateState();
  }

  void _updateSizes() {
    for (final skin in skinsMap.values) {
      skin?.size = size;
    }
  }

  @protected
  void updateState() {
    if (isDisabled) {
      setState(ButtonState.disabled);
      return;
    }
    if (isPressed) {
      setState(ButtonState.down);
      return;
    }
    if (isHovered) {
      if (hasSkinForState(ButtonState.hover)) {
        setState(ButtonState.hover);
        return;
      }
    }
    setState(ButtonState.up);
  }

  ButtonState _state = ButtonState.up;

  @protected
  void setState(ButtonState value) {
    if (_state == value) {
      return;
    }
    _state = value;
    _removeSkins();
    _addSkin(_state);
  }

  void _addSkin(ButtonState state) {
    (skinsMap[state] ?? defaultSkin)?.parent = this;
  }

  void _removeSkins() {
    for (final state in ButtonState.values) {
      if (state != _state) {
        _removeSkin(state);
      }
    }
  }

  void _removeSkin(ButtonState state) {
    if (skinsMap[state]?.parent != null) {
      skinsMap[state]?.removeFromParent();
    }
  }

  @protected
  bool hasSkinForState(ButtonState state) {
    return skinsMap[state] != null;
  }
}

enum ButtonState {
  up,
  upAndSelected,
  down,
  downAndSelected,
  hover,
  hoverAndSelected,
  disabled,
  disabledAndSelected;

  const ButtonState();

  bool get isDefault {
    return this == ButtonState.up;
  }

  bool get isNotDefault {
    return !isDefault;
  }
}
