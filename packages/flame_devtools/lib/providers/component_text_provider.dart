import 'package:flame_devtools/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentTextProvider = FutureProvider.autoDispose.family<String, int>(
  (ref, id) async {
    return await Repository.getComponentText(id: id);
  },
);
