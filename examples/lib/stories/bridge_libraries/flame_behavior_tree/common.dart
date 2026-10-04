import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

/// The width of the area that all the behavior tree examples play in.
const exampleWidth = 400.0;

/// The base class of the behavior tree examples, which gives them a fixed
/// sized area to play in, with the origin at its top left corner.
abstract class BehaviorTreeGame({required double height}) extends FlameGame {
  this
    : super(
        camera: CameraComponent.withFixedResolution(
          width: exampleWidth,
          height: height,
        )..viewfinder.anchor = Anchor.topLeft,
      );
}

/// An invisible component that reports where it is tapped.
class TapArea({required Vector2 size, required this.onTap})
    extends PositionComponent
    with TapCallbacks {
  this : super(size: size);

  final void Function(Vector2 position) onTap;

  @override
  void onTapDown(TapDownEvent event) => onTap(event.localPosition);
}

final _captionStyle = TextPaint(
  style: const TextStyle(color: Colors.white60, fontSize: 10),
);

/// Creates a text with the style used for the explanations in the examples.
TextComponent caption(
  String text, {
  required Vector2 position,
  Anchor anchor = Anchor.topLeft,
}) {
  return TextComponent(
    text: text,
    position: position,
    anchor: anchor,
    textRenderer: _captionStyle,
  );
}

/// Creates a plain colored circle, which is what most of the characters in the
/// examples are made of.
CircleComponent dot(Color color, {required Vector2 position, double r = 10}) {
  return CircleComponent(
    radius: r,
    position: position,
    anchor: Anchor.center,
    paint: Paint()..color = color,
  );
}

final _labels = Expando<String>();

/// Gives [node] a [label], which is shown next to it in a [TreeView].
///
/// Returns [node], so that it can be used right where the node is created.
T named<T extends Node>(String label, T node) {
  _labels[node] = label;
  return node;
}

/// Shows the behavior tree of a component, and what its nodes are doing.
///
/// A node is bold and yellow while it is running. Otherwise it has the color
/// of the last status that it returned: green for success and red for failure,
/// or grey if it has not been ticked, or was aborted.
class TreeView(this.owner, {required Vector2 position})
    extends PositionComponent {
  this : super(position: position);

  final HasBehaviorTree owner;

  final _paints = <(Color, bool), TextPaint>{};

  static const _lineHeight = 12.0;
  static const _indent = 12.0;

  TextPaint _paint(Color color, {required bool bold}) {
    return _paints[(color, bold)] ??= TextPaint(
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontFamily: 'monospace',
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: 1,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _captionStyle.render(
      canvas,
      'Behavior tree (bold yellow: running, green: success, red: failure)',
      Vector2.zero(),
    );
    var line = 1;
    void draw(Node node, int depth) {
      final color = statusColor(
        node.isRunning ? Status.running : node.lastStatus,
      );
      final label = _labels[node];
      final text = _typeName(node) + (label == null ? '' : '  $label');
      final x = depth * _indent;
      final y = line * _lineHeight + 4;
      // The bullet is drawn, because glyphs are not available in all fonts.
      canvas.drawCircle(Offset(x + 3, y + 5), 2.5, Paint()..color = color);
      _paint(color, bold: node.isRunning).render(
        canvas,
        text,
        Vector2(x + 10, y),
      );
      line++;
      final children = switch (node) {
        Composite() => node.children,
        Decorator() => [node.child],
        _ => const <Node>[],
      };
      children.forEach((child) => draw(child, depth + 1));
    }

    draw(owner.behaviorTree.root, 0);
  }
}

/// The name of the type of [node].
///
/// `runtimeType` can not be used for this, because it is minified in release
/// builds, which is what the examples on the website are.
String _typeName(Node node) {
  return switch (node) {
    MoveTo() => 'MoveTo',
    PlayEffect() => 'PlayEffect',
    Task() => 'Task',
    Condition() => 'Condition',
    AsyncTask() => 'AsyncTask',
    Wait() => 'Wait',
    Sequence() => 'Sequence',
    Selector() => 'Selector',
    Parallel() => 'Parallel',
    Inverter() => 'Inverter',
    AlwaysSucceed() => 'AlwaysSucceed',
    AlwaysFail() => 'AlwaysFail',
    Repeat() => 'Repeat',
    RetryOnFailure() => 'RetryOnFailure',
    TimeLimit() => 'TimeLimit',
    Cooldown() => 'Cooldown',
    _ => 'Node',
  };
}

/// The color that is used to show a [Status] in the examples.
Color statusColor(Status? status) {
  return switch (status) {
    Status.success => const Color(0xFF30D158),
    Status.failure => const Color(0xFFFF453A),
    Status.running => const Color(0xFFFFD60A),
    null => const Color(0xFF8E8E93),
  };
}
