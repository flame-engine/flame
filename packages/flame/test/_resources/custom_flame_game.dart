import 'package:flame/game.dart';

class CustomFlameGame extends FlameGame {
  CustomFlameGame({
    super.children,
    Future<void>? Function(FlameGame)? onLoad,
    void Function(FlameGame)? onMount,
  }) : _onLoad = onLoad,
       _onMount = onMount;

  final Future<void>? Function(FlameGame)? _onLoad;
  final void Function(FlameGame)? _onMount;

  @override
  Future<void>? onLoad() => _onLoad?.call(this);

  @override
  void onMount() => _onMount?.call(this);
}
