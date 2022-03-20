import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../game/mixins/has_hoverables.dart';
import '../../gestures/events.dart';

mixin Hoverable on Component {
  bool _isHovered = false;
  bool get isHovered => _isHovered;
  bool onHoverEnter(PointerHoverInfo info) {
    return true;
  }

  bool onHoverLeave(PointerHoverInfo info) {
    return true;
  }

  @nonVirtual
  bool handleMouseMovement(PointerHoverInfo info) {
    if (containsPoint(eventPosition(info))) {
      if (!_isHovered) {
        _isHovered = true;
        return onHoverEnter(info);
      }
    } else {
      if (_isHovered) {
        _isHovered = false;
        return onHoverLeave(info);
      }
    }
    return true;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    assert(
      findGame()! is HasHoverables,
      'Hoverable Components can only be added to a FlameGame with '
      'HasHoverables',
    );
  }
}
