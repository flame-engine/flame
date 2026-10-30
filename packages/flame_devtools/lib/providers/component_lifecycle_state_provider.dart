import 'package:flame/devtools.dart' show ComponentLifecycleState;
import 'package:flame_devtools/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final componentLifecycleStateProvider =
    FutureProvider.autoDispose.family<ComponentLifecycleState, int>((
      ref,
      id,
    ) async {
      final stateName = await Repository.getComponentLifecycleState(id: id);
      return ComponentLifecycleState.values.byName(stateName);
    });

extension ComponentLifecycleStateX on ComponentLifecycleState {
  /// The human-readable name displayed in the DevTools UI.
  String get display {
    return switch (this) {
      ComponentLifecycleState.removing => 'Removing',
      ComponentLifecycleState.mounted => 'Mounted',
      ComponentLifecycleState.loaded => 'Loaded',
      ComponentLifecycleState.loading => 'Loading',
      ComponentLifecycleState.detached => 'Detached',
    };
  }
}
