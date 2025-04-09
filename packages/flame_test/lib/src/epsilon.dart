import 'dart:typed_data';

/// Returns the next larger representable float32 value from [value].
///
/// This is useful for creating test values that are just above a target value.
/// For example, if you want a value that's just above 1.0, you can use:
/// `final justAbove1 = nextFloat32(1.0);`
double nextFloat32(double value) {
  // Handle special cases
  if (value.isNaN) {
    return double.nan;
  }
  if (value == double.infinity) {
    return double.infinity;
  }
  if (value == double.negativeInfinity) {
    // The largest negative finite float32
    return -3.4028234663852886e+38;
  }

  // For negative zero, return smallest positive number
  if (value == 0 && _isNegativeZero(value)) {
    return 1.401298464324817e-45; // Smallest positive float32
  }

  // Convert to bits
  final bits = _doubleToInt32Bits(value);

  // For positive numbers, increase by 1
  // For negative numbers, decrease by 1
  final nextBits = value >= 0 ? bits + 1 : bits - 1;

  // Convert back to double
  return _int32BitsToDouble(nextBits);
}

/// Returns the next smaller representable float32 value from [value].
///
/// This is useful for creating test values that are just below a target value.
/// For example, if you want a value that's just below 1.0, you can use:
/// `final justBelow1 = prevFloat32(1.0);`
double prevFloat32(double value) {
  // Handle special cases
  if (value.isNaN) {
    return double.nan;
  }
  if (value == double.negativeInfinity) {
    return double.negativeInfinity;
  }
  if (value == double.infinity) {
    // The largest finite float32
    return 3.4028234663852886e+38;
  }

  // For positive zero, return smallest negative number
  if (value == 0 && !_isNegativeZero(value)) {
    return -1.401298464324817e-45; // Smallest negative float32
  }

  // Convert to bits
  final bits = _doubleToInt32Bits(value);

  // For positive numbers, decrease by 1
  // For negative numbers, increase by 1
  final prevBits = value > 0 ? bits - 1 : bits + 1;

  // Convert back to double
  return _int32BitsToDouble(prevBits);
}

/// Converts a double to its raw 32-bit float representation
int _doubleToInt32Bits(double value) {
  // Create a ByteData to store the floating point value
  final data = ByteData(4);
  // Write the value as a float32
  data.setFloat32(0, value);
  // Read it back as int32
  return data.getInt32(0);
}

/// Converts a raw 32-bit representation back to a double
double _int32BitsToDouble(int bits) {
  // Create a ByteData to store the bits
  final data = ByteData(4);
  // Write the bits as int32
  data.setInt32(0, bits);
  // Read it back as float32
  return data.getFloat32(0);
}

/// Detects if a zero is negative zero
bool _isNegativeZero(double value) {
  if (value != 0) {
    return false;
  }

  // Use bit-level inspection
  final data = ByteData(8);
  data.setFloat64(0, value);
  // The sign bit is the most significant bit
  return (data.getUint8(0) & 0x80) != 0;
}
