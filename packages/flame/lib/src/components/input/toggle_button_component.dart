import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// The [ToggleButtonComponent] is an [AdvancedButtonComponent] that can switch
/// between the selected and not selected state, imagine for example a switch
/// widget or a tab that can be selected.
///
/// Note: You have to set the [defaultSkin], [defaultSelectedSkin]
/// and other skins that you want to use in [onLoad] if you are not passed in
/// through the constructor.
class ToggleButtonComponent extends AdvancedButtonComponent {
  ToggleButtonComponent({
    super.onPressed,
    this.onSelectedChanged,
    super.onChangeState,
    super.defaultSkin,
    super.downSkin,
    super.hoverSkin,
    super.disabledSkin,
    PositionComponent? defaultSelectedSkin,
    PositionComponent? downAndSelectedSkin,
    PositionComponent? hoverAndSelectedSkin,
    PositionComponent? disabledAndSelectedSkin,
    super.defaultLabel,
    super.disabledLabel,
    PositionComponent? defaultSelectedLabel,
    PositionComponent? disabledAndSelectedLabel,
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
    this.defaultSelectedLabel = defaultSelectedLabel;
    this.disabledAndSelectedLabel = disabledAndSelectedLabel;
  }

  /// Callback when button selected changed
  ValueChanged<bool>? onSelectedChanged;

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

  PositionComponent? get defaultSelectedLabel =>
      labelsMap[ButtonState.upAndSelected];

  set defaultSelectedLabel(PositionComponent? value) {
    labelsMap[ButtonState.upAndSelected] = value;
    updateLabel();
  }

  set disabledAndSelectedLabel(PositionComponent? value) {
    labelsMap[ButtonState.disabledAndSelected] = value;
    updateLabel();
  }

  @override
  void onTapUp(TapUpEvent event) {
    isSelected = !_isSelected;
    super.onTapUp(event);
  }

  bool _isSelected = false;

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    if (_isSelected == value) {
      return;
    }
    _isSelected = value;
    updateState();
    onSelectedChanged?.call(_isSelected);
  }

  @override
  @protected
  void setSkin(ButtonState state) {
    var skin = skinsMap[state];
    if (state.isDisabledAndSelected && !hasSkinForState(state)) {
      skin = skinsMap[ButtonState.disabled];
    }
    if (state.isDownAndSelected && !hasSkinForState(state)) {
      skin = skinsMap[ButtonState.down];
    }
    if (state.isHoverAndSelected && !hasSkinForState(state)) {
      skin = skinsMap[ButtonState.hover];
    }
    if (state.isDownAndSelected && !hasSkinForState(state)) {
      skin = skinsMap[ButtonState.down];
    }
    skin = skin ?? (isSelected ? defaultSelectedSkin : defaultSkin);
    skin?.parent = skinContainer;
  }

  @override
  @protected
  void addLabel(ButtonState state) {
    labelAlignContainer.child =
        labelsMap[state] ?? (isSelected ? defaultSelectedLabel : defaultLabel);
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
