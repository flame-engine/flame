import 'dart:typed_data';

import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// The datatype of the accessor's components.
enum ComponentType {
  byte(value: 5120, byteSize: 1),
  unsignedByte(value: 5121, byteSize: 1),
  short(value: 5122, byteSize: 2),
  unsignedShort(value: 5123, byteSize: 2),
  unsignedInt(value: 5125, byteSize: 4),
  float(value: 5126, byteSize: 4);

  final int value;
  final int byteSize;

  const ComponentType({
    required this.value,
    required this.byteSize,
  });

  num parseData(ByteData byteData, {int cursor = 0}) {
    return switch (this) {
      ComponentType.byte => byteData.getInt8(cursor),
      ComponentType.unsignedByte => byteData.getUint8(cursor),
      ComponentType.short => byteData.getInt16(cursor, Endian.little),
      ComponentType.unsignedShort => byteData.getUint16(cursor, Endian.little),
      ComponentType.unsignedInt => byteData.getUint32(cursor, Endian.little),
      ComponentType.float => byteData.getFloat32(cursor, Endian.little),
    };
  }

  static ComponentType valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static ComponentType? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
