part of 'river_game.dart';

/// The one place that turns an empty [RiverGame] into a river and puts the
/// jet on it: the sun and the jet once, and then, every time a run starts or
/// the jet flies on, the stretches around it with their bridges and targets.
///
/// **An extension rather than a second class**, the way the other demo
/// games keep theirs: the river is code, not a level document, and this is
/// the only code that says what is on it. Being in the same library, it
/// reaches the game's private state as a method would.
extension RiverGameStaging on RiverGame {
  /// Opens the river once the 3D device is: the sun, the jet at the start,
  /// and the stretches it can see. Called once, from `buildScene`.
  void build(GraphicsDevice device, Scene scene) {
    _device = device;
    _scene = scene;
    _kit = _Kit(device);
    _shots = InstancedMeshNode(
      _kit.shot,
      _kit.glow,
      capacity: 8,
      name: 'shots',
    );
    scene.add(_shots);
    blasts = Particles3dComponent(
      system: ParticleSystem(capacity: 512),
      plane: RiverGame.river,
    );
    soot = Particles3dComponent(
      system: ParticleSystem(capacity: 128),
      plane: RiverGame.river,
    );
    addAll(<Component>[blasts, soot]);
    wardrobe = ModelWardrobe<Craft>(
      device: device,
      scene: scene,
      looks: Craft.looks,
    );
    scene
      ..ambientIntensity = 0.7
      ..add(
        LightNode(name: 'sun', intensity: 2.4)
          ..setLocalForward(Vector3(-0.35, -1.0, -0.45)),
      );

    jet = JetComponent(
      node: SceneNode(name: 'jet'),
      scene: scene,
    );
    jet.visual.add(
      MeshNode(_kit.playerJet, _kit.painted, name: 'jet primitive'),
    );
    wardrobe.dress(jet.visual, Craft.player);
    add(jet);
    chase = ChaseCamera(
      camera: camera3d,
      target: jet,
      offset: Vector3(0.0, 11.0, 11.0),
      // The water level ahead of the jet, whatever height it flies at.
      lookOffset: Vector3(0.0, -flightHeight, -9.0),
      followAcross: 0.35,
      lookAcross: 0.5,
    )..advance(0.0);
    // After everything that moves the jet, so it follows this frame's move.
    add(ChaseCameraComponent(chase));
    built = true;
    _restart();
  }

  /// Puts the jet at the start of the checkpoint's stretch, with the river
  /// around it built fresh: what was shot there is back, as it was.
  void _restart() {
    _stretches.clear();
    blasts.system.clear();
    soot.system.clear();
    for (final leftover in children.where(
      (child) => child is ShotComponent || child is EnemyShotComponent,
    )) {
      leftover.removeFromParent();
    }
    final start = course.section(run.checkpoint).start + 8.0;
    jet
      ..position.setValues(course.rowAt(start).center, -start)
      ..show();
    speed = 0.0;
    refuelling = false;
    // A fresh run starts with three jets in reserve after the last one
    // ended with none; that is not a jet earned, and says nothing.
    _reserveHeard = run.reserve;
    phase = Phase.ready;
    // The panel names the level while the jet waits; flying announces the
    // next one as it is reached.
    _announced = stage.index;
    banner = null;
    _ensureStretches();
  }

  /// Starts the run on level [index] of [campaign], counting from zero, as
  /// if every level before it had been flown: for looking at a later level
  /// without playing up to it.
  void startOnLevel(int index) {
    run = RunState()..checkpoint = firstSectionOf(index);
    if (built) {
      _restart();
    }
  }

  /// Builds the stretches from a little behind the jet to as far ahead as
  /// the camera sees, and lets go of the ones it has left behind.
  void _ensureStretches() => _stretches.cover(
    course.sectionIndexAt(distance - 25.0),
    course.sectionIndexAt(distance + 160.0),
  );

  _Stretch _buildStretch(int index) {
    final section = course.section(index);
    final valleyGeometry = DeviceMesh.upload(
      _device,
      valleyMesh(section),
      keepSourceData: false,
    );
    final valley = MeshNode(
      valleyGeometry,
      _kit.painted,
      name: 'valley $index',
    );
    final water = MeshNode(_kit.water, _kit.waterMaterial, name: 'water $index')
      ..setPosition(0.0, 0.0, -(section.start + sectionLength / 2.0));
    _scene
      ..add(valley)
      ..add(water);

    BridgeComponent? bridge;
    DeviceMesh? bridgeGeometry;
    DeviceMesh? shieldGeometry;
    if (section.hasBridge) {
      final row = section.rowAt(section.bridgeAt);
      final span = row.half * 2.0 + 2.6;
      bridgeGeometry = DeviceMesh.upload(_device, bridgeHalfMesh(span / 2.0));
      shieldGeometry = DeviceMesh.upload(_device, shieldMesh(span));
      final shield = MeshNode(shieldGeometry, _kit.shield, name: 'shield')
        ..setPosition(0.0, deckHeight, 0.0)
        ..visible = false;
      // Each half hangs from its own bank end; the right one is the left
      // one turned round to reach back towards the middle.
      final left = SceneNode(name: 'bridge $index left')
        ..setPosition(-span / 2.0, deckHeight, 0.0)
        ..add(MeshNode(bridgeGeometry, _kit.painted));
      final right = SceneNode(name: 'bridge $index right')
        ..setPosition(span / 2.0, deckHeight, 0.0)
        ..add(
          MeshNode(bridgeGeometry, _kit.painted)
            ..setRotation(_facing(0.0, -1.0)),
        );
      bridge = BridgeComponent(
        section: index,
        span: span,
        left: left,
        right: right,
        shield: shield,
        node: SceneNode(name: 'bridge $index')
          ..add(left)
          ..add(right)
          ..add(shield),
        scene: _scene,
        position: Vector2(row.center, -section.bridgeAt),
        // The bridge's own span and shield go with it.
        owns: <DeviceMesh>[bridgeGeometry, shieldGeometry],
      );
      add(bridge);
    }

    final targets = <TargetComponent>[
      for (final plan in section.targets) _targetFor(plan),
    ];
    addAll(targets);
    return _Stretch(
      index: index,
      valley: valley,
      water: water,
      geometry: <DeviceMesh>[valleyGeometry],
      bridge: bridge,
      targets: targets,
      reeds: _reedsAlong(index),
    );
  }

  /// Reeds and bushes along both banks of stretch [index], added to the game;
  /// none until the sprites are drawn.
  ///
  /// **The same every time it is flown into**: placed by a random of the
  /// stretch's own, so a stretch dropped behind the jet and built again on
  /// a restart has its reeds where they were. Every one shares the atlas's
  /// texture, material and cards, and the renderer draws the ones of a kind
  /// as one.
  List<SpriteBillboardComponent> _reedsAlong(int index) {
    if (sprites == null) {
      return <SpriteBillboardComponent>[];
    }
    final section = course.section(index);
    final random = GameRandom(index * 7919 + 17);
    final reeds = <SpriteBillboardComponent>[
      for (var at = 3.0; at < sectionLength; at += 6.0)
        for (final side in const <double>[-1.0, 1.0])
          if (random.nextDouble() < 0.6)
            ?_reedAt(
              section,
              section.start + at + random.nextDouble() * 3.0,
              side,
              random,
            ),
    ];
    addAll(reeds);
    return reeds;
  }

  SpriteBillboardComponent? _reedAt(
    Section section,
    double distance,
    double side,
    GameRandom random,
  ) {
    final drawn = sprites!;
    // Nothing on the road to the bridge.
    if ((distance - section.bridgeAt).abs() < 4.0) {
      return null;
    }
    final row = course.rowAt(distance);
    final x =
        (side < 0.0 ? row.left : row.right) +
        side * (0.4 + random.nextDouble() * 0.8);
    if (!row.isLand(x)) {
      return null;
    }
    return SpriteBillboardComponent(
      sprite: drawn.banks[random.nextInt(drawn.banks.length)],
      atlas: atlas,
      device: _device,
      scene: _scene,
      plane: RiverGame.river,
      cardHeight: 1.1 + random.nextDouble() * 0.6,
      position: Vector2(x, -distance),
      elevation: landHeight - 0.05,
    );
  }

  void _dropStretch(int index, _Stretch stretch) {
    stretch.valley.removeFromParent();
    stretch.water.removeFromParent();
    for (final component in <Component>[
      ...stretch.targets,
      ...stretch.reeds,
      ?stretch.bridge,
    ]) {
      if (component.parent != null) {
        component.removeFromParent();
      }
      if (component is TargetComponent) {
        wardrobe.forget(component.visual);
      }
    }
    // Frames already sent may still be drawing the valley; the renderer
    // gives its buffers back once none can be. The bridge owns its own and
    // lets them go the same way when it is removed.
    stretch.geometry.forEach(_release);
  }

  TargetComponent _targetFor(TargetPlan plan) {
    final craft = switch (plan.kind) {
      TargetKind.tanker =>
        plan.distance.floor().isEven ? Craft.tankerA : Craft.tankerB,
      TargetKind.helicopter => Craft.helicopter,
      TargetKind.jet => Craft.enemyJet,
      TargetKind.depot => null,
    };
    final target = TargetComponent(
      plan: plan,
      node: SceneNode(name: plan.kind.name),
      channel:
          course.rowAt(plan.distance).channelAt(plan.x) ?? (plan.x, plan.x),
      scene: _scene,
    );
    final visual = target.visual;
    switch (plan.kind) {
      case TargetKind.tanker:
        visual.add(MeshNode(_kit.tanker, _kit.painted));
      case TargetKind.helicopter:
        final rotor = MeshNode(_kit.rotor, _kit.painted)
          ..setPosition(0.0, 0.53, 0.2);
        target.rotor = rotor;
        visual
          ..add(MeshNode(_kit.helicopter, _kit.painted))
          ..add(rotor);
      case TargetKind.jet:
        visual.add(MeshNode(_kit.enemyJet, _kit.painted));
      case TargetKind.depot:
        visual.add(MeshNode(_kit.depot, _kit.painted));
        signDepot(target);
    }
    if (craft != null) {
      wardrobe.dress(visual, craft);
    }
    return target;
  }

  /// Stands a FUEL sign on the near side of [depot], once the sprites are
  /// drawn: a child of the depot's, so it goes up with it.
  void signDepot(TargetComponent depot) {
    final fuel = sprites?.fuel;
    if (fuel == null || depot.down) {
      return;
    }
    depot.add(
      SpriteBillboardComponent(
        sprite: fuel,
        smooth: true,
        atlas: atlas,
        device: _device,
        scene: _scene,
        plane: RiverGame.river,
        cardHeight: 0.6,
        // Flame's children stand in their parent's box, from its corner: the
        // middle of the depot across, and just past its near end.
        position: Vector2(depot.size.x / 2.0, depot.size.y + 0.1),
        elevation: 0.35,
      ),
    );
  }
}
