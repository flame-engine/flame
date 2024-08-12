import 'package:flame_devtools/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final positionComponentAttributesProvider =
    FutureProvider.family<PositionComponentAttributes, int>((ref, id) async {
  return Repository.getPositionComponentAttributes(id: id);
});
