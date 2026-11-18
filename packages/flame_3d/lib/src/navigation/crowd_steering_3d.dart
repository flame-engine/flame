import 'dart:math' as math;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/navigation.dart';

/// A single 3D navigation crowd agent managed by [CrowdSteering3D].
class CrowdAgent3D({
  required Vector3 position,
  var double radius = 0.4,
  var double maxSpeed = 3.5,
  var double maxAcceleration = 18.0,
  var double waypointReachRadius = 0.25,
  var double arrivalSlowingRadius = 0.8,
  var double timeHorizon = 1.8,
  var double separationWeight = 2.5,
  Vector3? velocity,
  this.targetComponent,
}) {
  this : assert(radius > 0, 'radius must be positive');

  /// Current world-space position of this agent.
  final Vector3 position = position.clone();

  /// Current world-space velocity of this agent.
  final Vector3 velocity = velocity?.clone() ?? Vector3.zero();

  /// Optional visual [Component3D] synchronized to [position] every update.
  Component3D? targetComponent;

  List<Vector3> _path = const [];
  int _waypointIndex = 0;
  final Vector3 _nextVelocity = Vector3.zero();

  /// Current planned waypoint list.
  List<Vector3> get path => _path;

  /// Index of the active waypoint along [path].
  int get currentWaypointIndex => _waypointIndex;

  /// Whether this agent has arrived at the end of its [path] (or has no path).
  bool get hasReachedGoal => _waypointIndex >= _path.length;

  /// Assigns an explicit sequence of 3D [waypoints] to follow.
  void setPath(List<Vector3> waypoints) {
    _path = List.unmodifiable([for (final p in waypoints) p.clone()]);
    _waypointIndex = _path.length > 1 ? 1 : 0;
  }

  /// Plans and assigns a smooth funnel path from [position] to [goal] on
  /// [navMesh]. Returns `true` if a valid path was found.
  bool setDestination(Vector3 goal, NavMesh3D navMesh) {
    final planned = navMesh.findPath(position, goal);
    if (planned.isEmpty) {
      _path = const [];
      _waypointIndex = 0;
      return false;
    }
    setPath(planned);
    return true;
  }

  /// Clears the active path and stops desired motion.
  void stop() {
    _path = const [];
    _waypointIndex = 0;
  }
}

/// Multi-agent 3D crowd steering solver combining waypoint path following,
/// Reciprocal Velocity-Obstacle (RVO) predictive collision avoidance with
/// right-hand symmetry breaking, separation, and optional [NavMesh3D] surface
/// clamping.
class CrowdSteering3D({
  List<CrowdAgent3D>? agents,
  this.navMesh,
  Vector3? upAxis,
  var double safetyMargin = 0.04,
}) {
  /// Managed agents steered together each frame.
  final List<CrowdAgent3D> agents = agents != null
      ? List<CrowdAgent3D>.of(agents)
      : <CrowdAgent3D>[];

  /// Optional [NavMesh3D] used to keep agents clamped onto walkable ground.
  NavMesh3D? navMesh;

  /// Normalized vertical axis perpendicular to the horizontal steering plane.
  final Vector3 upAxis = (upAxis?.clone() ?? Vector3(0.0, 1.0, 0.0))
    ..normalize();

  /// Adds [agent] to the managed crowd.
  void addAgent(CrowdAgent3D agent) {
    if (!agents.contains(agent)) {
      agents.add(agent);
    }
  }

  /// Removes [agent] from the managed crowd.
  void removeAgent(CrowdAgent3D agent) {
    agents.remove(agent);
  }

  /// Advances all [agents] by [dt] seconds without overlapping one another.
  void update(double dt) {
    if (dt <= 0.0 || agents.isEmpty) {
      return;
    }

    final up = upAxis;
    final basisU = up.x.abs() < 0.9
        ? (Vector3(1.0, 0.0, 0.0)..addScaled(up, -up.x))
        : (Vector3(0.0, 1.0, 0.0)..addScaled(up, -up.y));
    basisU.normalize();
    final basisV = up.cross(basisU)..normalize();

    // 1. Compute RVO-avoiding horizontal velocity + path vertical tracking for
    // each agent simultaneously before integrating positions.
    for (var i = 0; i < agents.length; i++) {
      final a = agents[i];
      _computePreferredVelocity(a, up, _prefVel);

      final prefUp = _prefVel.dot(up);
      final prefU = _prefVel.dot(basisU);
      final prefV = _prefVel.dot(basisV);

      var chosenU = prefU;
      var chosenV = prefV;

      if (agents.length > 1) {
        _selectRvoVelocity2D(
          agentIndex: i,
          prefU: prefU,
          prefV: prefV,
          up: up,
          basisU: basisU,
          basisV: basisV,
          outUV: _chosenUV,
        );
        chosenU = _chosenUV.x;
        chosenV = _chosenUV.y;
      }

      // Smoothly accelerate toward chosen velocity within `maxAcceleration`.
      final targetVx = basisU.x * chosenU + basisV.x * chosenV + up.x * prefUp;
      final targetVy = basisU.y * chosenU + basisV.y * chosenV + up.y * prefUp;
      final targetVz = basisU.z * chosenU + basisV.z * chosenV + up.z * prefUp;

      final dvx = targetVx - a.velocity.x;
      final dvy = targetVy - a.velocity.y;
      final dvz = targetVz - a.velocity.z;
      final dvLen = math.sqrt(dvx * dvx + dvy * dvy + dvz * dvz);
      final maxDv = a.maxAcceleration * dt;
      if (dvLen > maxDv && dvLen > 1e-9) {
        final s = maxDv / dvLen;
        a._nextVelocity.setValues(
          a.velocity.x + dvx * s,
          a.velocity.y + dvy * s,
          a.velocity.z + dvz * s,
        );
      } else {
        a._nextVelocity.setValues(targetVx, targetVy, targetVz);
      }
    }

    // 2. Commit velocities and integrate positions.
    for (var i = 0; i < agents.length; i++) {
      final a = agents[i];
      a.velocity.setFrom(a._nextVelocity);
      a.position.addScaled(a.velocity, dt);
    }

    // 3. Enforce strict non-overlap in the horizontal plane in case high crowd
    // density compressed agents closer than `rA + rB`.
    for (var pass = 0; pass < 2; pass++) {
      for (var i = 0; i < agents.length; i++) {
        final a = agents[i];
        for (var j = i + 1; j < agents.length; j++) {
          final b = agents[j];
          // Only separate agents on the same elevation layer (`|dUp| < 1.5`).
          final dUp = (b.position - a.position).dot(up);
          if (dUp.abs() > 1.5) {
            continue;
          }
          final diffX = b.position.x - a.position.x - up.x * dUp;
          final diffY = b.position.y - a.position.y - up.y * dUp;
          final diffZ = b.position.z - a.position.z - up.z * dUp;
          final dist2 = diffX * diffX + diffY * diffY + diffZ * diffZ;
          final minSep = a.radius + b.radius;
          if (dist2 < minSep * minSep) {
            final dist = math.sqrt(dist2);
            double nx;
            double ny;
            double nz;
            if (dist > 1e-6) {
              nx = diffX / dist;
              ny = diffY / dist;
              nz = diffZ / dist;
            } else {
              nx = basisU.x;
              ny = basisU.y;
              nz = basisU.z;
            }
            final push = 0.5 * (minSep - dist + 1e-4);
            a.position.setValues(
              a.position.x - nx * push,
              a.position.y - ny * push,
              a.position.z - nz * push,
            );
            b.position.setValues(
              b.position.x + nx * push,
              b.position.y + ny * push,
              b.position.z + nz * push,
            );
          }
        }
      }
    }

    // 4. Optional NavMesh surface elevation clamping & visual sync.
    final mesh = navMesh;
    for (var i = 0; i < agents.length; i++) {
      final a = agents[i];
      if (mesh != null) {
        final h = mesh.sampleHeightAt(a.position);
        if (h != null) {
          final curH = a.position.dot(up);
          a.position.addScaled(up, h - curH);
        } else {
          final nearest = mesh.findNearestPoly(a.position);
          if (nearest != null) {
            a.position.setFrom(nearest.point);
          }
        }
      }
      a.targetComponent?.position.setFrom(a.position);
    }
  }

  void _computePreferredVelocity(
    CrowdAgent3D agent,
    Vector3 up,
    Vector3 out,
  ) {
    while (agent._waypointIndex < agent._path.length) {
      final wp = agent._path[agent._waypointIndex];
      final dx = wp.x - agent.position.x;
      final dy = wp.y - agent.position.y;
      final dz = wp.z - agent.position.z;
      final dUp = dx * up.x + dy * up.y + dz * up.z;
      final hx = dx - up.x * dUp;
      final hy = dy - up.y * dUp;
      final hz = dz - up.z * dUp;
      final hDist = math.sqrt(hx * hx + hy * hy + hz * hz);
      final isFinal = agent._waypointIndex == agent._path.length - 1;
      final reach = isFinal
          ? math.min(0.08, agent.waypointReachRadius * 0.5)
          : agent.waypointReachRadius;

      if (hDist <= reach && dUp.abs() <= math.max(0.5, agent.radius * 2.0)) {
        agent._waypointIndex++;
        continue;
      }

      final fullLen = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (fullLen <= 1e-8) {
        agent._waypointIndex++;
        continue;
      }

      var speed = agent.maxSpeed;
      if (isFinal &&
          agent.arrivalSlowingRadius > 1e-4 &&
          fullLen < agent.arrivalSlowingRadius) {
        speed =
            agent.maxSpeed *
            (fullLen / agent.arrivalSlowingRadius).clamp(0.1, 1.0);
      }
      final s = speed / fullLen;
      out.setValues(dx * s, dy * s, dz * s);
      return;
    }

    out.setZero();
  }

  void _selectRvoVelocity2D({
    required int agentIndex,
    required double prefU,
    required double prefV,
    required Vector3 up,
    required Vector3 basisU,
    required Vector3 basisV,
    required Vector2 outUV,
  }) {
    final me = agents[agentIndex];
    final myPosU = me.position.dot(basisU);
    final myPosV = me.position.dot(basisV);
    final myPosUp = me.position.dot(up);
    final myVelU = me.velocity.dot(basisU);
    final myVelV = me.velocity.dot(basisV);

    final prefSpeed = math.sqrt(prefU * prefU + prefV * prefV);
    final baseAngle = prefSpeed > 1e-5
        ? math.atan2(prefV, prefU)
        : (myVelU * myVelU + myVelV * myVelV > 1e-5
              ? math.atan2(myVelV, myVelU)
              : 0.0);
    final refSpeed = prefSpeed > 1e-4 ? prefSpeed : me.maxSpeed;

    var bestU = prefU;
    var bestV = prefV;
    var bestPenalty = double.infinity;

    // Candidate angles (in radians) and speed scales around `baseAngle`.
    // In `(basisU, basisV)` with `basisV = up x basisU`, rotating by `-angle`
    // turns to the agent's **right**! A tiny right-side preference (`+0.02` on
    // left turns) breaks exact head-on symmetry deterministically so both
    // opposing agents pass smoothly on their respective right sides!
    for (final speedScale in _speedScales) {
      final spd = speedScale == 0.0 ? 0.0 : refSpeed * speedScale;
      for (var ai = 0; ai < _candidateAngles.length; ai++) {
        if (spd == 0.0 && ai > 0) {
          break;
        }
        final offset = _candidateAngles[ai];
        final ang = baseAngle + offset;
        final cu = spd * math.cos(ang);
        final cv = spd * math.sin(ang);

        final du = cu - prefU;
        final dv = cv - prefV;
        var penalty = math.sqrt(du * du + dv * dv);
        // Right-hand rule tie-breaker (`offset < 0` is right turn in `(U, V)`).
        if (offset > 1e-4) {
          penalty += 0.03 * me.maxSpeed;
        }

        var minTtc = double.infinity;
        for (var j = 0; j < agents.length; j++) {
          if (j == agentIndex) {
            continue;
          }
          final other = agents[j];
          if ((other.position.dot(up) - myPosUp).abs() > 1.5) {
            continue;
          }

          final relPosU = other.position.dot(basisU) - myPosU;
          final relPosV = other.position.dot(basisV) - myPosV;
          final combinedR = me.radius + other.radius + safetyMargin;
          final dist2 = relPosU * relPosU + relPosV * relPosV;
          if (dist2 >
              (combinedR + (me.maxSpeed + other.maxSpeed) * me.timeHorizon) *
                  (combinedR +
                      (me.maxSpeed + other.maxSpeed) * me.timeHorizon)) {
            continue;
          }

          final otherVelU = other.velocity.dot(basisU);
          final otherVelV = other.velocity.dot(basisV);

          // Reciprocal Velocity Obstacle (`2 * v_cand - v_me - v_other`), or
          // full VO if the other agent is stationary.
          final otherMoving =
              otherVelU * otherVelU + otherVelV * otherVelV > 1e-4 ||
              !other.hasReachedGoal;
          final rvoVx = otherMoving
              ? (2.0 * cu - myVelU - otherVelU)
              : (cu - otherVelU);
          final rvoVy = otherMoving
              ? (2.0 * cv - myVelV - otherVelV)
              : (cv - otherVelV);

          final ttc = _timeToCollision2D(
            relPosU,
            relPosV,
            rvoVx,
            rvoVy,
            combinedR,
          );
          if (ttc < minTtc) {
            minTtc = ttc;
          }
        }

        if (minTtc < me.timeHorizon) {
          penalty +=
              me.separationWeight *
              me.maxSpeed *
              (me.timeHorizon / math.max(0.02, minTtc));
        }

        if (penalty < bestPenalty) {
          bestPenalty = penalty;
          bestU = cu;
          bestV = cv;
        }
      }
    }

    outUV.setValues(bestU, bestV);
  }

  static double _timeToCollision2D(
    double px,
    double py,
    double vx,
    double vy,
    double r,
  ) {
    // Ray `0 + t * v` intersecting disk centered at `p` of radius `r`:
    // `||t * v - p||^2 = r^2`.
    final c = px * px + py * py - r * r;
    if (c <= 0.0) {
      // Already inside combined margin: strongly penalize moving closer
      // (`v . p > 0`), allow separating (`v . p < 0`).
      final vp = vx * px + vy * py;
      return vp >= 0.0 ? 0.01 : 0.35;
    }
    final a = vx * vx + vy * vy;
    if (a <= 1e-10) {
      return double.infinity;
    }
    final b = -(vx * px + vy * py); // half-b in `a*t^2 + 2*b*t + c = 0`
    if (b >= 0.0) {
      return double.infinity;
    }
    final disc = b * b - a * c;
    if (disc < 0.0) {
      return double.infinity;
    }
    final t = (-b - math.sqrt(disc)) / a;
    return t >= 0.0 ? t : double.infinity;
  }

  static final Vector3 _prefVel = Vector3.zero();
  static final Vector2 _chosenUV = Vector2.zero();

  static const List<double> _speedScales = [1.0, 0.75, 0.45, 0.0];
  static const List<double> _candidateAngles = [
    0.0,
    -0.2617993877991494, // -15 deg (right)
    0.2617993877991494, // +15 deg (left)
    -0.5235987755982988, // -30 deg
    0.5235987755982988, // +30 deg
    -0.7853981633974483, // -45 deg
    0.7853981633974483, // +45 deg
    -1.0471975511965976, // -60 deg
    1.0471975511965976, // +60 deg
    -1.3962634015954636, // -80 deg
    1.3962634015954636, // +80 deg
    -1.8325957145940461, // -105 deg
    1.8325957145940461, // +105 deg
  ];
}
