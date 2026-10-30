import 'package:flame_devtools/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentLifecycleStateProvider =
    FutureProvider.autoDispose.family<String, int>((ref, id) async {
      return await Repository.getComponentLifecycleState(id: id);
    });
