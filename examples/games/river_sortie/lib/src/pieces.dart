part of 'river_game.dart';

/// The yaw that turns something built nose along +Z to face [x], [z].
Quaternion _facing(double x, double z) =>
    Quaternion.axisAngle(Vector3(0.0, 1.0, 0.0), math.atan2(x, z));

Quaternion _roll(double angle) =>
    Quaternion.axisAngle(Vector3(0.0, 0.0, 1.0), angle);

/// The player's jet.
///
/// **Flame moves it; the bridge draws it.** [RiverGame] writes the jet's
/// Flame position every step, and `Object3dComponent`, flowing Flame to the
/// scene, writes that into its node, [flightHeight] over the river. The
/// bridge's [visual] node turns it up the river and banks it into a turn.
final class JetComponent extends Object3dComponent
    with CollisionCallbacks, HasGameRef<RiverGame> {
  JetComponent({required super.node, required super.scene})
    : super(
        plane: RiverGame.river,
        direction: SyncDirection.flameToScene,
        elevation: flightHeight,
        size: Vector2(1.5, 1.8),
        anchor: Anchor.center,
      );

  /// Radians rolled about the nose, eased towards what the stick asks for.
  double bank = 0.0;

  /// Up the river is -Z. A fresh one each read: a shared quaternion is one
  /// caller away from being turned in place for every other.
  static Quaternion get _upRiver => _facing(0.0, -1.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  /// The fuel depot under the jet right now, if there is one.
  TargetComponent? get depotBelow {
    for (final other in activeCollisions) {
      if (other is TargetComponent &&
          other.plan.kind == TargetKind.depot &&
          !other.down) {
        return other;
      }
    }
    return null;
  }

  /// Eases the roll towards [stick], full right being a bank of about thirty
  /// degrees into the turn.
  void bankTowards(double stick, double dt) {
    bank += (stick * 0.55 - bank) * math.min(1.0, dt * 6.0);
    visual.setRotation(_upRiver * _roll(bank));
  }

  void show() {
    isVisible = true;
    bank = 0.0;
    visual.setRotation(_upRiver);
  }

  void hide() => isVisible = false;

  /// Anything but a depot is a crash: a bridge still standing, a craft, a
  /// helicopter's bullet.
  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    final solid = switch (other) {
      TargetComponent(:final plan, :final down) =>
        !down && plan.kind != TargetKind.depot,
      BridgeComponent(:final down) => !down,
      EnemyShotComponent() => true,
      _ => false,
    };
    if (solid) {
      gameRef.crash(Crash.collision);
    }
  }
}

/// A tanker, a helicopter, an enemy jet or a fuel depot.
///
/// Still until the jet comes within [RiverGame.wakeRange]; then a tanker or
/// a helicopter that moves at all runs from bank to bank across its
/// channel, a helicopter that is a gunner turns after the jet and fires at
/// it, and a jet crosses the whole valley and comes round again.
///
/// **Shot, it goes the way its kind would.** A tanker lists and sinks,
/// trailing smoke. A helicopter spins and drops into the river. A jet and
/// a depot go up at once, and a depot takes whatever is close with it.
/// From the moment it is hit its hitbox is gone: a sinking tanker is
/// scenery, not something to crash into.
final class TargetComponent extends Object3dComponent
    with HasGameRef<RiverGame>, FixedStepUpdate {
  TargetComponent({
    required this.plan,
    required super.node,
    required super.scene,
    required (double, double) channel,
  }) : heading = plan.heading,
       _limits = (
         math.min(channel.$1 + plan.kind.halfLength, plan.x),
         math.max(channel.$2 - plan.kind.halfLength, plan.x),
       ),
       super(
         plane: RiverGame.river,
         // What flies flies at the jet's height; what floats floats.
         elevation: switch (plan.kind) {
           TargetKind.helicopter || TargetKind.jet => flightHeight,
           TargetKind.tanker || TargetKind.depot => 0.0,
         },
         direction: SyncDirection.flameToScene,
         position: Vector2(plan.x, -plan.distance),
         size: switch (plan.kind) {
           TargetKind.tanker => Vector2(3.4, 1.2),
           TargetKind.helicopter => Vector2(2.4, 1.2),
           TargetKind.jet => Vector2(2.2, 1.0),
           TargetKind.depot => Vector2(1.9, 2.3),
         },
         anchor: Anchor.center,
       ) {
    face();
  }

  /// Seconds between a gunner's shots.
  static const double fireInterval = 1.1;

  /// A gunner fires only at a jet this far ahead of it, and no nearer.
  ///
  /// **From almost as far as it wakes.** Starting at 36 with a shot every
  /// 1.8 seconds, a jet at cruise went through the whole window in about
  /// one interval and drew a single shot, and on the throttle often none.
  /// With the first shot soon after waking, it now draws three at cruise
  /// and two on the throttle.
  static const (double, double) fireRange = (7.0, 46.0);

  /// Seconds from waking to a gunner's first shot.
  static const double firstShot = 0.2;

  final TargetPlan plan;

  /// The stand-in helicopter's blades, spun while it flies. Null for every
  /// other target, and left alone once a model has replaced them.
  SceneNode? rotor;

  int heading;
  bool awake = false;

  /// Hit, and going down the way its kind does.
  bool down = false;

  double _spin = 0.0;
  double _dying = 0.0;
  double _smokeIn = 0.0;
  double _fireIn = firstShot;

  /// Made with the component rather than on load, so a target hit before
  /// Flame has loaded it has a hitbox to take away.
  final RectangleHitbox _hitbox = RectangleHitbox(
    collisionType: CollisionType.passive,
  );

  /// Where the stretch of water it runs across ends, either way: the
  /// channel it was put on, less its own half-length at each end.
  ///
  /// **Handed in, not looked up on load.** A stretch built and dropped in
  /// one step, which a restart does, has its targets loaded by Flame after
  /// they have left the tree, when there is no game to ask for the course.
  final (double, double) _limits;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!down) {
      add(_hitbox);
    }
  }

  /// Turns what is drawn to face [heading] across the river.
  void face() => visual.setRotation(_facing(heading.toDouble(), 0.0));

  /// Takes the hit. False when it was already down, so a shot and a blast
  /// arriving together count once.
  bool hit() {
    if (down) {
      return false;
    }
    down = true;
    _hitbox.removeFromParent();
    // Burnt: the wreck goes down charred, over the material every craft of
    // its kind shares.
    tint.setValues(0.35, 0.3, 0.28, 1.0);
    return true;
  }

  @override
  void fixedUpdate(double dt) {
    if (down) {
      _goDown(dt);
    } else {
      if (!awake &&
          gameRef.built &&
          plan.distance - gameRef.distance < RiverGame.wakeRange) {
        awake = true;
      }
      if (awake && plan.gunner) {
        _hunt(dt);
      }
      if (awake && plan.speed > 0.0) {
        _move(dt);
      }
      final blades = rotor;
      if (blades != null) {
        _spin += dt * 18.0;
        blades.setRotation(Quaternion.axisAngle(Vector3(0.0, 1.0, 0.0), _spin));
      }
    }
  }

  void _move(double dt) {
    position.x += heading * plan.speed * dt;
    if (plan.kind == TargetKind.jet) {
      const edge = riverReach + 8.0;
      if (position.x > edge) {
        position.x = -edge;
      }
      if (position.x < -edge) {
        position.x = edge;
      }
      return;
    }
    final (lo, hi) = _limits;
    if (position.x >= hi && heading > 0 || position.x <= lo && heading < 0) {
      position.x = position.x.clamp(lo, hi);
      heading = -heading;
      face();
    }
  }

  /// A gunner turns to cut across the jet's line, and fires when it has it
  /// in range ahead.
  void _hunt(double dt) {
    if (gameRef.phase != Phase.flying) {
      return;
    }
    final towards = (gameRef.jet.position.x - position.x).sign.toInt();
    if (towards != 0 && towards != heading) {
      heading = towards;
      face();
    }
    _fireIn -= dt;
    final ahead = plan.distance - gameRef.distance;
    if (_fireIn <= 0.0 && ahead > fireRange.$1 && ahead < fireRange.$2) {
      _fireIn = fireInterval;
      gameRef.enemyFire(from: position.clone());
    }
  }

  void _goDown(double dt) {
    _dying += dt;
    _smokeIn -= dt;
    final yaw = _facing(heading.toDouble(), 0.0);
    switch (plan.kind) {
      case TargetKind.tanker:
        // Lists to one side and goes under, smoking as it does.
        visual.setRotation(yaw * _roll(math.min(0.55, _dying * 0.45)));
        elevation = -0.45 * _dying * _dying;
        if (_smokeIn <= 0.0) {
          _smokeIn = 0.22;
          gameRef.smoke(scenePosition..y = 0.8);
        }
        if (_dying > 2.4) {
          removeFromParent();
        }
      case TargetKind.helicopter:
        // Spins about its mast and falls, smoke pouring out, until the
        // river takes it.
        elevation = flightHeight - 0.5 * 9.0 * _dying * _dying;
        visual.setRotation(
          Quaternion.axisAngle(Vector3(0.0, 1.0, 0.0), _dying * 11.0) *
              _roll(0.3),
        );
        if (_smokeIn <= 0.0) {
          _smokeIn = 0.1;
          gameRef.smoke(scenePosition..y += 0.3);
        }
        if (elevation <= 0.0) {
          gameRef.splash(scenePosition..y = 0.1);
          removeFromParent();
        }
      case TargetKind.jet:
      case TargetKind.depot:
        removeFromParent();
    }
  }
}

/// The bridge at the end of a stretch. Solid until shot, and on the last
/// bridge of a level, shielded until the level's task is done.
///
/// **Shot, it breaks in the middle.** It is drawn as two halves, each on a
/// pivot at its own bank end; they swing down into the river, and sink.
final class BridgeComponent extends Object3dComponent
    with HasGameRef<RiverGame>, FixedStepUpdate {
  BridgeComponent({
    required this.section,
    required this.span,
    required this.left,
    required this.right,
    required this.shield,
    required super.node,
    required super.scene,
    required super.position,
    super.owns,
  }) : super(
         plane: RiverGame.river,
         direction: SyncDirection.flameToScene,
         size: Vector2(span, 2.4),
         anchor: Anchor.center,
       );

  /// The index of the section it ends.
  final int section;
  final double span;

  /// The pivots the two halves hang from, at the bank ends.
  final SceneNode left;
  final SceneNode right;

  /// Glowing rails, lit while [RiverGame.shielded] says it cannot fall: a
  /// pilot sees the task is not done before a shot bounces off.
  final SceneNode shield;

  bool down = false;
  double _falling = 0.0;

  /// Made with the component, for the reason [TargetComponent] gives.
  final RectangleHitbox _hitbox = RectangleHitbox(
    collisionType: CollisionType.passive,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!down) {
      add(_hitbox);
    }
  }

  /// Breaks it. False when it was already down.
  bool collapse() {
    if (down) {
      return false;
    }
    down = true;
    _hitbox.removeFromParent();
    return true;
  }

  @override
  void fixedUpdate(double dt) {
    shield.visible = !down && gameRef.shielded(this);
    if (down) {
      _falling += dt;
      final swing = math.min(0.8, _falling * 1.3);
      final sink = math.max(0.0, _falling - 0.7) * 0.9;
      left
        ..setRotation(_roll(-swing))
        ..setPosition(-span / 2.0, deckHeight - sink, 0.0);
      right
        ..setRotation(_roll(swing))
        ..setPosition(span / 2.0, deckHeight - sink, 0.0);
      // The last second under the water it fades rather than blinks out.
      opacity = (3.5 - _falling).clamp(0.0, 1.0);
      if (_falling > 3.5) {
        isVisible = false;
      }
    }
  }
}

/// One shot, straight up the river until it hits something or runs out.
///
/// An instance of the game's one batch of shots rather than a node of its
/// own: at five shots a second with a second of life, there are always a
/// handful in the air, and they are one draw.
final class ShotComponent extends InstancedObject3dComponent
    with CollisionCallbacks, HasGameRef<RiverGame>, FixedStepUpdate {
  ShotComponent({
    required super.batch,
    required super.position,
    required this.speed,
  }) : super(
         plane: RiverGame.river,
         elevation: flightHeight,
         // Longer than the rod drawn: at thirty frames a second a shot moves
         // two and a half metres a frame, and a shorter box could step over
         // a tanker without ever overlapping it.
         size: Vector2(0.4, 1.8),
         anchor: Anchor.center,
       );

  final double speed;
  double _life = 0.9;
  bool _spent = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void fixedUpdate(double dt) {
    position.y -= speed * dt;
    _life -= dt;
    if (_life <= 0.0) {
      _spend();
    }
  }

  void _spend() {
    if (_spent) {
      return;
    }
    _spent = true;
    removeFromParent();
  }

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_spent) {
      return;
    }
    switch (other) {
      case TargetComponent(down: false):
        gameRef.hitTarget(other);
      case BridgeComponent(down: false):
        gameRef.hitBridge(other, at: position.clone());
      default:
        return;
    }
    _spend();
  }
}

/// A helicopter's bullet: slow enough to see and to dodge, flying at where
/// the jet was when it was fired.
final class EnemyShotComponent extends Object3dComponent
    with CollisionCallbacks, FixedStepUpdate {
  EnemyShotComponent({
    required super.node,
    required super.scene,
    required super.position,
    required this.velocity,
  }) : super(
         plane: RiverGame.river,
         elevation: flightHeight,
         direction: SyncDirection.flameToScene,
         size: Vector2.all(0.5),
         anchor: Anchor.center,
       );

  static const double speed = 20.0;

  final Vector2 velocity;
  double _life = 2.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void fixedUpdate(double dt) {
    position.addScaled(velocity, dt);
    _life -= dt;
    if (_life <= 0.0 && !isRemoving) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is JetComponent && !isRemoving) {
      removeFromParent();
    }
  }
}
