import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

class ToggleButtonComponent extends AdvancedButtonComponent {
  ToggleButtonComponent({
    super.onPressed,
    this.onChange,
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

  void Function(bool isSelected)? onChange;

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
    onChange?.call(_isSelected);
  }

  @mustCallSuper
  @protected
  @override
  void updateState() {
    if (isDisabled) {
      setState(
        _isSelected && hasSkinForState(ButtonState.disabledAndSelected)
            ? ButtonState.disabledAndSelected
            : ButtonState.disabled,
      );
      return;
    }
    if (isPressed) {
      setState(
        _isSelected
            ? hasSkinForState(ButtonState.downAndSelected)
                ? ButtonState.downAndSelected
                : ButtonState.upAndSelected
            : ButtonState.down,
      );
      return;
    }
    if (isHovered) {
      final hoverState =
          _isSelected ? ButtonState.hoverAndSelected : ButtonState.hover;
      if (hasSkinForState(hoverState)) {
        setState(hoverState);
        return;
      }
    }
    setState(
      _isSelected && hasSkinForState(ButtonState.upAndSelected)
          ? ButtonState.upAndSelected
          : ButtonState.up,
    );
  }
}
