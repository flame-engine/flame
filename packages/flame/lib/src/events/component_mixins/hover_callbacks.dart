import 'package:flame/events.dart';
import 'package:flame/src/components/core/component.dart';

/// This mixin can be added to a [Component] allowing it to receive hover
/// events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "hovered" if the point where the tap has occurred is inside the component.
///
/// This mixin is the replacement of the Hoverable mixin.
mixin HoverCallbacks on PointerMoveCallbacks {
  bool _isHovered = false;

  /// Returns true while the component is being dragged.
  bool get isHovered => _isHovered;

  void onHoverEnter() {}

  void onHoverExit() {}

  void _doHoverEnter() {
    _isHovered = true;
    onHoverEnter();
  }

  void _doHoverExit() {
    _isHovered = false;
    onHoverExit();
  }

  @override
  void onPointerMoveEvent(PointerMoveEvent event) {
    final position = event.localPosition;
    if (containsPoint(position)) {
      if (!_isHovered) {
        _doHoverEnter();
      }
    } else {
      if (_isHovered) {
        _doHoverExit();
      }
    }
  }
}
