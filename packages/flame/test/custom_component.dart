import 'dart:async';

import 'package:flame/components.dart';

/// A component where all event handlers can be provided as parameters in the
/// constructor.
class CustomComponent extends Component {
  CustomComponent({
    void Function(CustomComponent, Vector2)? onGameResize,
    FutureOr<void> Function(CustomComponent)? onLoad,
    void Function(CustomComponent)? onMount,
    void Function(CustomComponent)? onRemove,
  })  : _onGameResize = onGameResize,
        _onLoad = onLoad,
        _onMount = onMount,
        _onRemove = onRemove;

  final void Function(CustomComponent, Vector2)? _onGameResize;
  final FutureOr<void> Function(CustomComponent)? _onLoad;
  final void Function(CustomComponent)? _onMount;
  final void Function(CustomComponent)? _onRemove;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _onGameResize?.call(this, size);
  }

  @override
  FutureOr<void> onLoad() => _onLoad?.call(this);

  @override
  void onMount() => _onMount?.call(this);

  @override
  void onRemove() => _onRemove?.call(this);
}
