import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// The [AdvancedButtonComponent] has different skins for
/// different button states.
///
/// Note: You have to set the [defaultSkin],[downSkin],[hoverSkin]
/// [disabledSkin] in [onLoad] if you are not passing it in through
/// the constructor

class AdvancedButtonComponent extends PositionComponent
    with HoverCallbacks, TapCallbacks {
  AdvancedButtonComponent({
    this.onPressed,
    this.onChangeState,
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

  /// Callback for what should happen when the button is pressed.
  void Function()? onPressed;

  /// Callback when button state changes
  void Function(ButtonState state)? onChangeState;

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(skinContainer);
  }

  @protected
  final skinContainer = PositionComponent();

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
      defaultSkin!.parent = skinContainer;
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
    _updateSkin();
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
      setState(ButtonState.hover);
      return;
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
    _updateSkin();
    onChangeState?.call(_state);
  }

  void _updateSkin() {
    _removeSkins();
    addSkin(_state);
  }

  @protected
  void addSkin(ButtonState state) {
    (skinsMap[state] ?? defaultSkin)?.parent = skinContainer;
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

  bool get isDefaultSelected {
    return this == ButtonState.upAndSelected;
  }

  bool get isNotDefault {
    return !isDefault;
  }

  bool get isDown {
    return this == ButtonState.down;
  }

  bool get isDownAndSelected {
    return this == ButtonState.downAndSelected;
  }

  bool get isHover {
    return this == ButtonState.hover;
  }

  bool get isHoverAndSelected {
    return this == ButtonState.hoverAndSelected;
  }

  bool get isHoverOrHoverAndSelected {
    return isHover || isHoverAndSelected;
  }

  bool get isDisabled {
    return this == ButtonState.disabled;
  }

  bool get isDisabledAndSelected {
    return this == ButtonState.disabledAndSelected;
  }
}
