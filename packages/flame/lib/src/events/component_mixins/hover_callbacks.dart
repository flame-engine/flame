import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive hover
/// events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "hovered" if the point where the hover event occurred is inside the
/// component.
///
/// This mixin is the replacement of the Hoverable mixin.
///
/// This callback uses [PointerMoveDispatcher] to route events.
mixin HoverCallbacks on Component implements PointerMoveCallbacks {
  bool _isHovered = false;

  /// Returns true while the component is being dragged.
  bool get isHovered => _isHovered;

  void onHoverEnter() {}

  void onHoverExit() {}

  /// Called when a hover is interrupted because a pointer button was pressed
  /// while the component was hovered.
  ///
  /// Flutter does not emit `PointerHoverEvent`s while a button is held, so the
  /// hover state ends as soon as the press starts. Override this to react to
  /// that transition (e.g. clear a hover-driven highlight). After a cancel,
  /// [onHoverEnter] will fire again only when a fresh button-free hover
  /// re-enters the area.
  void onHoverCancel() {}

  void _doHoverEnter() {
    _isHovered = true;
    onHoverEnter();
  }

  void _doHoverExit() {
    _isHovered = false;
    onHoverExit();
  }

  /// Called by [PointerMoveDispatcher] when a pointer button is pressed while
  /// this component is hovered. Not intended to be called by user code.
  @internal
  void cancelHover() {
    if (_isHovered) {
      _isHovered = false;
      onHoverCancel();
    }
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    final position = event.localPosition;
    if (containsLocalPoint(position)) {
      if (!_isHovered) {
        _doHoverEnter();
      }
    } else {
      if (_isHovered) {
        _doHoverExit();
      }
    }
  }

  @override
  void onPointerMoveStop(PointerMoveEvent event) {
    if (_isHovered) {
      _doHoverExit();
    }
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    PointerMoveDispatcher.addDispatcher(this);
  }
}
