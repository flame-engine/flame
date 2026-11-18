import 'dart:typed_data';

/// {@template particle_buffer_3d}
/// Struct-of-arrays storage for the live particles of a `ParticleSystem3D`.
///
/// Every value of every particle lives in a typed list allocated once with
/// room for [capacity] particles, so a running system allocates nothing per
/// particle or per frame and its simulation is a scan over contiguous
/// memory.
///
/// The particles at the indices `0` to `length - 1` are alive. Removing a
/// particle moves the last live particle into its slot.
/// {@endtemplate}
class ParticleBuffer3D(
  /// The maximum number of particles alive at once.
  final int capacity,
) {
  /// {@macro particle_buffer_3d}
  this : assert(capacity > 0, 'capacity must be positive');

  /// The position along x, in the system's simulation space.
  final Float32List posX = Float32List(capacity);

  /// The position along y.
  final Float32List posY = Float32List(capacity);

  /// The position along z.
  final Float32List posZ = Float32List(capacity);

  /// The velocity along x, in units per second.
  final Float32List velX = Float32List(capacity);

  /// The velocity along y.
  final Float32List velY = Float32List(capacity);

  /// The velocity along z.
  final Float32List velZ = Float32List(capacity);

  /// The time since the particle spawned, in seconds.
  final Float32List age = Float32List(capacity);

  /// The reciprocal of the lifespan: `age * invLifespan` is the life
  /// progress, from 0 at spawn to 1 at death.
  final Float32List invLifespan = Float32List(capacity);

  /// The width the particle spawned with (the scale of a mesh particle).
  final Float32List width = Float32List(capacity);

  /// The height the particle spawned with.
  final Float32List height = Float32List(capacity);

  /// The rotation, in radians.
  final Float32List rotation = Float32List(capacity);

  /// The angular velocity, in radians per second.
  final Float32List spin = Float32List(capacity);

  /// The x component of the unit spin axis of a mesh particle.
  final Float32List axisX = Float32List(capacity);

  /// The y component of the spin axis.
  final Float32List axisY = Float32List(capacity);

  /// The z component of the spin axis.
  final Float32List axisZ = Float32List(capacity);

  /// The multiplier of the system's gravity.
  final Float32List gravityScale = Float32List(capacity);

  /// A random value in `[0, 1)` drawn when the particle spawned, for
  /// per-particle variation (blob outlines, flipbook start frames).
  final Float32List seed = Float32List(capacity);

  /// The color the particle spawned with, as a 32-bit ARGB value.
  final Uint32List color = Uint32List(capacity);

  /// One bit per attractor of the system, set while the particle is within
  /// its arrival radius.
  final Uint32List attractorFlags = Uint32List(capacity);

  int _length = 0;

  /// The number of live particles.
  int get length => _length;

  /// Whether [capacity] particles are alive.
  bool get isFull => _length == capacity;

  /// The life progress of the particle at [index], from 0 to 1.
  double progressAt(int index) => age[index] * invLifespan[index];

  /// Activates a slot and returns its index, or `-1` when the buffer is
  /// full. The caller sets every value at that index.
  int spawn() {
    if (_length == capacity) {
      return -1;
    }
    return _length++;
  }

  /// Removes the particle at [index], moving the last live particle into its
  /// slot.
  void removeAt(int index) {
    final last = --_length;
    if (index != last) {
      copy(last, index);
    }
  }

  /// Copies every value of the particle at [from] to [to].
  void copy(int from, int to) {
    posX[to] = posX[from];
    posY[to] = posY[from];
    posZ[to] = posZ[from];
    velX[to] = velX[from];
    velY[to] = velY[from];
    velZ[to] = velZ[from];
    age[to] = age[from];
    invLifespan[to] = invLifespan[from];
    width[to] = width[from];
    height[to] = height[from];
    rotation[to] = rotation[from];
    spin[to] = spin[from];
    axisX[to] = axisX[from];
    axisY[to] = axisY[from];
    axisZ[to] = axisZ[from];
    gravityScale[to] = gravityScale[from];
    seed[to] = seed[from];
    color[to] = color[from];
    attractorFlags[to] = attractorFlags[from];
  }

  /// Removes every particle.
  void clear() {
    _length = 0;
  }
}
