part of 'world_3d.dart';

/// {@template shadow_group}
/// Worlds that share one shadow map: the objects of every world of the group
/// cast their shadows onto the objects of every other, as if they were one
/// scene.
/// {@endtemplate}
class ShadowGroup() {
  /// {@macro shadow_group}
  this;

  /// The projection the group's shadow map is rendered with.
  final DirectionalShadowProjection projection = DirectionalShadowProjection();

  final List<World3D> _worlds = [];

  /// The worlds of the group, in the order they joined it (see
  /// [World3D.shadowGroup]).
  List<World3D> get worlds => List.unmodifiable(_worlds);

  /// Combined [World3D.castersVersion] sum across all worlds in this group.
  int get castersVersion {
    var total = 0;
    for (final member in _worlds) {
      total = 0x1fffffff & (total * 31 + member._castersVersion);
    }
    return total;
  }

  /// The union of the bounds of the casters of the last map.
  final Aabb3 _bounds = Aabb3();

  // The frame and the version of the last map, see [_renderFor].
  GraphicsDevice? _device;
  int _frame = -1;
  int? _version;

  /// Makes [world]'s next main pass, whose camera is set in [context],
  /// receive the group's shadow map: reused when it was rendered earlier in
  /// this frame (or cached via [ShadowSettings.cacheWhenStatic]) and is still
  /// bound, rendered otherwise. Returns whether the pass receives shadows.
  bool _renderFor(World3D world, RenderContext3D context, Canvas canvas) {
    final device = context.device;
    final version = _version;
    if (version != null &&
        identical(device, _device) &&
        device.frame == _frame &&
        context.reuseShadowMap(version)) {
      return true;
    }
    _device = device;
    _frame = device.frame;
    _version = null;

    var any = false;
    var groupCastersHash = 0;
    for (final member in _worlds) {
      if (!identical(member._contextOrNull, context)) {
        continue;
      }
      groupCastersHash = Object.hash(
        groupCastersHash,
        member,
        member._castersVersion,
      );
      final bounds = member.sceneBounds;
      if (bounds == null) {
        continue;
      }
      if (any) {
        _bounds.hull(bounds);
      } else {
        _bounds.copyFrom(bounds);
        any = true;
      }
    }

    final key = World3D._shadowCasterKey(this, groupCastersHash, world._lights);
    if (!context.beginShadowPass(
      projection: projection,
      sceneBounds: any ? _bounds : null,
      castersKey: key,
    )) {
      if (context.hasActiveShadows) {
        _version = context.shadowMapVersion;
        return true;
      }
      return false;
    }
    try {
      world._recordCasters(canvas);
      for (final member in _worlds) {
        if (identical(member, world) ||
            !identical(member._contextOrNull, context)) {
          continue;
        }
        member._recordCasters(canvas);
      }
    } finally {
      context.endShadowPass();
    }
    _version = context.shadowMapVersion;
    return true;
  }
}
