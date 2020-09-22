import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

import '../position.dart';
import 'game.dart';
import 'game_render_box.dart';

/// This a widget to embed a game inside the Widget tree. You can use it in pair with [BaseGame] or any other more complex [Game], as desired.
///
/// It handles for you positioning, size constraints and other factors that arise when your game is embedded within the component tree.
/// Provided it with a [Game] instance for your game and the optional size of the widget.
/// Creating this without a fixed size might mess up how other components are rendered with relation to this one in the tree.
/// You can bind Gesture Recognizers immediately around this to add controls to your widgets, with easy coordinate conversions.
class EmbeddedGameWidget extends LeafRenderObjectWidget {
  final Game game;
  final Position size;

  EmbeddedGameWidget(this.game, {this.size});

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
        child: GameRenderBox(context, game),
        additionalConstraints:
            BoxConstraints.expand(width: size?.x, height: size?.y));
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderConstrainedBox renderBox) {
    renderBox
      ..child = GameRenderBox(context, game)
      ..additionalConstraints =
          BoxConstraints.expand(width: size?.x, height: size?.y);
  }
}
