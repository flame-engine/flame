import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';

export 'package:vector_math/vector_math.dart' hide Colors;

export 'src/game/notifying_quaternion.dart';
export 'src/game/notifying_vector3.dart';
export 'src/game/transform_3d.dart';

typedef FlameGame3D<W extends World3D> = FlameGame<W>;
