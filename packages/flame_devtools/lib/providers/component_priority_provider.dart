import 'package:flame_devtools/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentPriorityProvider = FutureProvider.autoDispose.family<int, int>(
  (ref, id) async {
    return await Repository.getComponentPriority(id: id);
  },
);
