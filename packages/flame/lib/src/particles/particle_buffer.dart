import 'dart:typed_data';

/// Struct-of-arrays storage for the live particles of an emitter.
///
/// All per-particle state lives in preallocated typed-data lists, so a
/// running particle system performs no per-particle allocations and the
/// simulation loop is a tight scan over contiguous memory.
///
/// The particles at indices `0` to `length - 1` are alive. Removing a
/// particle swaps the last live particle into its slot, so iteration while
/// removing must not advance the index after a removal.
class ParticleBuffer(
  /// The maximum number of simultaneous particles.
  final int capacity,
) {
  /// Creates a buffer with room for [capacity] simultaneous particles.
  this : assert(capacity > 0, 'capacity must be positive');

  /// The x position, in the emitter's local coordinate system.
  final Float32List posX = Float32List(capacity);

  /// The y position, in the emitter's local coordinate system.
  final Float32List posY = Float32List(capacity);

  /// The x velocity, in local units per second.
  final Float32List velX = Float32List(capacity);

  /// The y velocity, in local units per second.
  final Float32List velY = Float32List(capacity);

  /// Time in seconds since the particle spawned.
  final Float32List age = Float32List(capacity);

  /// The reciprocal of the particle's lifespan; `age[i] * invLifespan[i]`
  /// is the life progress from 0 (spawn) to 1 (death).
  final Float32List invLifespan = Float32List(capacity);

  /// The size the particle had when it spawned, in local units.
  final Float32List baseSize = Float32List(capacity);

  /// The current rendered size (width and height) in local units.
  final Float32List size = Float32List(capacity);

  /// The current rotation in radians.
  final Float32List rotation = Float32List(capacity);

  /// The angular velocity in radians per second.
  final Float32List spin = Float32List(capacity);

  /// The current color as a 32-bit ARGB value.
  final Int32List color = Int32List(capacity);

  int _length = 0;

  /// The number of currently live particles.
  int get length => _length;

  /// Whether the buffer has reached [capacity].
  bool get isFull => _length == capacity;

  /// The life progress of the particle at [index], from 0 to 1.
  double progressAt(int index) => age[index] * invLifespan[index];

  /// Activates one particle slot and returns its index, or -1 when the
  /// buffer is full. The caller is responsible for initializing every field
  /// at the returned index.
  int spawn() {
    if (_length == capacity) {
      return -1;
    }
    return _length++;
  }

  /// Removes the particle at [index] by swapping the last live particle
  /// into its slot.
  void removeAt(int index) {
    final last = --_length;
    if (index != last) {
      posX[index] = posX[last];
      posY[index] = posY[last];
      velX[index] = velX[last];
      velY[index] = velY[last];
      age[index] = age[last];
      invLifespan[index] = invLifespan[last];
      baseSize[index] = baseSize[last];
      size[index] = size[last];
      rotation[index] = rotation[last];
      spin[index] = spin[last];
      color[index] = color[last];
    }
  }

  /// Removes all live particles.
  void clear() => _length = 0;
}
