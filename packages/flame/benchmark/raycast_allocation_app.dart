import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flame/collisions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'raycast_scene.dart';

/// The app that `tool/measure_raycast_allocations.dart` runs in a profile
/// build, so that it can measure the allocations of casting rays in AOT code
/// like a game has.
///
/// It does nothing by itself: it registers the service extension
/// `ext.flame.raycast`, which casts rays against a scene.
///
/// To run it by hand, from the `examples` directory, which has a macOS runner:
///
///     flutter run -d macos --profile -t ../packages/flame/benchmark/raycast_allocation_app.dart
void main() {
  developer.registerExtension('ext.flame.raycast', _handle);
  runApp(const SizedBox());
}

String? _sceneKey;
RaycastScenery? _scenery;

/// The scene of the arguments, which is kept until another one is asked for.
Future<RaycastScenery> _sceneFor(
  HitboxKind kind,
  RaycastScene scene,
  int count,
) async {
  final key = '${kind.name}/${scene.name}/$count';
  final existing = _scenery;
  if (existing != null && key == _sceneKey) {
    return existing;
  }
  _scenery = null;
  final created = await RaycastScenery.create(
    kind: kind,
    count: count,
    scene: scene,
  );
  _sceneKey = key;
  return _scenery = created;
}

/// Casts rays against a scene, with the arguments (all strings):
///
/// - `kind`: a name of [HitboxKind].
/// - `scene`: a name of [RaycastScene].
/// - `count`: the number of hitboxes.
/// - `rays`: the number of rays to cast, from the rays of the scene in turn.
///
/// It returns the number of rays that hit something and the microseconds that
/// casting took.
Future<developer.ServiceExtensionResponse> _handle(
  String method,
  Map<String, String> parameters,
) async {
  final kind = HitboxKind.values.byName(parameters['kind']!);
  final scene = RaycastScene.values.byName(parameters['scene']!);
  final count = int.parse(parameters['count']!);
  final rays = int.parse(parameters['rays']!);
  final scenery = await _sceneFor(kind, scene, count);
  final detection = scenery.detection;
  final result = RaycastResult<ShapeHitbox>();
  final sceneRays = scenery.rays;
  var hits = 0;
  final watch = Stopwatch()..start();
  for (var i = 0; i < rays; i++) {
    if (detection.raycast(sceneRays[i % sceneRays.length], out: result) !=
        null) {
      hits++;
    }
  }
  final micros = watch.elapsedMicroseconds;
  return developer.ServiceExtensionResponse.result(
    jsonEncode({
      'hits': hits,
      'micros': micros,
      'profileMode': kProfileMode,
    }),
  );
}
