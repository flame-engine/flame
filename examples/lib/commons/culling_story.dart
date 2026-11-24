import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

/// The labels of the knobs that the culling examples share.
const cullingCulledKnob = 'Culled';
const cullingBigViewKnob = 'Big view';

/// The settings of the culling examples that can change while they run, from
/// the knobs of Widgetbook.
mixin CullingControls on FlameGame {
  /// Whether the game culls what is out of view.
  bool get culled;
  set culled(bool value);

  /// How fast the camera moves, where 1 is the normal speed.
  abstract double cameraSpeed;

  /// Called when a setting is changed with the keyboard, with the label of the
  /// knob of the setting and its new value, so that the knob can follow.
  void Function(String knob, Object value)? onKnobChanged;

  /// Tells [onKnobChanged] that the setting of [knob] is now [value].
  void reportKnob(String knob, Object value) =>
      onKnobChanged?.call(knob, value);
}

/// The knob for the speed of the camera of the culling examples.
double cameraSpeedKnob(BuildContext context) {
  return context.knobs.double.slider(
    label: 'Camera speed',
    initialValue: 1,
    max: 5,
    divisions: 20,
    precision: 2,
  );
}

/// Shows a culling example in Widgetbook, and keeps it in sync with the knobs.
///
/// The game is only made again when [gameKey] changes, for the knobs that
/// change what the game is made of. The other knobs are given to the running
/// game with [apply], so that the camera keeps moving from where it is. When
/// the game changes a setting with the keyboard, the knob of that setting is
/// changed too.
class const CullingStory<T extends CullingControls>({
  /// The knobs that need a new game, like the size of the map.
  required final Object gameKey,

  /// Makes the game for the current knobs.
  required final T Function() createGame,

  /// Gives the current knobs to the running game.
  required final void Function(T game) apply,
  super.key,
}) extends StatefulWidget {
  @override
  State<CullingStory<T>> createState() => _CullingStoryState<T>();
}

class _CullingStoryState<T extends CullingControls>()
    extends State<CullingStory<T>> {
  late T _game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _game = _createGame();
  }

  T _createGame() {
    return widget.createGame()..onKnobChanged = _updateKnob;
  }

  @override
  void didUpdateWidget(CullingStory<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameKey != widget.gameKey) {
      _game = _createGame();
    } else {
      widget.apply(_game);
    }
    // Changing a knob gives it the focus, so give it back to the game for its
    // keys to work.
    _focusNode.requestFocus();
  }

  /// Changes the knob [label] to [value], like it was changed in the panel.
  void _updateKnob(String label, Object value) {
    WidgetbookState.maybeOf(context)?.updateQueryField(
      group: 'knobs',
      field: label,
      value: value.toString(),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game, focusNode: _focusNode);
  }
}
