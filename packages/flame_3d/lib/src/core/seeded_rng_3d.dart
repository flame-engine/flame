import 'dart:math' as math;

/// Cross-platform deterministic 32-bit-safe SplitMix/Xoshiro128** PRNG
/// implementing [math.Random] so identical integer seeds produce bit-identical
/// sequences across native VM, AOT, and Web targets.
class SeededRng3D(int seed) implements math.Random {
  /// Initializes the generator state from `seed`.
  this {
    var z = seed & 0xFFFFFFFF;
    int nextWord() {
      z = (z + 0x9E3779B9) & 0xFFFFFFFF;
      var t = z ^ (z >>> 16);
      t = _imul32(t, 0x85EBCA6B);
      t = t ^ (t >>> 13);
      t = _imul32(t, 0xC2B2AE35);
      return (t ^ (t >>> 16)) & 0xFFFFFFFF;
    }

    _s0 = nextWord();
    _s1 = nextWord();
    _s2 = nextWord();
    _s3 = nextWord();
    if ((_s0 | _s1 | _s2 | _s3) == 0) {
      _s0 = 1;
    }
  }

  int _s0 = 1;
  int _s1 = 0;
  int _s2 = 0;
  int _s3 = 0;

  static int _imul32(int a, int b) {
    final ah = (a >>> 16) & 0xFFFF;
    final al = a & 0xFFFF;
    final bh = (b >>> 16) & 0xFFFF;
    final bl = b & 0xFFFF;
    return ((al * bl) + ((((ah * bl) + (al * bh)) & 0xFFFF) << 16)) &
        0xFFFFFFFF;
  }

  static int _rotl32(int x, int k) =>
      ((x << k) | ((x & 0xFFFFFFFF) >>> (32 - k))) & 0xFFFFFFFF;

  int _nextUint32() {
    final result = _imul32(_rotl32(_imul32(_s1, 5), 7), 9);
    final t = (_s1 << 9) & 0xFFFFFFFF;
    _s2 = (_s2 ^ _s0) & 0xFFFFFFFF;
    _s3 = (_s3 ^ _s1) & 0xFFFFFFFF;
    _s1 = (_s1 ^ _s2) & 0xFFFFFFFF;
    _s0 = (_s0 ^ _s3) & 0xFFFFFFFF;
    _s2 = (_s2 ^ t) & 0xFFFFFFFF;
    _s3 = _rotl32(_s3, 11);
    return result;
  }

  @override
  bool nextBool() => (_nextUint32() & 1) != 0;

  @override
  int nextInt(int max) {
    if (max <= 0 || max > 0x100000000) {
      throw RangeError.range(max, 1, 0x100000000, 'max');
    }
    if ((max & (max - 1)) == 0) {
      return _nextUint32() & (max - 1);
    }
    final threshold = (0x100000000 - max) % max;
    while (true) {
      final r = _nextUint32();
      if (r >= threshold) {
        return r % max;
      }
    }
  }

  @override
  double nextDouble() => _nextUint32() / 4294967296.0;

  /// Returns a uniform double in `[min, max)`.
  double rangeDouble(double min, double max) =>
      min + (max - min) * nextDouble();
}
