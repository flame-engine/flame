import 'package:example/components/crate.dart';
import 'package:example/components/player.dart';
import 'package:example/components/rendered_point_light.dart';
import 'package:example/components/room_bounds.dart';
import 'package:example/example_game_3d.dart';
import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_console/flame_console.dart';

class DestroyCommand extends FlameConsoleCommand<ExampleGame3D> {
  @override
  String get name => 'destroy';

  @override
  String get description => 'Destroys objects in the world';

  @override
  (String?, String) execute(ExampleGame3D game, ArgResults args) {
    var count = 0;
    for (final arg in args.arguments) {
      switch (arg) {
        case '@all':
          count += destroyMatching(game, (e) => true);
        case '@crate':
          count += destroyMatching(game, (e) => e is Crate);
        case '@light':
          count += destroyMatching(game, (e) => e is RenderedPointLight);
        case '@mesh':
          count += destroyMatching(game, (e) => e is MeshComponent);
        default:
          return ('Invalid argument: $arg', '');
      }
    }
    return (null, '$count objects were destroyed.');
  }

  static bool _ignoredComponents(Component component) {
    return switch (component) {
      Player() => true,
      CameraComponent3D() => true,
      RoomBounds() => true,
      _ => false,
    };
  }

  static int destroyMatching(
    ExampleGame3D game,
    bool Function(Component) predicate,
  ) {
    final toDestroy = game.world.children
        .where((element) => !_ignoredComponents(element))
        .where(predicate)
        .toList();
    for (final obj in toDestroy) {
      game.world.remove(obj);
    }
    return toDestroy.length;
  }
}
