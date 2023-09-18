import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

class AdvancedButtonComponent extends PositionComponent
    with HoverCallbacks, TapCallbacks {
  AdvancedButtonComponent({
    PositionComponent? defaultSkin,
    PositionComponent? downSkin,
    PositionComponent? hoverSkin,
    this.onPressed,
    bool isSelectable = false,
    PositionComponent? defaultSelectedSkin,
    PositionComponent? downAndSelectedSkin,
    PositionComponent? hoverAndSelectedSkin,
    PositionComponent? disabledSkin,
    PositionComponent? disabledAndSelectedSkin,
    super.size,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) {
    size.addListener(_updateSizes);
    this.defaultSkin = defaultSkin;
    this.downSkin = downSkin;
    this.hoverSkin = hoverSkin;
    this.defaultSelectedSkin = defaultSelectedSkin;
    this.downAndSelectedSkin = downAndSelectedSkin;
    this.hoverAndSelectedSkin = hoverAndSelectedSkin;
    this.disabledSkin = disabledSkin;
    this.disabledAndSelectedSkin = disabledAndSelectedSkin;
    setIsSelectable(isSelectable: isSelectable);
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

  bool _isPressed = false;

  @override
  @mustCallSuper
  void onTapDown(TapDownEvent event) {
    if (_isDisabled) {
      return;
    }
    onPressed?.call();
    _isPressed = true;
    _updateState();
  }

  void Function()? onPressed;

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    if (_isSelectable) {
      setSelected(isSelected: !_isSelected);
      return;
    }
    _updateState();
  }

  bool _isHovered = false;

  @override
  void onHoverEnter() {
    _isHovered = true;
    _updateState();
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    _isPressed = false;
    _updateState();
  }

  Map<ButtonState, PositionComponent?> skinsMap = {};

  PositionComponent? get defaultSkin => skinsMap[ButtonState.up];

  set defaultSkin(PositionComponent? value) {
    skinsMap[ButtonState.up] = value;
    if (size.isZero()) {
      size = skinsMap[ButtonState.up]?.size ?? Vector2.zero();
    }
    _invalidateSkins();
  }

  set downSkin(PositionComponent? value) {
    skinsMap[ButtonState.down] = value;
    _invalidateSkins();
  }

  set defaultSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.upAndSelected] = value;
    _invalidateSkins();
  }

  set downAndSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.downAndSelected] = value;
    _invalidateSkins();
  }

  set hoverSkin(PositionComponent? value) {
    skinsMap[ButtonState.hover] = value;
    _invalidateSkins();
  }

  set hoverAndSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.hoverAndSelected] = value;
    _invalidateSkins();
  }

  set disabledSkin(PositionComponent? value) {
    skinsMap[ButtonState.disabled] = value;
    _invalidateSkins();
  }

  set disabledAndSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.disabledAndSelected] = value;
    _invalidateSkins();
  }

  void _invalidateSkins() {
    _updateSizes();
    _updateState();
  }

  bool _isDisabled = false;

  bool get isDisabled => _isDisabled;

  void setDisabled({required bool isDisabled}) {
    if (_isDisabled == isDisabled) {
      return;
    }
    _isDisabled = isDisabled;
    _updateState();
  }

  bool _isSelectable = false;

  bool get isSelectable => _isSelectable;

  void setIsSelectable({required bool isSelectable}) {
    if (_isSelectable == isSelectable) {
      return;
    }
    _isSelectable = isSelectable;
    _updateState();
  }

  bool _isSelected = false;

  bool get isSelected => _isSelected;

  void setSelected({required bool isSelected}) {
    if (_isSelected == isSelected) {
      return;
    }
    _isSelected = isSelected;
    _updateState();
  }

  void _updateSizes() {
    for (final skin in skinsMap.values) {
      skin?.size = size;
    }
  }

  void _updateState() {
    final isSelectableAndSelected = _isSelectable && _isSelected;
    if (_isDisabled) {
      _setState(
        isSelectableAndSelected &&
            _hasSkinForState(ButtonState.disabledAndSelected)
            ? ButtonState.disabledAndSelected
            : ButtonState.disabled,
      );
      return;
    }
    if (_isPressed) {
      _setState(
        isSelectableAndSelected && _hasSkinForState(ButtonState.downAndSelected)
            ? ButtonState.downAndSelected
            : ButtonState.down,
      );
      return;
    }
    if (_isHovered) {
      final hoverState = isSelectableAndSelected
          ? ButtonState.hoverAndSelected
          : ButtonState.hover;
      if (_hasSkinForState(hoverState)) {
        _setState(hoverState);
        return;
      }
    }
    _setState(
      isSelectableAndSelected && _hasSkinForState(ButtonState.upAndSelected)
          ? ButtonState.upAndSelected
          : ButtonState.up,
    );
  }

  ButtonState _state = ButtonState.up;

  void _setState(ButtonState value) {
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

  bool _hasSkinForState(ButtonState state) {
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
}
