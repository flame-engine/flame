import 'package:flame/components.dart' show Component;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The component that is currently selected in the studio.
///
/// This is shared by all panels: the Hierarchy changes it, and the Inspector
/// shows its properties. The selection is cleared whenever the game changes.
final selectedComponentProvider =
    NotifierProvider<SelectionController, Component?>(
      SelectionController.new,
    );

class SelectionController() extends Notifier<Component?> {
  @override
  Component? build() {
    ref.watch(gameControllerProvider.select((s) => s.game));
    return null;
  }

  // ignore: use_setters_to_change_properties
  void select(Component? component) => state = component;

  void clear() => state = null;
}
