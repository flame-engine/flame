import 'dart:collection';
import 'dart:ui';

import 'package:flame/components.dart' hide World;
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Decides which hits a [RayCastComponent] looks for.
enum RayCastMode() {
  /// Only the closest hit is looked for, and the ray ends there.
  ///
  /// This is the cheapest mode, since the physics world can stop looking as
  /// soon as it knows which shape is the closest.
  closest,

  /// All hits are looked for, and the ray ends at the farthest one.
  farthest,

  /// All hits are looked for, and the ray is rendered in its full length with
  /// every hit point marked.
  all,
}

/// A component that casts a ray through the physics world of the
/// [Forge2DWorld] that it is added to on every update, and renders it.
///
/// The ray starts at [origin] and travels along [translation], both in world
/// coordinates (meters). Which hits it looks for depends on the [mode]: in
/// [RayCastMode.closest] it is rendered from [origin] to the closest [hit], in
/// [RayCastMode.farthest] to the farthest [hit], and in [RayCastMode.all] in
/// its full length. When nothing is hit, it is rendered to the end of the ray.
/// A circle with a radius of [hitRadius] is drawn where the ray hit a shape.
///
/// [origin] and [translation] can be modified in place, for example to make
/// the ray follow a body or the mouse, and the next update will cast the ray
/// with the new values. Call [castRay] to recast it immediately instead.
///
/// This makes it easy to see what a ray cast hits while debugging, and [hit]
/// and [hits] can also be used directly to react to what the ray hits.
class RayCastComponent({
  Vector2? origin,
  Vector2? translation,
  Paint? paint,

  /// Which hits the ray looks for, see [RayCastMode].
  var RayCastMode mode = RayCastMode.closest,

  /// The filter that decides which shapes the ray can hit, or all shapes
  /// when null.
  var QueryFilter? filter,

  /// The radius, in meters, of the circle that is rendered at the hit points.
  ///
  /// Set it to 0 to not render the hit points.
  var double hitRadius = 0.1,
  super.children,
  super.priority,
  super.key,
}) extends Component with HasPaint, HasWorldRef<Forge2DWorld> {
  this {
    this.paint = paint ?? (Paint()..color = defaultColor);
    this.paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = this.paint.strokeWidth == 0
          ? defaultStrokeWidth
          : this.paint.strokeWidth;
  }

  static const defaultColor = Color(0xFFFF0000);

  /// The stroke width, in meters, that is used when the given paint doesn't
  /// have one.
  static const defaultStrokeWidth = 0.02;

  /// The point that the ray starts from, in world coordinates.
  final Vector2 origin = origin?.clone() ?? Vector2.zero();

  /// The direction and length of the ray, in world coordinates.
  final Vector2 translation = translation?.clone() ?? Vector2(1, 0);

  final Vector2 _endPoint = Vector2.zero();
  final List<RayHit> _hits = [];
  late final UnmodifiableListView<RayHit> _hitsView = UnmodifiableListView(
    _hits,
  );
  RayHit? _hit;

  /// The hit that the ray ends at when it was last cast, or null if it didn't
  /// hit anything.
  ///
  /// This is the closest hit, except in [RayCastMode.farthest] where it is
  /// the farthest one.
  RayHit? get hit => _hit;

  /// The hits that were found when the ray was last cast, sorted from nearest
  /// to farthest.
  ///
  /// In [RayCastMode.closest] this contains at most the closest hit.
  List<RayHit> get hits => _hitsView;

  /// The point where the ray ended when it was last cast.
  ///
  /// This is the point of the [hit], or the end of the ray if nothing was hit
  /// or the [mode] is [RayCastMode.all].
  ///
  /// Don't modify the returned vector, it is reused between casts.
  Vector2 get endPoint => _endPoint;

  /// Casts the ray from [origin] along [translation] and updates [hit],
  /// [hits] and [endPoint].
  void castRay() {
    _hits.clear();
    if (mode == RayCastMode.closest) {
      final closestHit = worldRef.castRayClosest(
        origin,
        translation,
        filter: filter,
      );
      if (closestHit != null) {
        _hits.add(closestHit);
      }
      _hit = closestHit;
    } else {
      worldRef.castRay(origin, translation, _collectHit, filter: filter);
      _hits.sort(_compareFraction);
      _hit = mode == RayCastMode.farthest
          ? _hits.lastOrNull
          : _hits.firstOrNull;
    }

    final hit = _hit;
    if (hit != null && mode != RayCastMode.all) {
      _endPoint.setFrom(hit.point);
    } else {
      _endPoint
        ..setFrom(origin)
        ..add(translation);
    }
  }

  double _collectHit(RayHit hit) {
    _hits.add(hit);
    // Continue looking for more hits without clipping the ray.
    return 1;
  }

  static int _compareFraction(RayHit a, RayHit b) =>
      a.fraction.compareTo(b.fraction);

  @override
  void onMount() {
    super.onMount();
    castRay();
  }

  @override
  void update(double dt) {
    castRay();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawLine(origin.toOffset(), _endPoint.toOffset(), paint);
    if (hitRadius <= 0) {
      return;
    }
    if (mode == RayCastMode.all) {
      for (final hit in _hits) {
        canvas.drawCircle(hit.point.toOffset(), hitRadius, paint);
      }
    } else if (_hit != null) {
      canvas.drawCircle(_endPoint.toOffset(), hitRadius, paint);
    }
  }
}
