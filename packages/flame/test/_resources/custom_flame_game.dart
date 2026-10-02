import 'package:flame/game.dart';

class CustomFlameGame({
  super.children,
  final Future<void>? Function(FlameGame)? _onLoad,
  final void Function(FlameGame)? _onMount,
}) extends FlameGame {
  @override
  Future<void>? onLoad() => _onLoad?.call(this);

  @override
  void onMount() => _onMount?.call(this);
}
