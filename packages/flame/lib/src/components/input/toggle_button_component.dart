import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

class ToggleButtonComponent extends AdvancedButtonComponent {
  ToggleButtonComponent({
    super.onPressed,
    this.onSelected,
    super.onChangeState,
    super.defaultSkin,
    super.downSkin,
    super.hoverSkin,
    super.disabledSkin,
    PositionComponent? defaultSelectedSkin,
    PositionComponent? downAndSelectedSkin,
    PositionComponent? hoverAndSelectedSkin,
    PositionComponent? disabledAndSelectedSkin,
    super.size,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) {
    this.defaultSelectedSkin = defaultSelectedSkin;
    this.downAndSelectedSkin = downAndSelectedSkin;
    this.hoverAndSelectedSkin = hoverAndSelectedSkin;
    this.disabledAndSelectedSkin = disabledAndSelectedSkin;
  }

  ValueChanged<bool>? onSelected;

  @override
  @mustCallSuper
  void onMount() {
    assert(
      defaultSelectedSkin != null,
      'The defaultSelectedSkin has to either be passed '
      'in as an argument or set in onLoad',
    );
    super.onMount();
  }

  PositionComponent? get defaultSelectedSkin =>
      skinsMap[ButtonState.upAndSelected];

  set defaultSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.upAndSelected] = value;
    invalidateSkins();
  }

  set downAndSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.downAndSelected] = value;
    invalidateSkins();
  }

  set hoverAndSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.hoverAndSelected] = value;
    invalidateSkins();
  }

  set disabledAndSelectedSkin(PositionComponent? value) {
    skinsMap[ButtonState.disabledAndSelected] = value;
    invalidateSkins();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    isSelected = !_isSelected;
  }

  bool _isSelected = false;

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    if (_isSelected == value) {
      return;
    }
    _isSelected = value;
    updateState();
    onSelected?.call(_isSelected);
  }

  @override
  @protected
  void addSkin(ButtonState currentState) {
    var skin = skinsMap[currentState];
    if (currentState.isDisabledAndSelected && !hasSkinForState(currentState)) {
      skin = skinsMap[ButtonState.disabled];
    }
    if (currentState.isDownAndSelected && !hasSkinForState(currentState)) {
      skin = skinsMap[ButtonState.down];
    }
    if (currentState.isHoverAndSelected && !hasSkinForState(currentState)) {
      skin = skinsMap[ButtonState.hover];
    }
    if (currentState.isDownAndSelected && !hasSkinForState(currentState)) {
      skin = skinsMap[ButtonState.down];
    }
    skin = skin ?? (isSelected ? defaultSelectedSkin : defaultSkin);
    skin?.parent = skinContainer;
  }

  @mustCallSuper
  @protected
  @override
  void updateState() {
    if (isDisabled) {
      setState(
        _isSelected ? ButtonState.disabledAndSelected : ButtonState.disabled,
      );
      return;
    }
    if (isPressed) {
      setState(
        _isSelected ? ButtonState.downAndSelected : ButtonState.down,
      );
      return;
    }
    if (isHovered) {
      setState(
        _isSelected ? ButtonState.hoverAndSelected : ButtonState.hover,
      );
      return;
    }
    setState(
      _isSelected ? ButtonState.upAndSelected : ButtonState.up,
    );
  }
}
