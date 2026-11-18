import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template light_component}
/// A [Component3D] that represents a light source in 3D space.
///
/// The light follows the component's world transform: a point light shines
/// from the component's world position, and a [DirectionalLight] without an
/// explicit direction shines along the component's -Z axis, so rotating the
/// component (or one of its ancestors) turns it.
/// {@endtemplate}
class LightComponent({
  /// What kind of light this is, and its color and intensity. Its values may
  /// be changed at any time.
  required final LightSource source,
  final int _lightMask = 0xFFFFFFFF,
  super.position,
  super.rotation,
}) extends Component3D {
  /// A [PointLight] at [position]. With a [range], its light fades out at that
  /// distance; without, it falls off with the inverse square of the distance.
  LightComponent.point({
    Vector3? position,
    Color color = const Color(0xFFFFFFFF),
    double intensity = 1.0,
    double? range,
    int lightMask = 0xFFFFFFFF,
  }) : this(
         source: PointLight(
           color: color,
           intensity: intensity,
           range: range,
         ),
         lightMask: lightMask,
         position: position,
       );

  /// An [AmbientLight].
  LightComponent.ambient({
    Color color = const Color(0xFFFFFFFF),
    double intensity = 0.2,
    int lightMask = 0xFFFFFFFF,
  }) : this(
         source: AmbientLight(
           color: color,
           intensity: intensity,
         ),
         lightMask: lightMask,
       );

  /// A [DirectionalLight] traveling in [direction] (world space), or, when
  /// it is `null`, along the -Z axis of the component's world [rotation].
  ///
  /// With [shadows] it casts shadows, see [ShadowSettings].
  LightComponent.directional({
    Color color = const Color(0xFFFFFFFF),
    double intensity = 1.0,
    Vector3? direction,
    Quaternion? rotation,
    double specular = 1.0,
    ShadowSettings? shadows,
    int lightMask = 0xFFFFFFFF,
  }) : this(
         source: DirectionalLight(
           color: color,
           intensity: intensity,
           direction: direction,
           specular: specular,
           shadows: shadows,
         ),
         lightMask: lightMask,
         rotation: rotation,
       );

  /// A [HemisphereLight] with the sky towards [up] (+Y by default).
  LightComponent.hemisphere({
    Color skyColor = const Color(0xFFFFFFFF),
    Color groundColor = const Color(0xFF808080),
    double intensity = 0.5,
    Vector3? up,
    int lightMask = 0xFFFFFFFF,
  }) : this(
         source: HemisphereLight(
           skyColor: skyColor,
           groundColor: groundColor,
           intensity: intensity,
           up: up,
         ),
         lightMask: lightMask,
       );

  /// A cone-shaped [SpotLight] at [position] shining along [direction] (or
  /// along the `-Z` axis of [rotation] when [direction] is `null`).
  LightComponent.spot({
    Vector3? position,
    Quaternion? rotation,
    Vector3? direction,
    Color color = const Color(0xFFFFFFFF),
    double intensity = 1.0,
    double innerConeAngle = 0.39269908169872414,
    double outerConeAngle = 0.7853981633974483,
    double? range,
    double specular = 1.0,
    ShadowSettings? shadows,
    int lightMask = 0xFFFFFFFF,
  }) : this(
         source: SpotLight(
           color: color,
           intensity: intensity,
           direction: direction,
           innerConeAngle: innerConeAngle,
           outerConeAngle: outerConeAngle,
           range: range,
           specular: specular,
           shadows: shadows,
         ),
         lightMask: lightMask,
         position: position,
         rotation: rotation,
       );

  /// 32-bit layer bitmask controlling which camera passes receive this light.
  int get lightMask => _light.lightMask;
  set lightMask(int value) {
    if (_light.lightMask == value) {
      return;
    }
    _light.lightMask = value;
    worldOrNull?.markSceneDirty(shadows: false);
  }

  late final Light _light = Light(
    position: Vector3.fromBuffer(
      worldTransformMatrix.storage.buffer,
      12 * Float32List.bytesPerElement,
    ),
    source: source,
    transform: worldTransformMatrix,
    lightMask: _lightMask,
  );

  /// The light this component registers with its world.
  Light get light => _light;

  @override
  void onMount() {
    super.onMount();
    worldRef.addLight(_light);
  }

  @override
  void onRemove() {
    worldRef.removeLight(_light);
    super.onRemove();
  }

  @override
  void update(double dt) {
    // NOTE: this ensures the matrix gets computed if need be, so that
    // the light position and orientation move with its ancestors.
    worldTransformMatrix;
    super.update(dt);
  }
}
